#!/bin/bash

# DISTRO_ID_LIKE=$(get_distro)
function get_distro {
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        echo "$ID_LIKE"
    else
        echo "unknown"
    fi
    
}

function no_passwd {
    local USER=$(whoami)

    if sudo grep -q "^$USER.*ALL=(ALL).*NOPASSWD: ALL" /etc/sudoers; then
        echo "[$(color "Ok" "32")] $USER possède déjà les privilèges sudo sans mot de passe."
    else
        echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers > /dev/null
        if [ $? -eq 0 ]; then
            echo "[$(color "Ok" "32")] Lutilisateur $(color "$USER" "32") n'a plus besoin d'utiliser le mot de passe."
        else
            echo "$(color "[Error]" "31") modification Visudo échouée."
        fi
    fi
}


function color {
    local text="$1"
    local color_code="$2"
    echo -e "\e[${color_code}m${text}\e[0m"
}

function is_installed {
    local program="$1"

    if command -v "$program" &> /dev/null; then
        echo "[$(color "Ok" "32")] $program est installé (via PATH)"
        return 0
    fi

    if dpkg-query -W -f='${Status}' "$program" 2>/dev/null | grep -q "ok installed"; then
        echo "[$(color "Ok" "32")] $program est installé (via dpkg)"
        return 0
    fi

    if snap list | grep -qw "$program"; then
        echo "[$(color "Ok" "32")] $program est installé (via Snap)"
        return 0
    fi

    if flatpak list | grep -qw "$program"; then
        echo "[$(color "Ok" "32")] $program est installé (via Flatpak)"
        return 0
    fi

    if find /home/$USER -name "*$program*.AppImage" -exec test -x {} \; -print -quit | grep -q .; then
        echo "[$(color "Ok" "32")] $program est installé (via AppImage)"
        return 0
    fi

    echo "$(color "[Error]" "31") $program n'est pas installé."
    return 1
}

function PASSWORD {
    read -s -p "$(color "Entrez votre mot de passe sudo " "96")" PASSWORD
    if echo "$PASSWORD" | sudo -S -v &> /dev/null; then
        echo "$PASSWORD" > /home/$USER/.password
        chmod 600 /home/$USER/.password
    else
        echo "$(color "[Error]" "31") Erreur d'authentification."
    fi

}
