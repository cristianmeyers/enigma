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
    if command -v apt-get &> /dev/null; then
        sudo DEBIAN_FRONTEND=noninteractive apt-get update &> /dev/null && sudo DEBIAN_FRONTEND=noninteractive apt-get -yq full-upgrade &> /dev/null
    elif command -v dnf &> /dev/null; then
        sudo dnf makecache --quiet &> /dev/null && sudo dnf -y upgrade &> /dev/null
    elif command -v yum &> /dev/null; then
        sudo yum makecache fast --quiet &> /dev/null && sudo yum -y update &> /dev/null
    elif command -v zypper &> /dev/null; then
        sudo zypper --non-interactive refresh &> /dev/null && sudo zypper --non-interactive update &> /dev/null
    elif command -v pacman &> /dev/null; then
        sudo pacman -Syu --noconfirm &> /dev/null
    elif command -v microdnf &> /dev/null; then
        sudo microdnf update -y &> /dev/null
    else
        echo "Gestionnaire de paquets inconnu ou non trouvÃ©" >&2
        exit 1
    fi
}

install_command() {
    if command -v apt-get &> /dev/null; then
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq $1 &> /dev/null
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y $1 &> /dev/null
    elif command -v yum &> /dev/null; then
        sudo yum install -y $1 &> /dev/null
    elif command -v zypper &> /dev/null; then
        sudo zypper --non-interactive install $1 &> /dev/null
    elif command -v pacman &> /dev/null; then
        sudo pacman -S $1 --noconfirm &> /dev/null
    elif command -v microdnf &> /dev/null; then
        sudo microdnf install $1 -y &> /dev/null
    else
        echo "Gestionnaire de paquets inconnu ou non trouvÃ©" >&2
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

    echo -e "${colorRED}############################################################${noCOLOR}"
    echo -e "${colorRED}##                                                        ##${noCOLOR}"
    echo -e "${colorRED}##             Installation des logiciels cyber           ##${noCOLOR}"
    echo -e "${colorRED}##                                                        ##${noCOLOR}"
    echo -e "${colorRED}############################################################${noCOLOR}"

echo -e -n "\r[ .. ] Install command ${colorORANGE}nmap${noCOLOR} !"
if ! command_exists nmap; then
    install_command nmap
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install ${colorORANGE}nmap${colorRED} !${noCOLOR}"
        exit 13
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install command ${colorORANGE}nmap${noCOLOR} !"

echo -e -n "\r[ .. ] Install command ${colorORANGE}wireshark${noCOLOR} !"
if ! command_exists wireshark; then
    install_command wireshark
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install ${colorORANGE}wireshark${colorRED} !${noCOLOR}"
        exit 14
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install command ${colorORANGE}wireshark${noCOLOR} !"

echo -e -n "\r[ .. ] Install command ${colorORANGE}hydra${noCOLOR} !"
if ! command_exists hydra; then
    install_command hydra
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install ${colorORANGE}hydra${colorRED} !${noCOLOR}"
        exit 15
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install command ${colorORANGE}hydra${noCOLOR} !"

echo -e -n "\r[ .. ] Install command ${colorORANGE}sqlmap${noCOLOR} !"
if ! command_exists sqlmap; then
    install_command sqlmap
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install ${colorORANGE}sqlmap${colorRED} !${noCOLOR}"
        exit 16
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install command ${colorORANGE}sqlmap${noCOLOR} !"

echo -e -n "\r[ .. ] Install command ${colorORANGE}mysql${noCOLOR} !"
if ! command_exists mysql; then
    install_command mysql-server
    if [ $? -ne 0 ]; then
        install_command mariadb-server
        if [ $? -ne 0 ]; then
            echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install ${colorORANGE}mysql${colorRED} !${noCOLOR}"
            exit 17
        fi
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install command ${colorORANGE}mysql${noCOLOR} !"

echo -e -n "\r[ .. ] Install command ${colorORANGE}snap${noCOLOR} !"
if ! command_exists snap; then
    install_command snapd
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Faill to install ${colorORANGE}snap${noCOLOR} !"
        exit 18
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install command ${colorORANGE}snap${noCOLOR} !"

echo -e -n "\r[ .. ] Install ${colorORANGE}sublime-text${noCOLOR} !"
if ! [ -d /snap/sublime-text/ ]; then
    sudo snap install sublime-text --classic &> /dev/null
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install ${colorORANGE}sublime-text${noCOLOR} !"
        exit 19
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install ${colorORANGE}sublime-text${noCOLOR} !"

# installation de logiciels Footprinting

echo -e -n "\r[ .. ] Install package ${colorORANGE}geoip-bin${noCOLOR} !"
if ! command_exists geoiplookup; then
    install_command geoip-bin
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install ${colorORANGE}geoip-bin${noCOLOR} !"
        exit 20
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install package ${colorORANGE}geoip-bin${noCOLOR} !"

echo -e -n "\r[ .. ] Install package ${colorORANGE}sublist3r${noCOLOR} !"
if ! command_exists sublist3r; then
    install_command sublist3r
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install ${colorORANGE}sublist3r${noCOLOR} !"
        exit 21
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install package ${colorORANGE}sublist3r${noCOLOR} !"

echo -e -n "\r[ .. ] Install package ${colorORANGE}nikto${noCOLOR} !"
if ! command_exists nikto; then
    install_command nikto
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install ${colorORANGE}nikto${noCOLOR} !"
        exit 22
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install package ${colorORANGE}nikto${noCOLOR} !"

# installation de logiciels spoofing

echo -e -n "\r[ .. ] Install package ${colorORANGE}dsniff${noCOLOR} !"
if ! command_exists dsniff; then
    install_command dsniff
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install ${colorORANGE}dsniff${noCOLOR} !"
        exit 23
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install package ${colorORANGE}dsniff${noCOLOR} !"

echo -e -n "\r[ .. ] Install package ${colorORANGE}hping3${noCOLOR} !"
if ! command_exists hping3; then
    install_command hping3
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install ${colorORANGE}hping3${noCOLOR} !"
        exit 24
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install package ${colorORANGE}hping3${noCOLOR} !"

echo -e -n "\r[ .. ] Install package ${colorORANGE}macchanger${noCOLOR} !"
if ! command_exists macchanger; then
    install_command macchanger
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install ${colorORANGE}macchanger${noCOLOR} !"
        exit 25
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install package ${colorORANGE}macchanger${noCOLOR} !"

# installation Spiderfoot

echo -e -n "\r[ .. ] Install package ${colorORANGE}git${noCOLOR} !"
if ! command_exists git; then
    install_command git
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install ${colorORANGE}git${noCOLOR} !"
        exit 26
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install package ${colorORANGE}git${noCOLOR} !"

echo -e -n "\r[ .. ] Install Spiderfoot !"
if ! [ -d spiderfoot ]; then
    git clone https://github.com/smicallef/spiderfoot.git &> /dev/null
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to clone Spiderfoot !${noCOLOR}"
        exit 27
    fi
fi
echo -e -n "\r[ ${colorGREEN}*${noCOLOR}. ] Install Spiderfoot !"
if ! docker_container_exists "spiderfoot" ; then
    cd spiderfoot
    docker compose up -d &> /dev/null
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to start Spiderfoot !${noCOLOR}"
        exit 28
    fi
    cd ..
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install Spiderfoot !"

# installation de DVWA
echo -e -n "\r[ .. ] Install DVWA !"
if ! [ -d DVWA ]; then
    git clone https://github.com/digininja/DVWA.git &> /dev/null
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to clone DVWA !${noCOLOR}"
        exit 29
    fi
fi
echo -e -n "\r[ ${colorGREEN}*${noCOLOR}. ] Install DVWA !"
if ! docker_container_exists "dvwa-dvwa-1" ; then
    cd DVWA
    docker compose up -d &> /dev/null
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to start DVWA !${noCOLOR}"
        exit 30
    fi
    cd ..
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install DVWA !"

echo -e "${colorRED}#############################################################################################${noCOLOR}"
echo -e "${colorRED}##                                                                                         ##${noCOLOR}"
echo -e "${colorRED}##         Insstallation du logiciel SYSREPTOR                                             ##${noCOLOR}"
echo -e "${colorRED}##         Reponse aux questions :                                                         ##${noCOLOR}"
echo -e "${colorRED}##         1) entrer, 2) Y, 3) Y, 4) Y, 5) Y, 6) entrer, 7) localhost, 8) Y et 9) Y        ##${noCOLOR}"
echo -e "${colorRED}##                                                                                         ##${noCOLOR}"
echo -e "${colorRED}#############################################################################################${noCOLOR}"

# installation de Sysreptor

echo -e -n "\r[ .. ] Install command ${colorORANGE}openssl${noCOLOR} !"
if ! command_exists openssl; then
    install_command openssl
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install ${colorORANGE}openssl${noCOLOR} !"
        exit 31
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install command ${colorORANGE}openssl${noCOLOR} !"

echo -e -n "\r[ .. ] Install package ${colorORANGE}uuid-runtime${noCOLOR} !"
if ! command_exists uuidd; then
    install_command uuid-runtime
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install ${colorORANGE}uuid-runtime${noCOLOR} !"
        exit 32
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install package ${colorORANGE}uuid-runtime${noCOLOR} !"

echo -e -n "\r[ .. ] Install package ${colorORANGE}tar${noCOLOR} !"
if ! command_exists tar; then
    install_command tar
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install ${colorORANGE}tar${noCOLOR} !"
        exit 33
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install package ${colorORANGE}tar${noCOLOR} !"

echo -e -n "\r[ .. ] Install package ${colorORANGE}coreutils${noCOLOR} !"
if ! is_package_installed coreutils; then
    install_command coreutils
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install ${colorORANGE}coreutils${noCOLOR} !"
        exit 34
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install package ${colorORANGE}coreutils${noCOLOR} !"

echo -e -n "\r[ .. ] Install Sysreptor !"
if ! docker_container_exists "sysreptor-app" ; then
    curl -fsSL https://docs.sysreptor.com/install.sh -o get-sysreptor.sh &> /dev/null
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to download Sysreptor install script !${noCOLOR}"
        exit 35
    fi
    echo -e "\n\nif [ -z \"\$SYSREPTOR_CADDY_FQDN\" ]\nthen\n    echo \"URL: http://127.0.0.1:\$SYSREPTOR_CADDY_PORT\" > ~/sysreptor-credential.txt\nelse\n    echo \"URL: http://\$SYSREPTOR_CADDY_FQDN:\$SYSREPTOR_CADDY_PORT\" > ~/sysreptor-credential.txt\nfi\necho \"Username: reptor\" >> ~/sysreptor-credential.txt\necho \"Password: \$password\" >> ~/sysreptor-credential.txt" >> get-sysreptor.sh
    bash get-sysreptor.sh
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install Sysreptor !${noCOLOR}"
        exit 36
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install Sysreptor !"

# installation de exegol

# install pipx if not already installed, from system package:
echo -e -n "\r[ .. ] Install command ${colorORANGE}pipx${noCOLOR} !"
if ! command_exists pipx; then
    install_command pipx
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install ${colorORANGE}pipx${noCOLOR} !"
        exit 37
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install command ${colorORANGE}pipx${noCOLOR} !"

# You can now install Exegol package from PyPI
echo -e -n "\r[ .. ] Install Exegol !"
pipx install exegol --force &> /dev/null
if [ $? -ne 0 ]; then
    echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install Exegol !${noCOLOR}"
    exit 38
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install Exegol !"

# Using the system package manager

echo -e -n "\r[ .. ] Install command ${colorORANGE}python3${noCOLOR} !"
if ! command_exists python3; then
    install_command python3
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install ${colorORANGE}python3${noCOLOR} !"
        exit 43
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install command ${colorORANGE}python3${noCOLOR} !"

echo -e -n "\r[ .. ] Install command ${colorORANGE}pip3${noCOLOR} !"
if ! command_exists pip3; then
    install_command python3-pip
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install ${colorORANGE}pip3${noCOLOR} !"
        exit 44
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install command ${colorORANGE}pip3${noCOLOR} !"

echo -e -n "\r[ .. ] Install package ${colorORANGE}python3-full${noCOLOR} !"
if ! is_package_installed python3-full; then
    install_command python3-full
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install ${colorORANGE}python3-full${noCOLOR} !"
        exit 45
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install package ${colorORANGE}python3-full${noCOLOR} !"

echo -e -n "\r[ .. ] Configure python3 !"
if ! [ -f /usr/local/share/.venv/bin/activate ]; then
    sudo python3 -m venv /usr/local/share/.venv &> /dev/null
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to configure python3 !"
        exit 46
    fi
    sudo bash -c 'echo "#!/bin/sh" > /etc/profile.d/python3.sh'
    sudo bash -c 'echo "if [ -f /usr/local/share/.venv/bin/activate ]; then" >> /etc/profile.d/python3.sh'
    sudo bash -c 'echo "    source /usr/local/share/.venv/bin/activate" >> /etc/profile.d/python3.sh'
    sudo bash -c 'echo "fi" >> /etc/profile.d/python3.sh'

    source /etc/profile.d/python3.sh
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to reload bashrc !"
        exit 47
    fi

    sudo sed -E -i "s/\s*(^Defaults\s+secure_path=\".+)\"/\1:\/usr\/local\/share\/.venv\/bin\"/g" /etc/sudoers
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to edit sudo environement file !"
        exit 48
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Configure python3 !"

echo -e -n "\r[ .. ] Install command ${colorORANGE}register-python-argcomplete${noCOLOR} !"
if ! command_exists register-python-argcomplete; then
    install_command python3-argcomplete
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to install ${colorORANGE}python3-argcomplete${noCOLOR} !"
        exit 49
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install command ${colorORANGE}register-python-argcomplete${noCOLOR} !"

echo -e -n "\r[ .. ] Register Exegol completion !"
register-python-argcomplete --no-defaults exegol | sudo tee /etc/bash_completion.d/exegol > /dev/null
if [ $? -ne 0 ]; then
    echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to register Exegol completion !${noCOLOR}"
    exit 50
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Register Exegol completion !"

# installation de Nessus
echo -e -n "\r[ .. ] Install Nessus !"
if ! docker_container_exists "nessus-managed" ; then
    docker pull tenable/nessus:latest-oracle &> /dev/null
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to pull Nessus image !${noCOLOR}"
        exit 51
    fi
    echo -e -n "\r[ ${colorGREEN}*${noCOLOR}. ] Install Nessus !"
    docker run --name "nessus-managed" -d -p 127.0.0.1:8834:8834 tenable/nessus:latest-oracle &> /dev/null
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to start Nessus !${noCOLOR}"
        exit 52
    fi
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install Nessus !"

# install Setoolkit

echo -e -n "\r[ .. ] Install Setoolkit !"
if ! [ -d setoolkit ]; then
    git clone https://github.com/trustedsec/social-engineer-toolkit/ setoolkit/ &> /dev/null
    if [ $? -ne 0 ]; then
        echo -e "\r[ ${colorRED}NOK${noCOLOR} ] ${colorRED}Failed to clone Setoolkit !${noCOLOR}"
        exit 53
    fi

    echo -e -n "\r[ ${colorGREEN}*${noCOLOR}. ] Install Setoolkit !"

    cd setoolkit
    sudo pip3 install -r requirements.txt
    sudo python3 setup.py
    cd ..
fi
echo -e "\r[ ${colorGREEN}OK${noCOLOR} ] Install Setoolkit !"


echo -e "${colorRED}#############################################################################################${noCOLOR}"
echo -e "${colorRED}##                                                                                         ##${noCOLOR}"
echo -e "${colorRED}##  Commande à installer pour activer la commande exegol                                   ##${noCOLOR}"
echo -e "${colorRED}##  dans le terminal :                                                                     ##${noCOLOR}"
echo -e "${colorRED}##  pipx ensurepath                                                                        ##${noCOLOR}"
echo -e "${colorRED}##  echo \"alias exegol='sudo -E $(which exegol)'\" >> ~/.bash_aliases     ##${noCOLOR}"
echo -e "${colorRED}##  source ~/.bashrc                                                                       ##${noCOLOR}"
echo -e "${colorRED}##                                                                                         ##${noCOLOR}"
echo -e "${colorRED}#############################################################################################${noCOLOR}"
