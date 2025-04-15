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
    local dependencies=("sudo" "tee")
    for dep in "${dependencies[@]}"; do
        if ! is_installed "$dep" &> /dev/null; then
            messages "31" "Dépendance manquante : $(color "$dep" "33")"
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
    messages "46" "36" "Installation Complète : $(echo -ne $(color "v1.1" "32"))" "left"
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
                echo -e "\r[ $(color "OK" "32") ] $(color "$program" "32") installé avec succès."
            else
                echo -ne "\r$(printf '%*s' ${COLUMNS:-$(tput cols)} '')"
                echo -e "\r[ $(color "Error" "31") ] Échec de l'installation de $(color "$program" "36")."
                success=false
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

    # Crear directorio para claves GPG
    sudo install -m 0755 -d /etc/apt/keyrings/docker.asc

    # Descargar clave GPG
    if ! sudo curl --max-time 40 -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc; then
        echo -e "\r[ $(color "Error" "31") ] Échec de l'ajout de la clé GPG Docker."
        return 1
    fi
    if [ -f /etc/apt/keyrings/docker.asc ]; then
        sudo chmod a+r /etc/apt/keyrings/docker.asc
    else
        echo -e "\r[ $(color "Error" "31") ] La clé GPG Docker n'a pas été téléchargée."
        return 1
    fi
    sudo bash -c "cat > /etc/apt/sources.list.d/docker.list <<dockerconf
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable
dockerconf"
    sudo apt update -y &> /dev/null
    errorMaker "Échec de la mise à jour de la liste des paquets."
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
    curl -fsSL "https://get.docker.com/" | sh
    sudo usermod -aG docker $(id -u -n)
    newgrp docker

    echo -e "\r[ $(color "OK" "32") ] Docker installé avec succès."
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
    )

    for program in "${programs[@]}"; do
        install_program "$program"
    done
}
# ============================================================================== #
#                                   Package Docker                               #
# ============================================================================== #

function packageByDocker(){
    # ========================== spiderfoot
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

    # =========================== DVWA
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
    echo -e "\r[ $(color "OK" "32") ] $(color "DVWA" "32") installé avec succès Par Jérémy"

    # =========================== Sysreptor
    echo -ne "\r[ $(color "..." "32") ] Installation de $(color "Sysreptor" "32")..."
    if ! is_installedByDocker "sysreptor-app"; then
        if ! curl -fsSL https://docs.sysreptor.com/install.sh -o get-sysreptor.sh > /dev/null 2>&1; then
            echo -e "\r[ $(color 'Errror' '31') ] Échec du téléchargement du script $(color "Sysreptor" "32") !"
            exit 1
        fi
        cat << 'sysrep' >> get-sysreptor.sh

if [ -z "$SYSREPTOR_CADDY_FQDN" ]; then
    echo "URL: http://127.0.0.1:$SYSREPTOR_CADDY_PORT" > ~/sysreptor-credential.txt
else
    echo "URL: http://$SYSREPTOR_CADDY_FQDN:$SYSREPTOR_CADDY_PORT" > ~/sysreptor-credential.txt
fi
echo "Username: reptor" >> ~/sysreptor-credential.txt
echo "Password: $password" >> ~/sysreptor-credential.txt
sysrep
        # Reponses d'avance, les espaces vides representent "Enter"
        bash get-sysreptor.sh << repsysreptor

y
y
y
y

localhost
y
y
repsysreptor

        errorMaker "Impossible de lancer $(color "Sysreptor" "33")"
        echo -ne "\r$(printf '%*s' ${COLUMNS:-$(tput cols)} '')"
        echo -e "\r[ $(color "OK" "32") ] $(color "Sysreptor" "32") installé avec succès Par Vincent."
    
    fi
    # =========================== Nessus
    echo -ne "\r[ $(color "..." "32") ] Installation de $(color "Nessus" "32")..."
    if ! is_installedByDocker "nessus-managed"; then
        docker pull tenable/nessus:latest-oracle &> /dev/null
        errorMaker "Impossible de télécharger l'image Nessus"
        docker run --name "nessus-managed" -d -p 127.0.0.1:8834:8834 tenable/nessus:latest-oracle &> /dev/null
        errorMaker "Impossible de lancer le conteneur Nessus"
    fi
    echo -ne "\r$(printf '%*s' ${COLUMNS:-$(tput cols)} '')"
    echo -e "\r[ $(color "OK" "32") ] $(color "Nessus" "32") installé avec succès Par Vincent."

    
}
# ============================================================================== #
#                                   Package Python                               #
# ============================================================================== #
function packageByPython(){
    programs=(
        python3
        python3-argcomplete
        python3-pip
        python3-full
        pipx
    )
    for program in "${programs[@]}"; do
        install_program "$program"
    done
    # =========================== configuration de python3
    echo -ne "\r[ $(color "..." "32") ] Configuration de $(color "python3" "32")..."
    if ! [ -f /usr/local/share/.venv/bin/activate ]; then
        sudo python3 -m venv /usr/local/share/.venv &> /dev/null
        errorMaker "Impossible de créer l'environnement virtuel python3"
        sudo bash -c 'cat << pythonconf > /etc/profile.d/python3.sh
#!/bin/sh
if [ -f /usr/local/share/.venv/bin/activate ]; then
    source /usr/local/share/.venv/bin/activate
fi
pythonconf'

        source /etc/profile.d/python3.sh
        errorMaker "Impossible de créer le fichier de configuration bashrc"
        if ! sudo grep -q '^Defaults\s+secure_path=".*:/usr/local/share/.venv/bin.*"' /etc/sudoers; then
            sudo sed -E -i "s|(^Defaults\s+secure_path=\"[^\"]*)\"|\1:/usr/local/share/.venv/bin\"|" /etc/sudoers
            errorMaker "Impossible de modifier le fichier sudoers"
        fi
    fi
    echo -ne "\r$(printf '%*s' ${COLUMNS:-$(tput cols)} '')"
    echo -e "\r[ $(color "OK" "32") ] $(color "python3" "32") configuré avec succès."

    # =========================== SEToolKit

    echo -ne "\r[ $(color "..." "32") ] Installation de $(color "SEToolKit" "32") via Python..."
    if ! is_installedByDocker "setoolkit"; then
        git clone https://github.com/trustedsec/social-engineer-toolkit/ $HOME/setoolkit/ &> /dev/null
        errorMaker "Impossible de cloner le dépôt SEToolKit"
        cd $HOME/setoolkit && sudo pip3 install -r requirements.txt > /dev/null 2>&1
        errorMaker "Impossible d'installer les dépendances de SEToolKit"
        sudo python3 setup.py > /dev/null 2>&1
        cd $HOME
        echo -ne "\r$(printf '%*s' ${COLUMNS:-$(tput cols)} '')"
        echo -e "\r[ $(color "OK" "32") ] $(color "SEToolKit" "32") installé avec succès."
    fi
    echo -ne "\r$(printf '%*s' ${COLUMNS:-$(tput cols)} '')"
    echo -e "\r[ $(color "OK" "32") ] $(color "SEToolKit" "32") installé avec succès."
    
    # =========================== Exegol
    # ============= Vérification de pipx
    if ! command -v pipx &> /dev/null; then
        echo "$(color '...' '33') pipx n'est pas installé. Installation en cours..."
        python3 -m pip install --user pipx
        python3 -m pipx ensurepath
        errorMaker "Impossible d'installer pipx"
    fi

    # =========================== Installation d'Exegol
    echo -ne "\r[ $(color '...' '32') ] Installation de $(color 'Exegol' '32') via pipx..."
    pipx install exegol --force > /dev/null 2>&1
    errorMaker "Impossible d'installer Exegol"

    # =========================== Configuration de l'alias Exegol
    if ! grep -q "alias exegol=" ~/.bash_aliases 2>/dev/null; then
        echo "alias exegol='sudo -E $(which exegol)'" >> ~/.bash_aliases
        errorMaker "Impossible de créer l'alias exegol"
        source ~/.bash_aliases || echo "Redémarrez votre terminal pour activer l'alias $(color "Exegol" "32")."
    fi
    echo -e "\r[ $(color 'OK' '32') ] $(color 'Exegol' '32') installé avec succès."

        
}



# ============================================================================== #
#                                   Package Snap                                 #
# ============================================================================== #
function packageBySnap(){
    # =========================== Metasploit
    echo -ne "\r[ $(color "..." "32") ] Installation de $(color "Metasploit" "32") via Snap..."
    if ! is_installedByDocker "metasploit-framework"; then
        sudo snap install metasploit-framework > /dev/null 2>&1
        errorMaker "Impossible de lancer le conteneur Metasploit"
    fi
    echo -ne "\r$(printf '%*s' ${COLUMNS:-$(tput cols)} '')"
    echo -e "\r[ $(color "OK" "32") ] $(color "Metasploit" "32") installé avec succès."
}






# ============================================================================== #
#                                   MAIN FUNCTION                                #
# ============================================================================== #
function main() {
    # Verificar requisitos
    if ! requirement; then
        messages "31" "Le script ne doit pas être exécuté en tant que root !"
        return 1
    fi

    # Configurar contraseña y permisos sudo
    passwd
    no_passwd

    # Actualizar el sistema
    updater &
    updater_pid=$!
    spinner "$updater_pid" "Mise à jour du système..."
    wait "$updater_pid"
    if [ $? -ne 0 ]; then
        echo -e "\r[ $(color "Error" "31") ] Échec de la mise à jour du système."
        exit 1
    fi

    # Instalar dependencias básicas
    install_program ca-certificates curl
    if ! check_dependencies; then
        exit 1
    fi

    # Instalar Docker
    install_docker
    errorMaker "Échec de l'installation de Docker."


    # Verificar que Docker funcione sin sudo
    if ! docker info &> /dev/null; then
        echo -e "\r[ $(color "Error" "31") ] Docker nécessite encore sudo. Redémarrez votre session."
        exit 1
    fi

    # Instalar herramientas adicionales
    #packageByDocker
    #package

    # Limpiar paquetes innecesarios
    sudo DEBIAN_FRONTEND=noninteractive apt -y autoremove

    # Finalizar
    finished
}
main