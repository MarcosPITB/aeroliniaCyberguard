# Terraform

Este repositorio contiene el código de **Terraform** y scripts para desplegar una web segura en AWS. La infraestructura consta de un servidor web Nginx en una subred pública y un servidor de bases de datos PostgreSQL aislado en una subred privada, interconectados y monitorizados de forma segura.

---

## 🏗️ Arquitectura del Sistema

La infraestructura se despliega en la región `us-east-1` y se compone de los siguientes elementos:

* **Red (VPC):** Una VPC con una de red `10.0.0.0/16`.
    * **Subred Pública (`10.0.1.0/24`):** Contiene el servidor Nginx y cuenta con un *Internet Gateway* para tráfico web.
    * **Subred Privada (`10.0.2.0/24`):** Contiene la base de datos PostgreSQL, completamente aislada del exterior, con acceso a internet mediante un *NAT Gateway* para actualizaciones y conexiones remotas.
* **Servidor Web (Nginx):** Instancia EC2 configurada con HTTPS mediante un certificado SSL autofirmado, PHP-FPM 8.1 y la aplicación web clonada desde GitHub.
* **Servidor de Base de Datos (PostgreSQL 14):** Instancia EC2 configurada para levantar la base de datos e importar dumps de SQL.
* **Red Privada Virtual (Tailscale):** Ambas máquinas se unen a una red Mesh privada corporativa (Tailnet), permitiendo la comunicación entre servicios de Proxmox.
* **Seguridad y Monitorización (Wazuh):** Ambas instancias tienen instalado el agente de seguridad de Wazuh (`v4.7.5`), apuntando directamente al servidor central de Wazuh.

## 🛠️ Configuración de Variables (`terraform.tfvars`)

Antes de ejecutar la infraestructura, se debe de crear un archivo **terraform.tfvars** con las siguientes variables:

| Variable | Descripción | Valor de Ejemplo |
| :--- | :--- | :--- |
| `tailscale_auth_key` | Clave de autenticación para registrar las máquinas de AWS en Tailscale automáticamente. | `tskey-auth-...` |
| `db_name` | Nombre de la base de datos. | `Cyberguard` |
| `db_user` | Nombre del usuario. | `Cyberuser` |
| `db_password` | Contraseña para el usuario (marcada como sensible). | `Cyberguard2026` |
| `db_port` | Puerto que utiliza la base de datos (por defecto `5432`). | `5432` |
| `hostnameServer` | Nombre del host asignado al servidor web. | `nginx` |
| `hostnameDatabase` | Nombre del host asignado a la base de datos. | `postgres` |
| `github_repo_url` | URL del repositorio que contiene la aplicación web y el dump de SQL. | `https://github.com/...` |
| `wazuh_manager_host` | Dirección IP del servidor central de Wazuh. | `100.104.166.34` |

## 🚀 Pasos para Desplegar

1.  **Clonar el repositorio** y ubicarse en el directorio del Terraform.
2.  **Inicializar Terraform** para descargar los proveedores necesarios:
    ```bash
    terraform init
    ```
3.  **Verificar el plan de ejecución** para asegurar que todos los recursos se crearán correctamente:
    ```bash
    terraform plan
    ```
4.  **Aplicar la infraestructura**. Esto creará los recursos en AWS y ejecutará automáticamente los scripts `setup_*.sh` dentro de las instancias:
    ```bash
    terraform apply
    ```


---

# Aplicación Web

La aplicación permite realizar el check-in online de los pasajeros, guardar sus datos de vuelo en una base de datos y buscar pasajeros.

---

## 🚀 Características de la Aplicación

* **Inicio (`index.php`):** Muestra ofertas de vuelos de la semana y detalles de la flota de aviones comerciales.
* **Paǵina de Check-in (`registro.php`):** Formulario interactivo para recopilar la información del pasajero (datos personales, número de vuelo, ruta, asiento y maletas facturadas).
* **Buscador de Pasajeros (`buscador.php`):** Panel de control que permite buscar pasajeros utilizando su nombre, apellidos o número de pasaporte.
* **Conexión hacia la base de datos (`conexion.php`):** Conexión segura hacia la base de datos usando variables de entorno inyectadas en el servidor.

## ⚙️ Variables de Entorno Requeridas

Para que la página web funcione e interactúe con la base de datos, el archivo `conexion.php` requiere que se especifique los siguientes parámetros en el pool de PHP-FPM:

| Variable de Entorno | Descripción |
| :--- | :--- |
| `DB_HOST` | Nombre de host o IP del servidor de base de datos (Ej: `postgres`). |
| `DB_PORT` | Puerto de escucha de la base de datos (Por defecto: `5432`). |
| `DB_NAME` | Nombre de la base de datos relacional (Ej: `Cyberguard`). |
| `DB_USER` | Usuario con privilegios de escritura/lectura (Ej: `Cyberuser`). |
| `DB_PASSWORD` | Contraseña segura del usuario administrador. |

Estos parámetros los cogera del **terraform.tfvars** de antes

---

# Script de Restic

Esta parte contiene los scripts de Restic para realizar backups la base de datos PostgreSQL.

---

## 📂 Estructura de Archivos del Módulo

* `backupRestic.sh`: Script que hace el backup de la base de datos (`pg_dump`), lo inyecta en el repositorio de Restic y aplica políticas de retención.
* `restoreRestic.sh`: Script para la recuperación ante desastres o accidentes. Extrae un snapshot específico y lo restaura de forma destructiva (`--clean --if-exists`).
* `.restic.env.example`: Plantilla de configuración con las variables de entorno necesarias para la autenticación en el ecosistema.

---

## ⚙️ Configuración del Entorno (`.restic.env`)

Para poner en marcha el sistema, copia la plantilla de configuración y asígnale los valores de tu infraestructura:

```bash
cp .restic.env.example .restic.env
nano .restic.env
```

## 🛠️ Parametros requeridos en el archivo de entorno

`RESTIC_REPOSITORY`:	Ruta del directorio local del repositorio de Restic.

`RESTIC_PASSWORD`:	Contraseña  de cifrado y llave de acceso al repositorio de Restic.

`DB_HOST`:	IP o hostname del servidor de base de datos.

`DB_PORT`:	Puerto de la base de datos de PostgreSQL (Por defecto: 5432).

`DB_NAME`:	Nombre de la base de datos a respaldar o restaurar.

`DB_USER`:	Nombre del usuario de la base de datos con privilegios de backup.

`PGPASSWORD`:	Contraseña del usuario de la base de datos para evitar pedir la contraseña.

## 📁 Inicialización del Repositorio (Solo la primera vez)

Antes de ejecutar los scripts por primera vez, debes inicializar la estructura del repositorio de Restic utilizando la configuración cargada en tu entorno local.

```bash
source .restic.env
restic init
```

