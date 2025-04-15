#!/bin/bash

clear

#color
colorRED="\033[0;31m"
colorGREEN="\033[0;32m"
colorORANGE='\033[0;33m'
noCOLOR="\033[0m"
backCOLORYELLOW="\033[1;43m"

is_root() {
    if [ "$EUID" -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

update_packages() {
    if command -v apt-get &>/dev/null; then
        sudo DEBIAN_FRONTEND=noninteractive apt-get update &>/dev/null && sudo DEBIAN_FRONTEND=noninteractive apt-get -yq full-upgrade &>/dev/null
    elif command -v dnf &>/dev/null; then
        sudo dnf makecache --quiet &>/dev/null && sudo dnf -y upgrade &>/dev/null
    elif command -v yum &>/dev/null; then
        sudo yum makecache fast --quiet &>/dev/null && sudo yum -y update &>/dev/null
    elif command -v zypper &>/dev/null; then
        sudo zypper --non-interactive refresh &>/dev/null && sudo zypper --non-interactive update &>/dev/null
    elif command -v pacman &>/dev/null; then
        sudo pacman -Syu --noconfirm &>/dev/null
    elif command -v microdnf &>/dev/null; then
        sudo microdnf update -y &>/dev/null
    else
        echo "Gestionnaire de paquets inconnu ou non trouvée" >&2
        exit 1
    fi
}

install_command() {
    if command -v apt-get &>/dev/null; then
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq $1 &>/dev/null
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y $1 &>/dev/null
    elif command -v yum &>/dev/null; then
        sudo yum install -y $1 &>/dev/null
    elif command -v zypper &>/dev/null; then
        sudo zypper --non-interactive install $1 &>/dev/null
    elif command -v pacman &>/dev/null; then
        sudo pacman -S $1 --noconfirm &>/dev/null
    elif command -v microdnf &>/dev/null; then
        sudo microdnf install $1 -y &>/dev/null
    else
        echo "Gestionnaire de paquets inconnu ou non trouvée" >&2
        exit 2
    fi
}

is_package_installed() {
    if command -v dpkg &>/dev/null; then
        dpkg -l | grep -qw $1
    elif command -v rpm &>/dev/null; then
        rpm -q $1 &>/dev/null
    elif command -v apk &>/dev/null; then
        apk info $1 &>/dev/null
    else
        echo "SystÃ¨me non reconnu"
        return 2
    fi
}

require_command() {
    if ! command_exists $1; then
        install_command $1
    fi
}

docker_container_exists() {
    docker ps -a --format "{{.Names}}" | grep -wq "^$1$"
}

if is_root; then
    echo -e "${colorRED}############################################################${noCOLOR}"
    echo -e "${colorRED}##                                                        ##${noCOLOR}"
    echo -e "${colorRED}##          The script must not be run as root !          ##${noCOLOR}"
    echo -e "${colorRED}##                                                        ##${noCOLOR}"
    echo -e "${colorRED}############################################################${noCOLOR}"
    exit -1
fi

if ! command_exists sudo; then
    echo -e "${colorRED}############################################################${noCOLOR}"
    echo -e "${colorRED}##                                                        ##${noCOLOR}"
    echo -e "${colorRED}##                Missing dependency: sudo                ##${noCOLOR}"
    echo -e "${colorRED}##                                                        ##${noCOLOR}"
    echo -e "${colorRED}############################################################${noCOLOR}"
    exit -1
fi

if ! command_exists tee; then
    echo -e "${colorRED}############################################################${noCOLOR}"
    echo -e "${colorRED}##                                                        ##${noCOLOR}"
    echo -e "${colorRED}##                Missing dependency: tee                 ##${noCOLOR}"
    echo -e "${colorRED}##                                                        ##${noCOLOR}"
    echo -e "${colorRED}############################################################${noCOLOR}"
    exit -1
fi

echo -e -n "\r[ .. ] Login into sudo !"
sudo -v &>/dev/null
if [ $? -ne 0 ]; then
    echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to login into sudo !${noCOLOR}"
    exit -1
fi
clear
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Login into sudo !"

echo -e -n "\r[ .. ] Update all packages from repo !"
update_packages
if [ $? -ne 0 ]; then
    echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to update all packages from repo !${noCOLOR}"
    exit 3
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Update all packages from repo !"

echo -e -n "\r[ .. ] Install command ${colorORANGE}sed${noCOLOR} !"
require_command sed
if ! command_exists sed; then
    echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install ${colorORANGE}sed${colorRED} !${noCOLOR}"
    exit 4
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install command ${colorORANGE}sed${noCOLOR} !"

echo -e -n "\r[ .. ] Configure ${colorORANGE}sudo${noCOLOR} authorisations !"
sudo sed -E -i "s/^\s*(%sudo\s+[A-Za-z0-9]+\s*=\s*\(\s*[A-Za-z0-9]+\s*:\s*[A-Za-z0-9]+\s*\)\s+)([A-Za-z0-9]+\s*)$/\1NOPASSWD: \2/g" /etc/sudoers
if [ $? -ne 0 ]; then
    echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to edit sudower file !${noCOLOR}"
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Configure ${colorORANGE}sudo${noCOLOR} authorisations !"

echo -e "${colorRED}############################################################${noCOLOR}"
echo -e "${colorRED}##                                                        ##${noCOLOR}"
echo -e "${colorRED}##                Insstallation de Docker                 ##${noCOLOR}"
echo -e "${colorRED}##                                                        ##${noCOLOR}"
echo -e "${colorRED}############################################################${noCOLOR}"

cd ~/
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
curl -fsSL "https://get.docker.com/" | sh
sudo usermod -aG docker $(id -u -n)
newgrp docker
