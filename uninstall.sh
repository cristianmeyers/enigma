#!/bin/bash

function color() {
    echo -e "\e[${2}m${1}\e[0m"
}

function uninstall_program() {
    local program="$1"
    echo -ne "\r[ $(color "..." "32") ] Uninstalling $(color "$program" "32")..."
    if command -v "$program" &> /dev/null || dpkg-query -W -f='${Status}' "$program" 2>/dev/null | grep -q "ok installed"; then
        sudo apt-get remove --purge -y "$program" &> /dev/null && \
        echo -e "\r[ $(color "OK" "32") ] $(color "$program" "32") uninstalled." || \
        echo -e "\r[ $(color "Error" "31") ] Failed to uninstall $(color "$program" "32")."
    elif snap list 2>/dev/null | grep -qw "$program"; then
        sudo snap remove "$program" &> /dev/null && \
        echo -e "\r[ $(color "OK" "32") ] $(color "$program" "32") uninstalled (Snap)." || \
        echo -e "\r[ $(color "Error" "31") ] Failed to uninstall $(color "$program" "32") (Snap)."
    elif flatpak list 2>/dev/null | grep -qw "$program"; then
        sudo flatpak uninstall -y "$program" &> /dev/null && \
        echo -e "\r[ $(color "OK" "32") ] $(color "$program" "32") uninstalled (Flatpak)." || \
        echo -e "\r[ $(color "Error" "31") ] Failed to uninstall $(color "$program" "32") (Flatpak)."
    else
        echo -e "\r[ $(color "OK" "32") ] $(color "$program" "32") is not installed."
    fi
}

function uninstall_docker() {
    echo -ne "\r[ $(color "..." "32") ] Removing Docker containers and images..."
    if command -v docker &> /dev/null; then
        docker ps -aq | xargs -r docker stop &> /dev/null
        docker ps -aq | xargs -r docker rm &> /dev/null
        docker images -q | xargs -r docker rmi -f &> /dev/null
        sudo apt-get remove --purge -y docker docker-engine docker.io containerd runc &> /dev/null
        echo -e "\r[ $(color "OK" "32") ] Docker uninstalled."
    else
        echo -e "\r[ $(color "OK" "32") ] Docker is not installed."
    fi
}

function remove_directories() {
    local directories=("$HOME/spiderfoot" "$HOME/.password" "$HOME/subshell.sh")
    for dir in "${directories[@]}"; do
        if [ -e "$dir" ]; then
            rm -rf "$dir" &> /dev/null && \
            echo -e "\r[ $(color "OK" "32") ] Directory/File $(color "$dir" "32") removed." || \
            echo -e "\r[ $(color "Error" "31") ] Failed to remove $(color "$dir" "32")."
        else
            echo -e "\r[ $(color "OK" "32") ] Directory/File $(color "$dir" "32") does not exist."
        fi
    done
}

function remove_no_passwd() {
    local user=$(whoami)
    if sudo grep -q "^$user.*NOPASSWD: ALL" /etc/sudoers; then
        sudo sed -i "/^$user.*NOPASSWD: ALL/d" /etc/sudoers && \
        echo -e "[ $(color "OK" "32") ] No-password setup removed for $(color "$user" "32")." || \
        echo -e "[ $(color "Error" "31") ] Failed to remove no-password setup for $(color "$user" "32")."
    else
        echo -e "[ $(color "OK" "32") ] No-password setup not found for $(color "$user" "32")."
    fi
}

function main() {
    echo -e "$(color "Starting uninstallation..." "32")\n"
    local programs=(
        curl nmap sed wireshark hydra sqlmap mysql-server
        snapd geoip-bin sublist3r nikto dsniff hping3 macchanger git openssl
        uuid-runtime gparted tar python3 python3-argcomplete
        python3-pip python3-full pipx
    )
    for program in "${programs[@]}"; do
        uninstall_program "$program"
    done
    uninstall_docker
    remove_directories
    sudo apt-get autoremove -y &> /dev/null
    sudo apt-get autoclean -y &> /dev/null
    remove_no_passwd
    echo -e "\n$(color "Uninstallation complete." "32")"
}

main
