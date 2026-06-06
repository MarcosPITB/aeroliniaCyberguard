#!/bin/bash

# 1. Cargar las variables de entorno seguras
if [ -f ./.restic.env ]; then
    source ./.restic.env
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: No se encontró el archivo de entorno /etc/restic_postgres.env" >&2
    exit 1
fi

# Políticas de retención
KEEP_LAST=7
KEEP_DAILY=7
KEEP_WEEKLY=4

# Definir ruta temporal local para el volcado
TMP_DUMP_FILE="/tmp/$DB_NAME-$(date '+%Y%m%d_%H%M%S').dump"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Iniciando descarga remota de la BD: $DB_NAME desde $DB_HOST..."

# 2. Conectarse de manera remota a la base de datos de AWS usando Tailscale y guardar el archivo temporalmente
# Nota: Requiere tener instalado postgresql-client en esta máquina de backups
pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -F c -b -v -f "$TMP_DUMP_FILE" "$DB_NAME"

if [ $? -eq 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Volcado remoto exitoso. Enviando dump local a Restic..."

    # 3. Guardar el archivo dump local en el repositorio cifrado de Restic
    restic backup "$TMP_DUMP_FILE" --tag "remote-postgres-backup"

    if [ $? -eq 0 ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ¡Backup guardado y cifrado con éxito en Restic!"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Falló la inserción del archivo en Restic." >&2
    fi
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: No se pudo realizar el pg_dump remoto." >&2
fi

# 4. LIMPIEZA ABSOLUTA DE ARCHIVOS TEMPORALES LOCALES
# Borramos el dump de la carpeta /tmp para no dejar rastro de los datos sin cifrar en esta máquina
if [ -f "$TMP_DUMP_FILE" ]; then
    rm -f "$TMP_DUMP_FILE"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Limpieza completada. Archivo temporal eliminado."
fi

# 5. Mantenimiento del repositorio (Políticas de retención)
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Ejecutando limpieza de snapshots antiguos (Prune)..."
restic forget --keep-last $KEEP_LAST --keep-daily $KEEP_DAILY --keep-weekly $KEEP_WEEKLY --prune

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Proceso finalizado."
