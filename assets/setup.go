package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

// ========================== LISTA DE PROGRAMAS ==========================
var systemPackages = []string{
	"nmap", "sed", "wireshark", "hydra", "sqlmap",
	"mysql-server", "mariadb-server", "snapd", "geoip-bin", "sublist3r",
	"nikto", "dsniff", "hping3", "macchanger", "git",
	"openssl", "uuid-runtime", "gparted", "tar", "coreutils",
	"ca-certificates", "curl", "python3", "python3-argcomplete",
	"python3-pip", "python3-full", "pipx",
}

var dockerContainers = []string{
	"metasploit-framework", "armitage", "spiderfoot",
	"DVWA", "sysreptor-app", "nessus-managed",
}

var pythonPipx = []string{
	"SEToolKit", "exegol",
}

var snapPackages = []string{
	"sublime-text",
}

// ========================== MAPA DE PAQUETES POR DISTRO ==========================
var packageMap = map[string]map[string]string{
	"mysql-server": {
		"ubuntu": "mysql-server",
		"debian": "mysql-server",
		"fedora": "mariadb-server",
		"centos": "mariadb-server",
		"arch":   "mariadb",
	},
	"uuid-runtime": {
		"ubuntu": "uuid-runtime",
		"debian": "uuid-runtime",
		"fedora": "uuid",
		"centos": "uuid",
		"arch":   "util-linux",
	},
	"geoip-bin": {
		"ubuntu": "geoip-bin",
		"debian": "geoip-bin",
		"fedora": "GeoIP",
		"centos": "GeoIP",
		"arch":   "geoip",
	},
}

// ========================== DETECCIÓN DE DISTRIBUCIÓN ==========================
func detectDistro() string {
	content, err := os.ReadFile("/etc/os-release")
	if err != nil {
		return "unknown"
	}
	text := strings.ToLower(string(content))
	switch {
	case strings.Contains(text, "ubuntu"):
		return "ubuntu"
	case strings.Contains(text, "debian"):
		return "debian"
	case strings.Contains(text, "fedora"):
		return "fedora"
	case strings.Contains(text, "centos"):
		return "centos"
	case strings.Contains(text, "arch"):
		return "arch"
	case strings.Contains(text, "opensuse"):
		return "opensuse"
	default:
		return "unknown"
	}
}

func detectPkgManager(distro string) string {
	switch distro {
	case "ubuntu", "debian":
		return "apt"
	case "fedora":
		return "dnf"
	case "centos":
		return "yum"
	case "arch":
		return "pacman"
	case "opensuse":
		return "zypper"
	default:
		return ""
	}
}

// ========================== EJECUCIÓN DE COMANDOS ==========================
func runCommand(name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func installSystemPackage(pkgName string, pkgManager string, distro string) {
	// Mapear paquete según distro
	if m, ok := packageMap[pkgName]; ok {
		if mapped, exists := m[distro]; exists {
			pkgName = mapped
		}
	}

	fmt.Printf("[..] Instalando %s...\n", pkgName)

	var cmdErr error
	switch pkgManager {
	case "apt":
		cmdErr = runCommand("sudo", "apt-get", "install", "-y", pkgName)
	case "dnf":
		cmdErr = runCommand("sudo", "dnf", "install", "-y", pkgName)
	case "yum":
		cmdErr = runCommand("sudo", "yum", "install", "-y", pkgName)
	case "pacman":
		cmdErr = runCommand("sudo", "pacman", "-S", "--noconfirm", pkgName)
	case "zypper":
		cmdErr = runCommand("sudo", "zypper", "--non-interactive", "install", pkgName)
	default:
		fmt.Printf("[Error] Gestor de paquetes desconocido para %s\n", pkgName)
		return
	}

	if cmdErr != nil {
		fmt.Printf("[Error] Fallo al instalar %s: %v\n", pkgName, cmdErr)
	} else {
		fmt.Printf("[OK] %s instalado.\n", pkgName)
	}
}

// ========================== INSTALACIÓN DOCKER ==========================
func installDocker(distro string, pkgManager string) error {
	fmt.Println("[..] Instalando Docker...")
	switch distro {
	case "ubuntu", "debian":
		runCommand("sudo", "apt-get", "update")
		runCommand("sudo", "apt-get", "install", "-y", "ca-certificates", "curl", "gnupg", "lsb-release")
		runCommand("sudo", "mkdir", "-p", "/etc/apt/keyrings")
		runCommand("sudo", "curl", "-fsSL", "https://download.docker.com/linux/"+distro+"/gpg", "-o", "/etc/apt/keyrings/docker.gpg")
		runCommand("sudo", "bash", "-c", fmt.Sprintf(`echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/%s %s stable" > /etc/apt/sources.list.d/docker.list`, distro, os.Getenv("VERSION_CODENAME")))
		runCommand("sudo", "apt-get", "update")
		runCommand("sudo", "apt-get", "install", "-y", "docker-ce", "docker-ce-cli", "containerd.io", "docker-buildx-plugin", "docker-compose-plugin", "docker-ce-rootless-extras")
	default:
		fmt.Println("[Aviso] Instalación Docker solo automatizada para Debian/Ubuntu. Debes instalar manualmente en otras distros.")
	}
	return nil
}

// ========================== FUNCIÓN PRINCIPAL ==========================
func main() {
	distro := detectDistro()
	pkgManager := detectPkgManager(distro)

	fmt.Printf("Distro detectada: %s, Gestor de paquetes: %s\n", distro, pkgManager)

	// Instalación de paquetes de sistema
	for _, pkg := range systemPackages {
		installSystemPackage(pkg, pkgManager, distro)
	}

	// Instalación Docker
	if err := installDocker(distro, pkgManager); err != nil {
		fmt.Println("[Error] Fallo instalando Docker:", err)
	} else {
		fmt.Println("[OK] Docker instalado.")
	}

	// Aquí puedes agregar instalación de contenedores, Python/pipx y Snap
	fmt.Println("[..] Instalación de contenedores y herramientas Python/pipx y Snap no implementada aún en este ejemplo.")
}
