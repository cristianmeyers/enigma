function eraseLastMessage() {
    clear
    echo -en "\rhello"
    echo
    for i in {1..10}
    do
        clear
        echo -ne "\rMise a jour du systeme $i"
        sleep 1
    done
    echo -ne "\r$(printf '%*s' ${COLUMNS:-$(tput cols)} '')"
    #                          numero de colonnes o comando tput
    #                     * :numero de caracteres a imprimir como argumento 
    #                      %s caracteres     
    echo -e "\rMise a jour reussi"
}

# basic message :
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


# advanced message :

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



function message_end(){
    echo  '

 _______ .__   __.  __    _______ .___  ___.      ___      
|   ____||  \ |  | |  |  /  _____||   \/   |     /   \     
|  |__   |   \|  | |  | |  |  __  |  \  /  |    /  ^  \    
|   __|  |  . `  | |  | |  | |_ | |  |\/|  |   /  /_\  \   
|  |____ |  |\   | |  | |  |__| | |  |  |  |  /  _____  \  
|_______||__| \__| |__|  \______| |__|  |__| /__/     \__\ 
                                                           


'
}

# ========================= testant la fonction de raph =========================

function install_spiderfoot() {
    local program="spiderfoot"
    local install_dir="$HOME/tools/spiderfoot"
    local github_url="https://github.com/smicallef/spiderfoot.git"

    echo -ne "\r[ $(color "..." "32") ] Vérification de $(color "$program" "32")..."

    # Vérifier si SpiderFoot est déjà installé
    if [ -d "$install_dir" ] && [ -f "$install_dir/sf.py" ]; then
        echo -ne "\r$(printf '%*s' ${COLUMNS:-$(tput cols)} '')"
        echo -ne "\r[ $(color "OK" "32") ] $(color "$program" "32") est déjà installé dans $install_dir"
        echo
        return 0
    fi

    # Installer les dépendances
    echo -ne "\r[ $(color "..." "32") ] Installation des dépendances pour $(color "$program" "32")..."
    install_program git python3 python3-pip python3-venv

    # Cloner le dépôt
    echo -ne "\r[ $(color "..." "32") ] Clonage du dépôt $(color "$program" "32")..."
    mkdir -p "$install_dir"
    if ! git clone "$github_url" "$install_dir" &> /dev/null; then
        echo -ne "\r[ $(color "Error" "31") ] Échec du clonage de $(color "$program" "36")"
        return 1
    fi

    # Configurer l'environnement virtuel
    echo -ne "\r[ $(color "..." "32") ] Configuration de l'environnement Python..."
    if ! python3 -m venv "$install_dir/venv"; then
        echo -ne "\r[ $(color "Error" "31") ] Échec de la création de l'environnement virtuel"
        return 1
    fi

    # Installer les requirements
    echo -ne "\r[ $(color "..." "32") ] Installation des dépendances Python..."
    source "$install_dir/venv/bin/activate"
    if ! pip install -r "$install_dir/requirements.txt" &> /dev/null; then
        echo -ne "\r[ $(color "Error" "31") ] Échec de l'installation des dépendances Python"
        deactivate
        return 1
    fi
    deactivate

    # Créer un lanceur
    echo -ne "\r[ $(color "..." "32") ] Création du lanceur..."
    cat > "$HOME/.local/bin/spiderfoot" <<EOF
#!/bin/bash
source $install_dir/venv/bin/activate
python3 $install_dir/sf.py \$@
deactivate
EOF
    chmod +x "$HOME/.local/bin/spiderfoot"

    echo -ne "\r$(printf '%*s' ${COLUMNS:-$(tput cols)} '')"
    echo -ne "\r[ $(color "OK" "32") ] $(color "$program" "32") installé avec succès dans $install_dir"
    echo
    echo -e "  Lancez avec: $(color "spiderfoot -l 127.0.0.1:5000" "36")"
    return 0
}
