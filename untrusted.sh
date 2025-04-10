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
function spinner() {
    local spinners=("/" "-" '\\' "|")
    local delay=0.1  
    local pid=$1 
    local message=$2    
    while kill -0 "$pid" &> /dev/null; do
        for char in "${spinners[@]}"; do
            echo -ne "\r[ $(color "$char" "32") ] $2"
            sleep "$delay"
        done
    done
    echo -e "\r$(printf '%*s' ${COLUMNS:-$(tput cols)} '')"
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
    elif [ $# -eq 4 ]; then
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
    elif [[ $# -eq 4 && $4 -eq "left" ]]; then
        padding=$(( (74 - len) / 2 ))
        left_padding=$(generate_padding $padding)
        echo
        echo -e "\e[$1m=======================================================================\e[0m"
        echo
        echo -e "${left_padding}\e[$2m${message}\e[0m"
        echo
        echo -e "\e[$1m=======================================================================\e[0m"
    fi
}
function errorMaker() {
    local error_message="$1"

    if [ $? -ne 0 ]; then
        echo -e "\r[ $(color "Error" "31") ] $error_message"
        exit 1
    fi
}


function requirement() {
    if [ "$(id -u)" != 0 ]; then
        return 0
    else
        return 1
    fi
}
check_dependencies() {
    local dependencies=("sudo" "tee" "curl")
    for dep in "${dependencies[@]}"; do
        if ! is_installed "$dep" &> /dev/null; then
            messages "31" "Dépendance manquante : $dep"
            return 1
        fi
    done
}

function updater() {
    function handle_error() {
        local code="$1"
        local message="$2"
        case "$code" in
            1)
                echo -e "\r[ $(color "Error" "31") ] Échec de la mise à jour de la cache des paquets."
                ;;
            2)
                echo -e "\r[ $(color "Error" "31") ] Échec de la mise à jour des paquets."
                ;;
            3)
                echo -e "\r[ $(color "Error" "31") ] Gestionnaire de paquets introuvable."
                ;;
            *)
                echo -e "\r[ $(color "Error" "31") ] $message"
                ;;
        esac
        exit 1
    }

    function handle_success() {
        echo -ne "\r$(printf '%*s' ${COLUMNS:-$(tput cols)} '')"
        echo -e "\r[ $(color "OK" "32") ] $(color "$1" "32")"
    }

    # Verificar si el gestor de paquetes existe
    if command -v apt-get &> /dev/null; then
        sudo DEBIAN_FRONTEND=noninteractive apt-get update &> /dev/null || handle_error 1 "Échec de la mise à jour de la cache des paquets."
        sudo DEBIAN_FRONTEND=noninteractive apt-get -yq full-upgrade &> /dev/null || handle_error 2 "Échec de la mise à jour des paquets."
    elif command -v dnf &> /dev/null; then
        sudo dnf makecache --quiet || handle_error 1 "Échec de la mise à jour de la cache des paquets."
        sudo dnf -y upgrade || handle_error 2 "Échec de la mise à jour des paquets."
    elif command -v yum &> /dev/null; then
        sudo yum makecache fast --quiet || handle_error 1 "Échec de la mise à jour de la cache des paquets."
        sudo yum -y update || handle_error 2 "Échec de la mise à jour des paquets."
    elif command -v zypper &> /dev/null; then
        sudo zypper --non-interactive refresh || handle_error 1 "Échec de la mise à jour de la cache des paquets."
        sudo zypper --non-interactive update || handle_error 2 "Échec de la mise à jour des paquets."
    elif command -v pacman &> /dev/null; then
        sudo pacman -Syu --noconfirm || handle_error 2 "Échec de la mise à jour des paquets."
    elif command -v microdnf &> /dev/null; then
        sudo microdnf update -y || handle_error 2 "Échec de la mise à jour des paquets."
    else
        handle_error 3 "Gestionnaire de paquets introuvable."
    fi
    handle_success "Mise à jour du système terminée."
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
function finished() {
    echo
    color '

         _______ .__   __.  __    _______ .___  ___.      ___      
        |   ____||  \ |  | |  |  /  _____||   \/   |     /   \     
        |  |__   |   \|  | |  | |  |  __  |  \  /  |    /  ^  \    
        |   __|  |  . `  | |  | |  | |_ | |  |\/|  |   /  /_\  \   
        |  |____ |  |\   | |  | |  |__| | |  |  |  |  /  _____  \  
        |_______||__| \__| |__|  \______| |__|  |__| /__/     \__\ 
                                                                

    ' "36"
    messages "46" "36" "Installation Complète : $(echo -ne $(color "v1.0" "32"))" "left"
    echo
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
function is_installedByDocker() {
    local program="$1"
    if docker ps -a --format "{{.Names}}" | grep -wq "$program" &> /dev/null; then
        echo -e "[ $(color "OK" "32") ] $(color "$program" "32") est installé (via $(color "Docker" "34"))"
        return 0
        
    else
        return 1
    fi
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
    sudo DEBIAN_FRONTEND=noninteractive apt remove -y --purge docker docker-engine docker.io containerd runc &> /dev/null
    sudo apt autoremove &> /dev/null
    sudo rm -rf /etc/apt/sources.list.d/docker.list
    sudo rm -rf /etc/apt/keyrings/docker.asc

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

    # Configurar el grupo Docker
    echo -e -n "\r[ .. ] Configuration du groupe Docker..."
    sudo usermod -aG docker "$(whoami)" &> /dev/null
    if [ $? -ne 0]; then
        echo -e "\r[ $(color "OK" "32") ] Groupe Docker configuré avec succès."

    else
        echo -e "\r[ $(color "Error" "31") ] Échec de la configuration du groupe Docker."
        return 1
    fi
    return 0
}

# ============================================================================== #
#                                  Functions des SIO                             #
# ============================================================================== #


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
function packageByDocker(){
    # spiderfoot
    echo -ne "\r[ $(color "..." "32") ] Installation de $(color "spiderfoot" "32") via Docker..."
    if ! [ -d "$HOME/spiderfoot" ];then
        git clone https://github.com/smicallef/spiderfoot.git "$HOME/spiderfoot" &> /dev/null
        errorMaker "Impossible de cloner le dépôt Spiderfoot"
    fi
    if ! is_installedByDocker "spiderfoot"; then
        cd "$HOME/spiderfoot" && docker compose up -d > /dev/null 2>&1
        errorMaker "Impossible de lancer le conteneur Spiderfoot"
    fi
    echo -ne "\r$(printf '%*s' ${COLUMNS:-$(tput cols)} '')"
    echo -e "\r[ $(color "OK" "32") ] $(color "spiderfoot" "32") installé avec succès via Docker."

    # DVWA
    echo -ne "\r[ $(color "..." "32") ] Installation de $(color "DVWA" "32") via Docker..."
    if ! [ -d "$HOME/DVWA" ];then
        git clone https://github.com/digininja/DVWA.git "$HOME/DVWA" &> /dev/null
        errorMaker "Impossible de cloner le dépôt DVWA"
    fi
    if ! is_installedByDocker "dvwa-dvwa-1"; then
        cd "$HOME/DVWA" && docker compose up -d > /dev/null 2>&1
        errorMaker "Impossible de lancer le conteneur DVWA"
    fi
    echo -ne "\r$(printf '%*s' ${COLUMNS:-$(tput cols)} '')"
    echo -e "\r[ $(color "OK" "32") ] $(color "DVWA" "32") installé avec succès via Docker."

    
}

# ============================================================================== #
#                                   MAIN FUNCTION                                #
# ============================================================================== #
function main() {
    if ! requirement; then
        messages "31" "Le script ne doit pas être exécuté en tant que root !"
        return 1

    fi
    if ! check_dependencies; then
        return 1
    fi


    SCRIPT_DIR=$(dirname "$(realpath "$0")")
    copyScript="$HOME/subshell.sh"
    SCRIPT_NAME=$(basename "$0")
    cp "$SCRIPT_DIR/$SCRIPT_NAME" "$copyScript"
    chmod +x "$copyScript"


    passwd
    no_passwd
    updater &
    updater_pid=$!
    spinner "$updater_pid" "Mise a jour du systeme..."
    clear
    install_program ca-certificates curl
    
    # ================================== #
    #   Installation de Docker           #

    install_docker 
    newgrp docker <<EOF
source $HOME/subshell.sh
if docker info &> /dev/null; then
    echo -e "[ $(color "OK" "32") ] Docker fonctionne sans privilèges sudo."
else
    echo -e "[ $(color "Error" "31") ] Docker nécessite encore sudo. Redémarrez votre session."
    exit 1
fi
echo -e "\r[ $(color "OK" "32") ] Docker installé avec succès."

packageByDocker

# ================================== #

EOF
    sudo DEBIAN_FRONTEND=noninteractive apt -y autoremove
    rm -f "$HOME/subshell.sh"
    clear
    package
    trap "rm -f $copyScript; sudo DEBIAN_FRONTEND=noninteractive apt -y autoremove" EXIT
    finished
    
}
function test(){
    sleep 10
}
test &
test_pid=$!
spinner "$test_pid" "Test en cours..."

