#!/bin/bash
# Actualizar el sistema e instalar paquetes base
apt-get update -y
apt-get install nginx certbot python3-certbot-nginx awscli curl -y

# --- CONFIGURACIÓN DE HOSTNAME DINÁMICO ---
hostnamectl set-hostname "${hostnameServer}"
echo "127.0.1.1 ${hostnameServer}" >> /etc/hosts

# Instalar Tailscale de forma segura usando su script oficial
curl -fsSL https://tailscale.com/install.sh | sh

# Configurar Certificado SSL Autofirmado básico en Barcelona
mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/nginx.key \
  -out /etc/nginx/ssl/nginx.crt \
  -subj "/C=ES/ST=Catalonia/L=Barcelona/O=Laboratorio/CN=localhost"

# Configuración del Virtual Host de Nginx
cat << 'CONFIG' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    return 301 https://\$host\$request_uri; 
}
server {
    listen 443 ssl default_server;
    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;
    root /var/www/html;
    index index.html;
    server_name _;
}
CONFIG

if [ -f /var/www/html/index.nginx-debian.html ]; then
    mv /var/www/html/index.nginx-debian.html /var/www/html/index.html
fi

systemctl restart nginx

# Conectarse automáticamente a Tailscale sin intervención manual
tailscale up --authkey="${tailscale_key}" --hostname="${hostnameServer}"
