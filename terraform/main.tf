# ==========================================
# 1. DECLARACIÓN DE VARIABLES
# ==========================================

variable "tailscale_auth_key" {
  type        = string
  description = "La Auth Key generada en el panel de Tailscale para registrar maquinas automaticamente"
  sensitive   = true
}

variable "db_name" {
  type        = string
  description = "Nombre de la base de datos de PostgreSQL"
  default     = "mi_base_datos"
}

variable "db_user" {
  type        = string
  description = "Usuario administrador de la base de datos"
  default     = "admin_user"
}

variable "db_password" {
  type        = string
  description = "Contrasena para el usuario de la base de datos"
  sensitive   = true
}

variable "hostnameServer" {
  type        = string
  description = "Nombre servidor Nginx"
}

variable "hostnameDatabase" {
  type        = string
  description = "Nombre de la Base de Datos"
}

# ==========================================
# 2. PROVEEDOR Y CONFIGURACIÓN DE RED (VPC)
# ==========================================

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "vpc-laboratorio" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "main-igw" }
}

# ==========================================
# 3. SUBREDES (PÚBLICA Y PRIVADA)
# ==========================================

resource "aws_subnet" "public_sub" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags                    = { Name = "public-subnet" }
}

resource "aws_subnet" "private_sub" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags              = { Name = "private-subnet" }
}

# ==========================================
# 4. COMPONENTES NAT GATEWAY (Salida a Internet Segura)
# ==========================================

# IP Elástica para el NAT Gateway
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]
  tags       = { Name = "nat-gateway-eip" }
}

# NAT Gateway (Asignado en la subred pública)
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_sub.id

  tags       = { Name = "main-nat-gateway" }
  depends_on = [aws_internet_gateway.gw]
}

# ==========================================
# 5. TABLAS DE ENRUTAMIENTO Y ASOCIACIONES
# ==========================================

# --- TABLA PÚBLICA ---
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "public-route-table" }
}

# Ruta explícita de la Tabla Pública hacia el Internet Gateway
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_sub.id
  route_table_id = aws_route_table.public_rt.id
}

# --- TABLA PRIVADA ---
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "private-route-table" }
}

# Ruta explícita de la Tabla Privada hacia el NAT Gateway
resource "aws_route" "private_nat_access" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_sub.id
  route_table_id = aws_route_table.private_rt.id
}

# ==========================================
# 6. GRUPOS DE SEGURIDAD (SECURITY GROUPS)
# ==========================================

resource "aws_security_group" "nginx_sg" {
  name        = "nginx-sg"
  description = "Permitir HTTP, HTTPS y trafico de Tailscale"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Tailscale UDP"
    from_port   = 41641
    to_port     = 41641
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "nginx-sg" }
}

resource "aws_security_group" "postgres_sg" {
  name        = "postgres-sg"
  description = "Permitir PostgreSQL desde Nginx y red Tailscale sin Ping"
  vpc_id      = aws_vpc.main.id

  # Conexión local interna VPC desde Nginx
  ingress {
    description     = "PostgreSQL desde Nginx"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.nginx_sg.id]
  }

  # Acceso directo al puerto TCP 5432 desde la interfaz interna de Tailscale
  ingress {
    description = "PostgreSQL desde la red Tailscale"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["100.64.0.0/10"]
  }

  # Tráfico de túnel UDP internamente desde la VPC
  ingress {
    description = "Tailscale UDP interno desde la VPC"
    from_port   = 41641
    to_port     = 41641
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "postgres-sg" }
}

# ==========================================
# 7. PERFIL DE IAM DE LABORATORIO (AWS ACADEMY)
# ==========================================

# Mapeamos directamente el ARN verificado del laboratorio para evitar consultas fallidas de la API
# arn:aws:iam::786256571087:instance-profile/LabInstanceProfile

# ==========================================
# 8. INSTANCIAS EC2 (UBUNTU 22.04 LTS)
# ==========================================

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# --- SERVIDOR NGINX ---
resource "aws_instance" "nginx_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_sub.id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  iam_instance_profile   = "LabInstanceProfile"

  user_data = templatefile("${path.module}/setup_nginx.sh", {
    tailscale_key  = var.tailscale_auth_key
    hostnameServer = var.hostnameServer
  })

  tags = { Name = "Nginx-Public-Server" }

  # Fuerza a que Nginx espere a tener acceso real a internet mediante la ruta pública
  depends_on = [aws_route.public_internet_access]
}

# --- SERVIDOR POSTGRESQL ---
resource "aws_instance" "postgres_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_sub.id
  vpc_security_group_ids = [aws_security_group.postgres_sg.id]
  iam_instance_profile   = "LabInstanceProfile"

  user_data = templatefile("${path.module}/setup_postgres.sh", {
    tailscale_key    = var.tailscale_auth_key
    db_name          = var.db_name
    db_user          = var.db_user
    db_password      = var.db_password
    hostnameDatabase = var.hostnameDatabase
  })

  tags = { Name = "Postgres-Private-DB" }

  # CAMBIO CRUCIAL: Fuerza a que Postgres espere a que la ruta privada hacia el NAT Gateway esté activa
  depends_on = [aws_route.private_nat_access]
}

# ==========================================
# 9. IP ELÁSTICA (EIP) PARA NGINX
# ==========================================

resource "aws_eip" "nginx_eip" {
  instance = aws_instance.nginx_server.id
  domain   = "vpc"
  tags     = { Name = "nginx-elastic-ip" }
}

# ==========================================
# 10. SALIDAS DE TERMINAL (OUTPUTS)
# ==========================================

output "nginx_public_ip" {
  value       = aws_eip.nginx_eip.public_ip
  description = "IP publica del servidor Nginx"
}

output "postgres_private_ip" {
  value       = aws_instance.postgres_server.private_ip
  description = "IP privada interna de la Base de Datos"
}
