#!/bin/sh
############################################################################################
# Installer for entrypoint, always will download the latest version                               #
############################################################################################
set -e

get_arch() {
  arch=$(uname -m)
  case $arch in
    x86_64) arch="amd64" ;;
    x86) arch="386" ;;
  esac
  echo ${arch}
}

wget_auth() {
    if [ -n "${GITHUB_TOKEN}" ]; then
        wget --header="Authorization: token ${GITHUB_TOKEN}" "$@"
    else
        wget "$@"
    fi
}

download_url() {
    api_url=$1
    url_for=$2
    wget_auth -q -O- ${api_url}  | grep browser_download_url | grep ${url_for} | sed '/-/!{s/$/_/}' | sort -V | sed 's/_$//' | tail -n 1 |  awk '{print $2}' | tr -d '"' | tr -d ','
}

get_filename() {
    api_url=$1
    url_for=$2
    wget_auth -q -O- ${api_url}  | grep name | grep ${url_for} | sed '/-/!{s/$/_/}' | sort -V | sed 's/_$//' | tail -n 1 |  awk '{print $2}' |  tr -d '"' | tr -d ','
}


release_version() {
    api_url=$1
    wget_auth -q -O- ${api_url}  | grep tag_name | sed '/-/!{s/$/_/}' | sort -V | sed 's/_$//' | tail -n 1 |  awk '{print $2}' |  tr -d '"' | tr -d ','
}

check_sha() {
    org=$1
    expected=$2

    current=$(sha256sum $1 | cut -d ' ' -f 1)
    if [ "$expected" != "$current" ]; then
        echo "failed sha256sum for '$org', ${expected} vs ${current} don't match"
        return 1
    fi
}

BINARY=entrypoint
REPO=entrypoint
FORMAT=tar.gz
BINDIR=/
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(get_arch)
API_URL=https://api.github.com/repos/OrchestSh/${REPO}/releases
URL=$(download_url ${API_URL} ${OS}_${ARCH})
CHECKSUMS=$(download_url ${API_URL} checksums.txt)
TEMP=$(mktemp -d)
SUMSLOCAL=${TEMP}/checksums.txt
TAG=$(release_version ${API_URL})
FULLNAME=$(get_filename ${API_URL} ${OS}_${ARCH})


download() {
    url=$1
    dest=$2
    wget_auth -q -O ${dest} "${url}"
}

echo "Version ${TAG} will be installed"
echo "Downloading binaries..."
download ${URL} ${TEMP}/${FULLNAME}
download ${CHECKSUMS} ${SUMSLOCAL}
# Check sha256 sum
echo "Cheking sha of the file"
sha=$(grep "${FULLNAME}" "${SUMSLOCAL}" 2>/dev/null | tr '\t' ' ' | cut -d ' ' -f 1)
check_sha ${TEMP}/${FULLNAME} $sha

echo "Decompressing and installing"
(cd "${TEMP}" && tar --no-same-owner -xzf "${FULLNAME}" && mv ${BINARY} ${BINDIR})

rm -r ${TEMP}

echo "Done"
