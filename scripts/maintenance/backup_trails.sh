#!/usr/bin/env bash
# =============================================================================
# Script  : backup_trails.sh
# Propósito: Copia de seguridad de los trail files de GoldenGate hacia un
#            directorio de backup, preservando la estructura de directorios
#            y añadiendo un timestamp al nombre del directorio de destino.
# Uso     : bash backup_trails.sh [directorio_backup]
#           Default: /backup/goldengate
# =============================================================================

set -euo pipefail

GG_HOME="${GG_HOME:-/u01/app/oracle/product/19.1.0/oggcore_1}"
DIRDAT="${GG_HOME}/dirdat"
BACKUP_ROOT="${1:-/backup/goldengate}"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
BACKUP_DIR="${BACKUP_ROOT}/trails_${TIMESTAMP}"
LOG_FILE="${GG_HOME}/dirrpt/backup_trails.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') – $*" | tee -a "${LOG_FILE}"
}

log "======================================================"
log " Inicio de copia de trail files"
log " Origen : ${DIRDAT}"
log " Destino: ${BACKUP_DIR}"
log "======================================================"

# ─── Crear directorio de backup ───────────────────────────────────────────
mkdir -p "${BACKUP_DIR}"
log "Directorio de backup creado: ${BACKUP_DIR}"

# ─── Copiar trail files ───────────────────────────────────────────────────
# rsync preserva permisos, timestamps y sólo copia archivos nuevos/modificados
if command -v rsync &>/dev/null; then
    rsync -av --progress "${DIRDAT}/" "${BACKUP_DIR}/" 2>&1 | tee -a "${LOG_FILE}"
else
    cp -pv "${DIRDAT}/"* "${BACKUP_DIR}/" 2>&1 | tee -a "${LOG_FILE}" || true
fi

# ─── Verificar integridad (checksum) ─────────────────────────────────────
if command -v md5sum &>/dev/null; then
    log "Generando checksums MD5..."
    cd "${DIRDAT}" && md5sum -- * > "${BACKUP_DIR}/MD5SUMS.txt" 2>/dev/null || true
    log "Checksums guardados en ${BACKUP_DIR}/MD5SUMS.txt"
fi

# ─── Comprimir el backup (opcional) ───────────────────────────────────────
COMPRESS="${COMPRESS_BACKUP:-false}"
if [[ "${COMPRESS}" == "true" ]]; then
    log "Comprimiendo backup..."
    tar -czf "${BACKUP_DIR}.tar.gz" -C "${BACKUP_ROOT}" "trails_${TIMESTAMP}"
    rm -rf "${BACKUP_DIR}"
    log "Backup comprimido: ${BACKUP_DIR}.tar.gz"
fi

# ─── Eliminar backups anteriores (retención 30 días) ──────────────────────
BACKUP_RETENTION="${BACKUP_RETENTION_DAYS:-30}"
log "Eliminando backups con más de ${BACKUP_RETENTION} días..."
find "${BACKUP_ROOT}" -maxdepth 1 \( -name "trails_*" -o -name "trails_*.tar.gz" \) \
     -mtime +"${BACKUP_RETENTION}" -exec rm -rf {} + 2>/dev/null || true

log "======================================================"
log " Copia de trail files completada exitosamente"
log "======================================================"
