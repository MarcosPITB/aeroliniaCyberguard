#!/bin/bash
apt-get update -y
apt-get install postgresql postgresql-contrib awscli curl git -y

# --- CONFIGURACIÓN DE HOSTNAME DINÁMICO ---
hostnamectl set-hostname "${hostnameDatabase}"
echo "127.0.1.1 ${hostnameDatabase}" >> /etc/hosts

# Instalar e iniciar Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --authkey="${tailscale_key}" --accept-routes --advertise-tags=tag:database &

# Configurar puerto y escucha en postgresql.conf de forma dinámica
echo "listen_addresses = '*'" >> /etc/postgresql/14/main/postgresql.conf
if [ "${db_port}" != "5432" ]; then
    echo "port = ${db_port}" >> /etc/postgresql/14/main/postgresql.conf
fi

# PERMISOS DE RED (pg_hba.conf)
echo "host    all             all             10.0.0.0/16             scram-sha-256" >> /etc/postgresql/14/main/pg_hba.conf
echo "host    all             all             100.64.0.0/10           scram-sha-256" >> /etc/postgresql/14/main/pg_hba.conf

systemctl restart postgresql

# Crear el Usuario y la Base de Datos con parámetros dinámicos
sudo -u postgres psql -p "${db_port}" -c "CREATE USER \"${db_user}\" WITH PASSWORD '${db_password}';"
sudo -u postgres psql -p "${db_port}" -c "CREATE DATABASE \"${db_name}\" OWNER \"${db_user}\";"
sudo -u postgres psql -p "${db_port}" -c "GRANT ALL PRIVILEGES ON DATABASE \"${db_name}\" TO \"${db_user}\";"

# --- DESPLIEGUE E INYECCIÓN DEL SCRIPT SQL DESDE GITHUB ---
rm -rf /tmp/aerolinia
git clone "${github_repo_url}" /tmp/aerolinia

if [ -f /tmp/aerolinia/sql/aerolinia.sql ]; then
    # Importar el dump original
    sudo -u postgres psql -p "${db_port}" -d "${db_name}" -f /tmp/aerolinia/sql/aerolinia.sql
    
    # Reasignar el OWNER de las tablas al Cyberuser actual de Terraform
    sudo -u postgres psql -p "${db_port}" -d "${db_name}" -c "ALTER TABLE public.pasajeros OWNER TO \"${db_user}\";"
    sudo -u postgres psql -p "${db_port}" -d "${db_name}" -c "ALTER SEQUENCE public.pasajeros_id_seq OWNER TO \"${db_user}\";"
fi

# --- LIMPIEZA ABSOLUTA DE ARCHIVOS TEMPORALES ---
rm -rf /tmp/aerolinia
