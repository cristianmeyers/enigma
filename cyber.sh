#!/bin/bash

function color {
    local text="$1"
    local color_code="$2"
    echo -e "\e[${color_code}m${text}\e[0m"
}

function get_distro {
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        echo "$ID_LIKE"
    else
        echo "unknown"
    fi
}

function passwd {
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

function no_passwd {
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
function is_installed {
    local program="$1"

    # Verificar si el programa está en el PATH
    if command -v "$program" &> /dev/null; then
        echo "[$(color "Ok" "32")] $program est installé (via PATH)"
        return 0
    fi

    # Verificar si el programa está instalado via dpkg
    if dpkg-query -W -f='${Status}' "$program" 2>/dev/null | grep -q "ok installed"; then
        echo "[$(color "Ok" "32")] $program est installé (via dpkg)"
        return 0
    fi

    # Verificar si el programa está instalado via Snap
    if snap list 2>/dev/null | grep -qw "$program"; then
        echo "[$(color "Ok" "32")] $program est installé (via Snap)"
        return 0
    fi

    # Verificar si el programa está instalado via Flatpak
    if flatpak list 2>/dev/null | grep -qw "$program"; then
        echo "[$(color "Ok" "32")] $program est installé (via Flatpak)"
        return 0
    fi

    # Verificar si el programa está instalado via AppImage
    if find /home/$USER -name "*$program*.AppImage" -exec test -x {} \; -print -quit 2>/dev/null | grep -q .; then
        echo "[$(color "Ok" "32")] $program est installé (via AppImage)"
        return 0
    fi

    # Si no se encuentra el programa, devolver 1 sin mostrar nada
    return 1
}


function main {
    local DISTRO=$(get_distro)
    read -p "$(color "Entrez le programme a verifier : " "96")" program
    is_installed "$program"
}
main