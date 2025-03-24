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
        echo "[$(color "Ok" "32")] Mot de passe chargé depuis $PASSWORD_FILE."
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

passwd
no_passwd