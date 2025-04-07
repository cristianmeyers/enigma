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



echo  '

 _______ .__   __.  __    _______ .___  ___.      ___      
|   ____||  \ |  | |  |  /  _____||   \/   |     /   \     
|  |__   |   \|  | |  | |  |  __  |  \  /  |    /  ^  \    
|   __|  |  . `  | |  | |  | |_ | |  |\/|  |   /  /_\  \   
|  |____ |  |\   | |  | |  |__| | |  |  |  |  /  _____  \  
|_______||__| \__| |__|  \______| |__|  |__| /__/     \__\ 
                                                           


'