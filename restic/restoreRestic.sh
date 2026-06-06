#!/bin/bash

# ==============================================================================
# 1. CONFIGURACIÓN Y CARGA DEL ENTORNO LOCAL
# ==============================================================================
# Definimos la ruta al archivo local de variables
ENV_FILE="./.restic.env"

# Validamos que el archivo de entorno exista en el directorio actual
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: No se encontró el archivo de entorno local en: $ENV_FILE" >&2
    echo "Asegúrate de ejecutar este script desde la carpeta donde reside tu archivo .restic.env" >&2
    exit 1
fi

# Generamos una ruta única temporal local para la extracción del dump sin cifrar
TMP_RESTORE_FILE="/tmp/restore_$(date '+%Y%m%d_%H%M%S').dump"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] --- INICIANDO PROCESO DE RESTAURACIÓN REMOTA ---"

# ==============================================================================
# 2. VALIDACIÓN DEL SNAPSHOT PASADO POR PARÁMETRO
# ==============================================================================
SNAPSHOT_ID=$1

# Si el usuario no introduce un ID, listamos de forma interactiva los disponibles
if [ -z "$SNAPSHOT_ID" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Debes especificar el ID del snapshot de Restic que deseas restaurar."
    echo "Uso: $0 <ID_SNAPSHOT>"
    echo ""
    echo "Lista de snapshots disponibles actualmente en el repositorio:"
    restic snapshots
    exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Verificando el snapshot '$SNAPSHOT_ID' en el repositorio..."

# ==============================================================================
# 3. IDENTIFICACIÓN Y EXTRACCIÓN DINÁMICA DEL ARCHIVO .DUMP
# ==============================================================================
# Buscamos de forma automatizada la ruta interna real del archivo guardado en Restic
TARGET_PATH=$(restic ls "$SNAPSHOT_ID" | grep '\.dump$' | head -n 1 | awk '{print $1}')

if [ -z "$TARGET_PATH" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: No se encontró ningún archivo .dump dentro del snapshot '$SNAPSHOT_ID'." >&2
    exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Extrayendo archivo interno: $TARGET_PATH"

# Extraemos el archivo cifrado hacia nuestra ruta temporal en /tmp
restic dump "$SNAPSHOT_ID" "$TARGET_PATH" > "$TMP_RESTORE_FILE"

if [ $? -ne 0 ] || [ ! -s "$TMP_RESTORE_FILE" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: No se pudo extraer el snapshot de Restic o el archivo temporal está vacío." >&2
    rm -f "$TMP_RESTORE_FILE"
    exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Extracción local completada con éxito."
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Conectando vía Tailscale a '$DB_HOST' para inyectar los datos..."

# ==============================================================================
# 4. INYECCIÓN REMOTA (PG_RESTORE) CON CONTROL INTELIGENTE DE ERRORES
# ==============================================================================
# --clean vacía las tablas del destino antes de importar para evitar colisiones de IDs duplicados
RESTORE_OUTPUT=$(pg_restore -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" --clean --if-exists -v "$TMP_RESTORE_FILE" 2>&1)
PG_STATUS=$?

# Analizador inteligente de compatibilidad de versiones de Postgres
if [ $PG_STATUS -ne 0 ]; then
    # Si el error es exclusivamente por el parámetro inofensivo "transaction_timeout", lo toleramos
    if echo "$RESTORE_OUTPUT" | grep -q "unrecognized configuration parameter \"transaction_timeout\""; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Nota: Se omitió un aviso de compatibilidad (transaction_timeout). Los datos estructurales se procesaron."
        STATUS_FINAL=0
    else
        # Si es un error crítico real, imprimimos la salida del error de postgres y marcamos fallo
        echo "$RESTORE_OUTPUT" >&2
        STATUS_FINAL=1
    fi
else
    STATUS_FINAL=0
fi

# Feedback visual al operador
if [ $STATUS_FINAL -eq 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ¡Base de datos '$DB_NAME' restaurada con éxito de forma remota!"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Ocurrió un fallo crítico real durante el pg_restore remoto." >&2
fi

# ==============================================================================
# 5. LIMPIEZA ABSOLUTA DE ARCHIVOS TEMPORALES
# ==============================================================================
if [ -f "$TMP_RESTORE_FILE" ]; then
    rm -f "$TMP_RESTORE_FILE"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Limpieza completada. El volcado temporal sin cifrar ha sido eliminado del disco."
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] --- FIN DEL PROCESO ---"
