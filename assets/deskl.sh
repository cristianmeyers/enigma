#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Este script necesita permisos de superusuario. Ejecuta como root o usa sudo."
    exit 1
fi

sudo apt-get update -qq


sudo apt-get install -y -qq openssh-server


sudo systemctl enable ssh >/dev/null 2>&1
sudo systemctl start ssh >/dev/null 2>&1

if command -v ufw >/dev/null 2>&1; then
    ufw allow ssh >/dev/null 2>&1
fi

if systemctl is-active --quiet ssh; then
    echo "El servidor SSH se ha instalado y está ejecutándose correctamente."
else
    echo "Hubo un problema al instalar o iniciar el servidor SSH."
    exit 1
fi
