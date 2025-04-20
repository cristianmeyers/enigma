#!/bin/bash

# Actualiza la lista de paquetes e instala OpenSSH
echo "Actualizando e instalando OpenSSH..."
sudo apt-get update -y
sudo apt-get install -y openssh-server

# Verificar si el servicio SSH está activo
echo "Verificando el estado del servicio SSH..."
sudo systemctl enable ssh
sudo systemctl start ssh

# Verifica si el servicio SSH está activo
echo "Verificando el estado del servicio SSH..."
if systemctl is-active --quiet ssh; then
    echo "El servicio SSH está corriendo."
else
    echo "Error al iniciar el servicio SSH."
    exit 1
fi

# Generar clave SSH (sin email)
echo "Generando clave SSH..."
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N ""
    echo "Clave SSH generada en $HOME/.ssh/id_ed25519"
else
    echo "Clave SSH ya existe."
fi

# Copiar la clave pública al archivo autorizado para SSH
echo "Configurando las claves SSH..."
mkdir -p $HOME/.ssh
chmod 700 $HOME/.ssh
cat $HOME/.ssh/id_ed25519.pub >> $HOME/.ssh/authorized_keys
chmod 600 $HOME/.ssh/authorized_keys

# Configuración del firewall
echo "Configurando el firewall para permitir SSH..."
sudo ufw allow ssh
sudo ufw enable

# Verificación final
echo "Todo configurado. Ahora puedes acceder a la máquina virtual mediante SSH desde tu PC."
echo "Para acceder desde tu PC, ejecuta el siguiente comando (reemplaza <IP> por la IP de tu VM):"
echo "ssh usuario@<IP>"

# Finalización
echo "Configuración completada. ¡Disfruta de tu acceso SSH!"
