#!/bin/bash
# Actualizar el sistema e instalar paquetes base
apt-get update -y
apt-get install postgresql postgresql-contrib awscli curl -y

# --- CONFIGURACIÓN DE HOSTNAME DINÁMICO ---
hostnamectl set-hostname "${hostnameDatabase}"
echo "127.0.1.1 ${hostnameDatabase}" >> /etc/hosts

# Instalar Tailscale de forma segura usando su script oficial
curl -fsSL https://tailscale.com/install.sh | sh

# Configurar Postgres para escuchar tráfico de red
echo "listen_addresses = '*'" >> /etc/postgresql/14/main/postgresql.conf

# PERMISOS DE RED ACCESO: 
# 1. Rango VPC local de AWS
echo "host    all             all             10.0.0.0/16            md5" >> /etc/postgresql/14/main/pg_hba.conf
# 2. Rango virtual interno Tailscale
echo "host    all             all             100.64.0.0/10           md5" >> /etc/postgresql/14/main/pg_hba.conf
# 3. RANGO DE TU CASA (Requerido para que responda a tu Kali a través de pfSense)
echo "host    all             all             192.168.1.0/24          md5" >> /etc/postgresql/14/main/pg_hba.conf

# Reiniciar Postgres para aplicar cambios de red
systemctl restart postgresql

# Crear el Usuario y la Base de Datos escapando las comillas para preservar mayúsculas/minúsculas
sudo -u postgres psql -c "CREATE USER \"${db_user}\" WITH PASSWORD '${db_password}';"
sudo -u postgres psql -c "CREATE DATABASE \"${db_name}\" OWNER \"${db_user}\";"

# Conectarse automáticamente a Tailscale sin intervención manual
tailscale up --authkey="${tailscale_key}" --hostname="${hostnameDatabase}"
