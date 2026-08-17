entrypoint
==========

This repo will host the entry point for all of our instances.

The new version have been rewritten in Go, check the release section and download the latest version.

This is not a process manager, that's the [supervisord](http://supervisord.org/) this means that if you want to add or modify
how processes are being managed use the proper supervisor configuration files.

Install from the build
--

The entry point can be installed automatically during the build stage of you image just add the following in your Dockerfile:

```dockerfile
ARG GITHUB_TOKEN=""
RUN if [ -n "$GITHUB_TOKEN" ]; then \
        wget --header="Authorization: token $GITHUB_TOKEN" -O- https://raw.githubusercontent.com/OrchestSh/entrypoint/master/installer.sh | GITHUB_TOKEN="$GITHUB_TOKEN" sh ; \
    else \
        wget -O- https://raw.githubusercontent.com/OrchestSh/entrypoint/master/installer.sh | sh ; \
    fi
...
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/entrypoint"]
```

This will download and deploy the entry_point in the ```/``` path.

If `GITHUB_TOKEN` is passed as a build arg, `installer.sh` will use it to authenticate against GitHub API (`api.github.com`), avoiding rate limit errors in CI/CD environments. 

Environment variables
--

The entry_point can be tuned using any of the following env vars:

```GITHUB_TOKEN```: If set, `installer.sh` will use this token to authenticate requests against the GitHub API (`api.github.com`) to query releases and avoid unauthenticated rate limits (60 req/hour vs 5,000 req/hour).

```DEBUG_ENTRYPOINT```: Will log debug output and be more verbose

```AUTOSTART```: If False will set all the processed from supervisor to autostart false, if true will **only**
set the `odoo` process to true, will leave the others as they are set. In case the var is not set, nothing will change.

```ORCHESTSH_STDOUT```: Will force all the instance logs to the standard output, this is usefully when deploying the
container in kubernetes or docker swarm, all the logs can be read by any collector that can read the container logs.

Configuring Odoo instance
--

The instance running inside can be configured using env vars just take in mind that they need to have the ```ODOORC_``` prefix.

```shell
ODOORC_DB_HOST=1.1.1.1
ODOORC_DB_USER=odoo
```

Those variables will be pased and replaced in the Odoo configuration file, you don't need to use uppercase
always, but is a good practice.

If the variable is not in the config file they will be added in the ```options``` section, if they are present in other
section they will be replaced there.

Sections in Odoo configuration file
--

Add the required files with the sections in ```/external_files/odoocfg``` and the entry_point will append them to the
default configuration file to replace the vaules with the env vars just add the ```ODOORC_``` prefix to the variable name
and will be replaced in the corresponding section


TODO
--

- [ ] Add support for docker secrets
- [ ] Add support for Vault secrets manager
- [ ] Improve testing 
- [ ] Add coverage support
