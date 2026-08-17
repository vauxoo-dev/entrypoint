package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var (
	Number    = "0.0.0-alpha.8"
	Build     = "LocalBuild"
	BuildDate = ""
)

// versionCmd represents the version command
var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Shows version and build details",
	Long:  `Show the current version, commit used to build the command and the build date.`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("Version: %s\n", Number)
		fmt.Printf("Build: %s\n", Build)
		fmt.Printf("Build date: %s\n", BuildDate)
	},
}

func init() {
	rootCmd.AddCommand(versionCmd)
}
