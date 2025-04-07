#!/bin/bash

clear

# ============================================================================== #
#                                   Functions                                    #
# ============================================================================== #

function color() {
    local text="$1"
    local color_code="$2"
    echo -e "\e[${color_code}m${text}\e[0m"
}

function messages() {
    local len
    local padding

    if [ $# -eq 2 ]; then
        len=${#2}
        message="$2"
    elif [ $# -eq 3 ]; then
        len=${#3}
        message="$3"
    fi

    local cols=${COLUMNS:-$(tput cols)} 
    padding=$(( (cols - len) / 2 ))

    generate_padding() {
        printf "%*s" "$1" ""
    }

    left_padding=$(generate_padding $padding)

    if [ $# -eq 2 ]; then
        echo
        echo -e "$(generate_padding $(( (cols - 74) / 2 )))\e[$1m=======================================================================\e[0m"
        echo
        echo -e "${left_padding}\e[$1m${message}\e[0m"
        echo
        echo -e "$(generate_padding $(( (cols - 74) / 2 )))\e[$1m=======================================================================\e[0m"
    elif [ $# -eq 3 ]; then
        echo
        echo -e "$(generate_padding $(( (cols - 74) / 2 )))\e[$1m=======================================================================\e[0m"
        echo
        echo -e "${left_padding}\e[$2m${message}\e[0m"
        echo
        echo -e "$(generate_padding $(( (cols - 74) / 2 )))\e[$1m=======================================================================\e[0m"
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
    
    echo -e "[ $(color "..." "32") ] Mise à jour du systeme..."
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
    local distro="unknown"
    local package_manager="unknown"

    if [ -f /etc/os-release ]; then
        source /etc/os-release
        distro="$ID_LIKE"
    fi


    if command -v apt-get &> /dev/null; then
        package_manager="apt-get"
    elif command -v dnf &> /dev/null; then
        package_manager="dnf"
    elif command -v yum &> /dev/null; then
        package_manager="yum"
    elif command -v zypper &> /dev/null; then
        package_manager="zypper"
    elif command -v pacman &> /dev/null; then
        package_manager="pacman"
    elif command -v microdnf &> /dev/null; then
        package_manager="microdnf"
    fi

    echo "Distro: $(color "$distro" "36"), Package Manager: $(color "$package_manager" "32")"
}

function passwd() {
    PASSWORD_FILE="$HOME/.password"

    if [ -f "$PASSWORD_FILE" ]; then
        export PASSWORD=$(cat "$PASSWORD_FILE")
    else
        read -s -p "$(color "Entrez votre mot de passe sudo : " "32")" PASSWORD
        echo
    clear
        if echo "$PASSWORD" | sudo -S -v &> /dev/null; then
            echo "$PASSWORD" > "$PASSWORD_FILE"
            chmod 600 "$PASSWORD_FILE"
            export PASSWORD
            echo "[ $(color "OK" "32") ] Mot de passe sauvegardé dans $PASSWORD_FILE."
        else
            echo "[ $(color "Error" "31") ] Erreur d'authentification."
            exit 1
        fi
    fi
}

function no_passwd() {
    local USER=$(whoami)

    if printf "%s\n" "$PASSWORD" | sudo -S cat /etc/sudoers | grep -q "^$USER.*ALL=(ALL).*NOPASSWD: ALL"; then
        echo "[ $(color "OK" "32") ] $USER possède déjà les privilèges sudo sans mot de passe."
    else
        printf "%s\n" "$PASSWORD" | sudo -S bash -c "echo '$USER ALL=(ALL) NOPASSWD: ALL' | tee -a /etc/sudoers > /dev/null"
        if [ $? -eq 0 ]; then
            echo "[ $(color "OK" "32") ] L'utilisateur $(color "$USER" "32") n'a plus besoin d'utiliser le mot de passe."
        else
            echo "[ $(color "Error" "31") ] Modification Visudo échouée."
        fi
    fi
}

function is_installed() {
    local program="$1"

    if command -v "$program" &> /dev/null; then
        echo "[ $(color "OK" "32") ] $(color "$program" "32" ) est installé (via $(color "PATH" "34"))"
        return 0
    fi

    if dpkg-query -W -f='${Status}' "$program" 2>/dev/null | grep -q "ok installed"; then
        echo "[ $(color "OK" "32") ] $(color "$program" "32" ) est installé (via $(color  "dpkg" "34"))"
        return 0
    fi

    if snap list 2>/dev/null | grep -qw "$program"; then
        echo "[ $(color "OK" "32") ] $(color "$program" "32" ) est installé (via $(color "Snap" "34"))"
        return 0
    fi

    if flatpak list 2>/dev/null | grep -qw "$program"; then
        echo "[ $(color "OK" "32") ] $(color "$program" "32" ) est installé (via $(color "Flatpak" "34"))"
        return 0
    fi

    if find /home/$USER -name "*$program*.AppImage" -exec test -x {} \; -print -quit 2>/dev/null | grep -q .; then
        echo "[ $(color "OK" "32") ] $(color "$program" "32" ) est installé (via $(color "AppImage" "34"))"
        return 0
    fi

    return 1
}

function install_program() {
    local success=true

    for program in "$@"; do
        if ! is_installed "$program"; then
            echo -ne "\r$(printf '%*s' ${COLUMNS:-$(tput cols)} '')"
            echo -ne "\r[ $(color "..." "32") ] Installation de $(color "$program" "32")..."

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
                echo -e "\r[ $(color "Error" "31") ] Gestionnaire de paquets n'a pas trouvé $(color "$program" "36")."
                echo
                success=false
                continue 
             fi
             #Once installed
            if [[ $? -eq 0 ]]; then
                echo -ne "\r$(printf '%*s' ${COLUMNS:-$(tput cols)} '')"
                echo -ne "\r[ $(color "OK" "32") ] $(color "$program" "32") installé avec succès."
                echo
            else
                echo -ne "\r$(printf '%*s' ${COLUMNS:-$(tput cols)} '')"
                echo -ne "\r[ $(color "Error" "31") ] Échec de l'installation de $(color "$program" "36")."
                success=false
                echo
                continue
            fi
        else
            continue  
        fi
    done

    if $success; then
        return 0
    else
        return 1
    fi
}

function install_docker() {
    echo -e -n "\r[ .. ] Installation de Docker..."


    if command -v apt-get &> /dev/null; then

        # Crear el directorio para las claves GPG
        sudo install -m 0755 -d /etc/apt/keyrings &> /dev/null

        # Descargar la clave GPG oficial de Docker
        if ! sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc &> /dev/null; then
            echo -e "\r[ $(color "Error" "31") ] Échec de l'ajout de la clé GPG Docker."
            return 1
        fi

        # Ajustar permisos de la clave GPG
        sudo chmod a+r /etc/apt/keyrings/docker.asc &> /dev/null

        # Configurar el repositorio oficial de Docker
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Actualizar los repositorios e instalar Docker
        sudo apt-get update -y &> /dev/null
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras &> /dev/null

        # Usar el script oficial de Docker como alternativa adicional
        curl -fsSL "https://get.docker.com/" | sh &> /dev/null
    else
        echo -e "\r[ $(color "Error" "31") ] Gestionnaire de paquets inconnu ou non pris en charge."
        return 1
    fi

    # Verificar si Docker está instalado
    if ! command -v docker &> /dev/null; then
        echo -e "\r[ $(color "Error" "31") ] Échec de l'installation de Docker."
        return 1
    fi

    echo -e "\r[ $(color "OK" "32") ] Docker installé avec succès."

    # Configurar el grupo Docker
    echo -e -n "\r[ .. ] Configuration du groupe Docker..."
    if sudo usermod -aG docker "$(whoami)" &> /dev/null; then
        echo -e "\r[ $(color "OK" "32") ] Groupe Docker configuré avec succès."

        # Cambiar al grupo Docker usando newgrp y luego salir de la subshell
        newgrp docker <<EOF
echo 'Commande exécutée dans le contexte du groupe Docker.'
exit
EOF
    else
        echo -e "\r[ $(color "Error" "31") ] Échec de la configuration du groupe Docker."
        return 1
    fi

    # Verificar si Docker funciona sin sudo
    if docker info &> /dev/null; then
        echo -e "[ $(color "OK" "32") ] Docker fonctionne sans privilèges sudo."
    else
        echo -e "[ $(color "Error" "31") ] Docker nécessite encore sudo. Redémarrez votre session."
    fi

    return 0
}



# ============================================================================== #
#                                   Package suite                                #
# ============================================================================== #

function package() {
    messages "46" "46" "Installation de la suite cyber $(echo -ne $(color "Enigma" "30"))"
    echo;echo
    local programs=(
        nmap
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
        tar
        coreutils
        pipx
    )

    for program in "${programs[@]}"; do
        install_program "$program"
    done
}


# ============================================================================== #
#                                   MAIN FUNCTION                                #
# ============================================================================== #
function main() {
    clear
    if ! requirement; then
        messages "31" "Le script ne doit pas être exécuté en tant que root !"
        return 1
    elif ! is_installed "sudo" &> /dev/null; then
        messages "31" "Dépendance manquante : sudo"
        return 1
    elif ! is_installed "tee" &> /dev/null; then
        messages "31" "Dépendance manquante : tee"
        return 1
    fi
    
    passwd
    no_passwd
    updater
    clear
    install_program ca-certificates curl
    install_docker
    sudo DEBIAN_FRONTEND=noninteractive apt -y autoremove
    clear
    package
    
}

main
