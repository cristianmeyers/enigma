#!/bin/bash

clear

function color() {
    local text="$1"
    local color_code="$2"
    echo -e "\e[${color_code}m${text}\e[0m"
}

function messages() {
    if [ $# -eq 2 ]; then
        echo -e "\e[$1m=======================================================================\e[0m"
        echo -e "\e[$1m                                                                       \e[0m"
        echo -e "\e[$1m                   $2                                                  \e[0m"
        echo -e "\e[$1m                                                                       \e[0m"
        echo -e "\e[$1m=======================================================================\e[0m"
    elif [ $# -eq 3 ]; then
        echo -e "\e[$1m=======================================================================\e[0m"
        echo -e "\e[$1m                                                                       \e[0m"
        echo -e "\e[$2m                   $3                                                  \e[0m"
        echo -e "\e[$1m                                                                       \e[0m"
        echo -e "\e[$1m=======================================================================\e[0m"
    fi
}

function requirement() {
    if [ "$(id -u)" != 0 ]; then
        return 0
    else
        return 1
    fi
}

function updater() {
    function handle_error() {
        if [ $1 -eq 1 ]; then
            echo "$(color "Erreur:" "31") Echec de la mise à jour de la cache des packets." >&2
        elif [ $1 -eq 2 ]; then
            echo "$(color "Erreur:" "31") Echec de la mise à jour des packets." >&2
        elif [ $1 -eq 3 ]; then
            echo "$(color "Erreur:" "31") Gestionnaire de packets introuvable" >&2
        else
            echo "$(color "Erreur:" "31") $2" >&2
        fi
        exit 1
    }

    if command -v apt-get &> /dev/null; then
        sudo DEBIAN_FRONTEND=noninteractive apt-get update &> /dev/null || handle_error 1
        sudo DEBIAN_FRONTEND=noninteractive apt-get -yq full-upgrade &> /dev/null || handle_error 2
    elif command -v dnf &> /dev/null; then
        sudo dnf makecache --quiet || handle_error 1
        sudo dnf -y upgrade || handle_error 2
    elif command -v yum &> /dev/null; then
        sudo yum makecache fast --quiet || handle_error 1
        sudo yum -y update || handle_error 2
    elif command -v zypper &> /dev/null; then
        sudo zypper --non-interactive refresh || handle_error 1
        sudo zypper --non-interactive update || handle_error 2
    elif command -v pacman &> /dev/null; then
        sudo pacman -Syu --noconfirm || handle_error 2
    elif command -v microdnf &> /dev/null; then
        sudo microdnf update -y || handle_error 2
    else
        handle_error 3
    fi
}

function get_distro() {
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        echo "$ID_LIKE"
    else
        echo "unknown"
    fi
}

function passwd() {
    PASSWORD_FILE="$HOME/.password"

    if [ -f "$PASSWORD_FILE" ]; then
        export PASSWORD=$(cat "$PASSWORD_FILE")
    else
        read -s -p "$(color "Entrez votre mot de passe sudo : " "96")" PASSWORD
        echo

        if echo "$PASSWORD" | sudo -S -v &> /dev/null; then
            echo "$PASSWORD" > "$PASSWORD_FILE"
            chmod 600 "$PASSWORD_FILE"
            export PASSWORD
            echo "[$(color "Ok" "32")] Mot de passe sauvegardé dans $PASSWORD_FILE."
        else
            echo "$(color "[Error]" "31") Erreur d'authentification."
            exit 1
        fi
    fi
}

function no_passwd() {
    local USER=$(whoami)

    if printf "%s\n" "$PASSWORD" | sudo -S cat /etc/sudoers | grep -q "^$USER.*ALL=(ALL).*NOPASSWD: ALL"; then
        echo "[$(color "Ok" "32")] $USER possède déjà les privilèges sudo sans mot de passe."
    else
        printf "%s\n" "$PASSWORD" | sudo -S bash -c "echo '$USER ALL=(ALL) NOPASSWD: ALL' | tee -a /etc/sudoers > /dev/null"
        if [ $? -eq 0 ]; then
            echo "[$(color "Ok" "32")] L'utilisateur $(color "$USER" "32") n'a plus besoin d'utiliser le mot de passe."
        else
            echo "$(color "[Error]" "31") Modification Visudo échouée."
        fi
    fi
}

function is_installed() {
    local program="$1"

    if command -v "$program" &> /dev/null; then
        echo "[$(color "Ok" "32")] $(color "$program" "32" ) est installé (via PATH)"
        return 0
    fi

    if dpkg-query -W -f='${Status}' "$program" 2>/dev/null | grep -q "ok installed"; then
        echo "[$(color "Ok" "32")] $(color "$program" "32" ) est installé (via dpkg)"
        return 0
    fi

    if snap list 2>/dev/null | grep -qw "$program"; then
        echo "[$(color "Ok" "32")] $(color "$program" "32" ) est installé (via Snap)"
        return 0
    fi

    if flatpak list 2>/dev/null | grep -qw "$program"; then
        echo "[$(color "Ok" "32")] $(color "$program" "32" ) est installé (via Flatpak)"
        return 0
    fi

    if find /home/$USER -name "*$program*.AppImage" -exec test -x {} \; -print -quit 2>/dev/null | grep -q .; then
        echo "[$(color "Ok" "32")] $(color "$program" "32" ) est installé (via AppImage)"
        return 0
    fi

    return 1
}

function install_program() {
    local program="$1"

    if is_installed "$program"; then
        return 0
    fi

    echo -e -n "\r[ .. ] Installation de $program..."

    if command -v apt-get &> /dev/null; then
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$program" &> /dev/null
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y "$program" &> /dev/null
    elif command -v yum &> /dev/null; then
        sudo yum install -y "$program" &> /dev/null
    elif command -v zypper &> /dev/null; then
        sudo zypper --non-interactive install "$program" &> /dev/null
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm "$program" &> /dev/null
    elif command -v microdnf &> /dev/null; then
        sudo microdnf install "$program" -y &> /dev/null
    else
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] Gestionnaire de paquets inconnu ou non trouvé."
        return 2
    fi

    if is_installed "$program"; then
        echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] $program installé avec succès."
        return 0
    else
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] Échec de l'installation de $program."
        return 1
    fi
}

function install_docker() {
    echo -e -n "\r[ .. ] Installation de Docker..."

    # Detectar el gestor de paquetes y realizar la instalación correspondiente
    if command -v apt-get &> /dev/null; then
        # Instalar dependencias necesarias
        sudo apt-get update -y &> /dev/null
        sudo apt-get install -y ca-certificates curl gnupg &> /dev/null

        # Agregar la clave GPG oficial de Docker
        if ! sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg &> /dev/null; then
            echo -e "\r[ $(color "NOK" "31") ] Échec de l'ajout de la clé GPG Docker."
            return 1
        fi

        # Configurar el repositorio oficial de Docker
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Actualizar los repositorios e instalar Docker
        sudo apt-get update -y &> /dev/null
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras &> /dev/null

    elif command -v dnf &> /dev/null; then
        sudo dnf -y install dnf-plugins-core &> /dev/null
        sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo &> /dev/null
        sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin &> /dev/null

    elif command -v yum &> /dev/null; then
        sudo yum install -y yum-utils &> /dev/null
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo &> /dev/null
        sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin &> /dev/null

    elif command -v zypper &> /dev/null; then
        sudo zypper refresh &> /dev/null
        sudo zypper install -y docker &> /dev/null

    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm docker &> /dev/null

    elif command -v microdnf &> /dev/null; then
        sudo microdnf install -y docker &> /dev/null

    else
        echo -e "\r[ $(color "NOK" "31") ] Gestionnaire de paquets inconnu ou non pris en charge."
        return 1
    fi

    # Verificar si Docker está instalado
    if ! command -v docker &> /dev/null; then
        echo -e "\r[ $(color "NOK" "31") ] Échec de l'installation de Docker."
        return 1
    fi

    echo -e "\r[ $(color "OK" "32") ] Docker installé avec succès."

    # Configurar el grupo Docker
    echo -e -n "\r[ .. ] Configuration du groupe Docker..."
    if sudo usermod -aG docker "$(whoami)" &> /dev/null; then
        echo -e "\r[ $(color "OK" "32") ] Groupe Docker configuré avec succès."
        sg docker -c "echo 'Commande exécutée dans le contexte du groupe Docker.'"
    else
        echo -e "\r[ $(color "ERREUR" "31") ] Échec de la configuration du groupe Docker."
        return 1
    fi

    # Verificar si Docker funciona sin sudo
    if docker info &> /dev/null; then
        echo -e "[ $(color "OK" "32") ] Docker fonctionne sans privilèges sudo."
    else
        echo -e "[ $(color "NOK" "31") ] Docker nécessite encore sudo. Redémarrez votre session."
    fi

    return 0
}

function main() {
    updater

    if ! requirement; then
        messages "31" "Le script ne doit pas être exécuté en tant que root !"
        return 1
    elif ! is_installed "sudo"; then
        messages "31" "Dépendance manquante : sudo"
        return 1
    elif ! is_installed "tee"; then
        messages "31" "Dépendance manquante : tee"
        return 1
    fi
    
    passwd
    no_passwd
    clear
    install_program ca-certificates
    install_program curl
    install_docker
    sudo DEBIAN_FRONTEND=noninteractive apt -y autoremove
    
}

main