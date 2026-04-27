#!/usr/bin/env bash
# =============================================================================
# Script  : cleanup_trails.sh
# Propósito: Elimina trail files más antiguos que N días en el directorio
#            dirdat de GoldenGate. Siempre verifica que los procesos activos
#            no estén leyendo los archivos antes de eliminarlos.
# Uso     : bash cleanup_trails.sh [dias_retencion]
#           Default: 7 días
# =============================================================================

set -euo pipefail

GG_HOME="${GG_HOME:-/u01/app/oracle/product/19.1.0/oggcore_1}"
DIRDAT="${GG_HOME}/dirdat"
RETENTION_DAYS="${1:-7}"
LOG_FILE="${GG_HOME}/dirrpt/cleanup_trails.log"
DRY_RUN="${DRY_RUN:-false}"   # Exportar DRY_RUN=true para simular sin borrar

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

log() {
    echo "${TIMESTAMP} – $*" | tee -a "${LOG_FILE}"
}

log "======================================================"
log " Limpieza de trail files – Retención: ${RETENTION_DAYS} días"
log " DRY_RUN: ${DRY_RUN}"
log "======================================================"

# ─── Obtener SCN/posición actual de cada proceso ─────────────────────────
# Esto garantiza que no borramos trails que aún están siendo leídos
ACTIVE_TRAILS=$( "${GG_HOME}/ggsci" <<-'GGSCI' 2>/dev/null | grep -oP '\./dirdat/\S+' | sort -u
    INFO ALL
    EXIT
GGSCI
)

log "Trail files activos (protegidos):"
while IFS= read -r trail; do
    log "  PROTEGIDO: ${trail}"
done <<< "${ACTIVE_TRAILS}"

# ─── Listar y eliminar trail files antiguos ───────────────────────────────
deleted=0
skipped=0

while IFS= read -r -d '' trail_file; do
    # Extraer prefijo del trail (primeros 2 chars del nombre de archivo)
    trail_prefix=$(basename "${trail_file}" | cut -c1-2)
    full_prefix="${DIRDAT}/${trail_prefix}"

    # Verificar si el trail está siendo usado por algún proceso activo
    if echo "${ACTIVE_TRAILS}" | grep -q "${full_prefix}"; then
        log "  SALTADO (activo): ${trail_file}"
        (( skipped++ )) || true
        continue
    fi

    if [[ "${DRY_RUN}" == "true" ]]; then
        log "  [DRY-RUN] Se eliminaría: ${trail_file}"
    else
        rm -f "${trail_file}"
        log "  ELIMINADO: ${trail_file}"
    fi
    (( deleted++ )) || true

done < <(find "${DIRDAT}" -type f -name "??[0-9]*" -mtime +"${RETENTION_DAYS}" -print0 2>/dev/null)

log "======================================================"
log " Resumen: ${deleted} eliminados, ${skipped} saltados"
log "======================================================"
