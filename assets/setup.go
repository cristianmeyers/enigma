package main

import (
	"fmt"
	"os"
	"os/exec"
	"os/user"
	"strings"
)

func color(text string, colorCode string) string {
	return fmt.Sprintf("\033[%sm%s\033[0m", colorCode, text)
}

func message(text string, colorCode string) string {
	lenText := len(text)
	border := lenText + 10
	padding := (border - lenText) / 2

	paddingLeft := strings.Repeat(" ", padding)
	paddingText := fmt.Sprintf("%s%s", paddingLeft, color(text, colorCode))
	line := strings.Repeat("=", border)

	return fmt.Sprintf("%s\n%s\n%s", line, paddingText, line)
}

func errorMaker(err error, errorMessage string) {
	if err != nil {
		fmt.Printf("\r[ %s ] %s\n", color("Error", "31"), errorMessage)
		os.Exit(1)
	}
}

func requirement() bool {
	currentUser, err := user.Current()
	errorMaker(err, "Cannot get current user")
	if currentUser.Uid == "0" {
		return true
	}
	return false
}

func checkDependencies() bool {
	dependencies := []string{"sudo", "tee"}
	missing := []string{}
	fmt.Println(len(missing))
	for _, dep := range dependencies {
		if !isInstalled(dep) {
			missing = append(missing, dep)
		}
	}
	fmt.Println(len(missing))

	if len(missing) > 0 {
		text := fmt.Sprintf("%s %s", color("Missing dependencies:", "33"), color(strings.Join(missing, ", "), "36"))
		fmt.Println(message(text, "33"))
		return false
	}

	return true
}

func isInstalled(program string) bool {
	cmd := exec.Command("command", "-v", program)
	err := cmd.Run()
	return err == nil
}

func updater() {
	commands := [][]string{
		{"apt-get", "update", "-qq"},
		{"apt-get", "full-upgrade", "-yq"},
		{"dnf", "makecache", "--quiet"},
		{"dnf", "upgrade", "-y"},
		{"yum", "makecache", "fast", "--quiet"},
		{"yum", "update", "-y"},
		{"zypper", "refresh", "--non-interactive"},
		{"zypper", "update", "--non-interactive"},
		{"pacman", "-Syu", "--noconfirm"},
		{"microdnf", "update", "-y"},
	}

	for i := 0; i < len(commands); i += 2 {
		if isInstalled(commands[i][0]) {
			if err := exec.Command("sudo", commands[i]...).Run(); err != nil {
				fmt.Println(message("Error updating package cache.", "31"))
				os.Exit(1)
			}
			if err := exec.Command("sudo", commands[i+1]...).Run(); err != nil {
				fmt.Println(message("Error updating packages.", "31"))
				os.Exit(1)
			}
			fmt.Println(message("System update completed successfully.", "32"))
			return
		}
	}

	fmt.Println(message("No compatible package manager found.", "31"))
	os.Exit(1)
}

func main() {
	cmd := exec.Command("clear")
	cmd.Run()

	if requirement() {
		fmt.Println(message("Root user is not allowed to execute this script!", "33"))
		os.Exit(1)
	}

	if !checkDependencies() {
		os.Exit(1)
	}

	updater()
}
