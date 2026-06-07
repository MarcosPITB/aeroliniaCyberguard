#!/bin/bash
apt-get update -y
apt-get install nginx certbot python3-certbot-nginx awscli curl git php-fpm php-pgsql wget -y

# --- CONFIGURACIÓN DE HOSTNAME DINÁMICO ---
hostnamectl set-hostname "${hostnameServer}"
echo "127.0.1.1 ${hostnameServer}" >> /etc/hosts

# Instalar e iniciar Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --authkey="${tailscale_key}" --accept-routes --advertise-tags=tag:webserver

# Configurar Certificado SSL Autofirmado básico
mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/nginx.key \
  -out /etc/nginx/ssl/nginx.crt \
  -subj "/C=ES/ST=Catalonia/L=Barcelona/O=Laboratorio/CN=localhost"

# --- DESPLIEGUE DESDE GITHUB ---
rm -rf /tmp/aerolinia
git clone "${github_repo_url}" /tmp/aerolinia

rm -rf /var/www/html/*
cp -r /tmp/aerolinia/web/* /var/www/html/

# --- INYECTAR LAS VARIABLES DE ENTORNO EN PHP-FPM ---
cat << ENV_CONF > /etc/php/8.1/fpm/pool.d/env_variables.conf
[www]
env[DB_HOST] = '${hostnameDatabase}'
env[DB_PORT] = '${db_port}'
env[DB_NAME] = '${db_name}'
env[DB_USER] = '${db_user}'
env[DB_PASSWORD] = '${db_password}'
ENV_CONF

chown -R www-data:www-data /var/www/html

# Configuración del Virtual Host de Nginx
cat << 'CONFIG' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    return 301 https://$host$request_uri; 
}
server {
    listen 443 ssl default_server;
    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;
    
    root /var/www/html;
    index index.php index.html;
    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }
}
CONFIG

# --- CONFIGURACIÓN DE SSH PARA ACCESO POR CONTRASEÑA ---
# 1. Configurar el archivo principal
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

# 2. Corregir archivos ocultos de AWS/Cloud-init que pisan la configuración
if [ -d /etc/ssh/sshd_config.d ]; then
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config.d/*.conf 2>/dev/null || true
fi

# 3. Asignar contraseña a root y reiniciar
echo "root:${db_password}" | chpasswd
systemctl restart ssh || systemctl restart sshd

wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.7.5-1_amd64.deb
WAZUH_MANAGER='${wazuh_manager}' dpkg -i ./wazuh-agent_4.7.5-1_amd64.deb
rm -f ./wazuh-agent_4.7.5-1_amd64.deb

systemctl daemon-reload
systemctl enable wazuh-agent
systemctl start wazuh-agent


# --- LIMPIEZA ABSOLUTA DE ARCHIVOS TEMPORALES ---
rm -rf /tmp/aerolinia

# Reiniciar servicios para aplicar cambios
systemctl restart php8.1-fpm
systemctl restart nginx
