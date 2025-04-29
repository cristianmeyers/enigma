#!/bin/bash

function color() {
    local text="$1"
    local color_code="$2"
    echo -e "\e[${color_code}m${text}\e[0m"
}

function uninstall_program() {
    local program="$1"
    echo -ne "\r[ $(color "..." "32") ] Uninstalling $(color "$program" "32")..."

    if command -v "$program" &> /dev/null || dpkg-query -W -f='${Status}' "$program" 2>/dev/null | grep -q "ok installed"; then
        sudo apt-get remove --purge -y "$program" &> /dev/null
        if [ $? -eq 0 ]; then
            echo -e "\r[ $(color "OK" "32") ] $(color "$program" "32") uninstalled."
        else
            echo -e "\r[ $(color "Error" "31") ] Failed to uninstall $(color "$program" "32")."
        fi
    elif snap list 2>/dev/null | grep -qw "$program"; then
        sudo snap remove "$program" &> /dev/null
        if [ $? -eq 0 ]; then
            echo -e "\r[ $(color "OK" "32") ] $(color "$program" "32") uninstalled (Snap)."
        else
            echo -e "\r[ $(color "Error" "31") ] Failed to uninstall $(color "$program" "32") (Snap)."
        fi
    elif flatpak list 2>/dev/null | grep -qw "$program"; then
        sudo flatpak uninstall -y "$program" &> /dev/null
        if [ $? -eq 0 ]; then
            echo -e "\r[ $(color "OK" "32") ] $(color "$program" "32") uninstalled (Flatpak)."
        else
            echo -e "\r[ $(color "Error" "31") ] Failed to uninstall $(color "$program" "32") (Flatpak)."
        fi
    else
        echo -e "\r[ $(color "OK" "32") ] $(color "$program" "32") is not installed."
    fi
}

function uninstall_docker_containers() {
    echo -ne "\r[ $(color "..." "32") ] Removing Docker containers..."
    if command -v docker &> /dev/null; then
        containers=$(docker ps -a --format "{{.Names}}")
        for container in $containers; do
            docker stop "$container" &> /dev/null
            docker rm "$container" &> /dev/null
            echo -e "\r[ $(color "OK" "32") ] Docker container $(color "$container" "32") removed."
        done
    else
        echo -e "\r[ $(color "OK" "32") ] Docker is not installed."
    fi
}

function uninstall_docker_images() {
    echo -ne "\r[ $(color "..." "32") ] Removing Docker images..."
    if command -v docker &> /dev/null; then
        images=$(docker images -q)
        for image in $images; do
            docker rmi -f "$image" &> /dev/null
            echo -e "\r[ $(color "OK" "32") ] Docker image $(color "$image" "32") removed."
        done
    else
        echo -e "\r[ $(color "OK" "32") ] Docker is not installed."
    fi
}

function remove_directories() {
    local directories=("$HOME/spiderfoot" "$HOME/.password" "$HOME/subshell.sh")
    for dir in "${directories[@]}"; do
        if [ -d "$dir" ] || [ -f "$dir" ]; then
            rm -rf "$dir" &> /dev/null
            echo -e "\r[ $(color "OK" "32") ] Directory/File $(color "$dir" "32") removed."
        else
            echo -e "\r[ $(color "OK" "32") ] Directory/File $(color "$dir" "32") does not exist."
        fi
    done
}
function remove_no_passwd() {
    local USER=$(whoami)
    if sudo grep -q "^$USER.*NOPASSWD: ALL" /etc/sudoers; then
        sudo sed -i "/^$USER.*NOPASSWD: ALL/d" /etc/sudoers
        echo -e "[ $(color "OK" "32") ] No-password setup-conf removed for $(color "$USER" "32")."
    else
        echo -e "[ $(color "OK" "32") ] No-password setup-conf not found for $(color "$USER" "32")."
    fi
}

function main() {
    echo -e "$(color "Starting uninstallation..." "32")\n"

    local programs=(
        ca-certificates 
        curl
        nmap
        sed
        wireshark
        hydra
        sqlmap
        mysql-server
        snapd
        geoip-bin
        sublist3r
        nikto
        dsniff
        hping3
        macchanger
        git
        openssl
        uuid-runtime
        gparted
        tar
        coreutils
        python3
        python3-argcomplete
        python3-pip
        python3-full
        pipx
        )

    for program in "${programs[@]}"; do
        uninstall_program "$program"
    done

    uninstall_docker_containers
    uninstall_docker_images
    sudo apt-get remove --purge -y docker docker-engine docker.io containerd runc &> /dev/null
    echo -e "\r[ $(color "OK" "32") ] Docker uninstalled."

    remove_directories

    sudo apt-get autoremove -y &> /dev/null
    sudo apt-get autoclean -y &> /dev/null
    remove_no_passwd

    echo -e "\n$(color "Uninstallation complete." "32")"
}

main
