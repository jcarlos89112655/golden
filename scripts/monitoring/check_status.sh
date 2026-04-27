#!/usr/bin/env bash
# =============================================================================
# Script  : check_status.sh
# Propósito: Muestra el estado de todos los procesos GoldenGate (Manager,
#            Extract, Pump, Replicat) y los últimos errores del reporte.
# Uso     : bash check_status.sh
# =============================================================================

set -euo pipefail

GG_HOME="${GG_HOME:-/u01/app/oracle/product/19.1.0/oggcore_1}"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "============================================================"
echo " ESTADO DE ORACLE GOLDENGATE  –  ${TIMESTAMP}"
echo "============================================================"

# ─── Manager ─────────────────────────────────────────────────────────────
echo ""
echo "[ MANAGER ]"
"${GG_HOME}/ggsci" <<-'GGSCI'
    INFO MANAGER
    EXIT
GGSCI

# ─── Todos los procesos GG ────────────────────────────────────────────────
echo ""
echo "[ TODOS LOS PROCESOS ]"
"${GG_HOME}/ggsci" <<-'GGSCI'
    INFO ALL
    EXIT
GGSCI

# ─── Lag de cada Extract y Replicat ──────────────────────────────────────
echo ""
echo "[ LAG POR PROCESO ]"
"${GG_HOME}/ggsci" <<-'GGSCI'
    LAG EXTRACT *
    LAG REPLICAT *
    EXIT
GGSCI

# ─── Últimas líneas del reporte del Manager ───────────────────────────────
echo ""
echo "[ ÚLTIMAS 20 LÍNEAS DEL REPORTE DEL MANAGER ]"
MGRRPT=$(find "${GG_HOME}/dirrpt" -name "mgr.rpt" 2>/dev/null | head -1)
if [[ -f "${MGRRPT}" ]]; then
    tail -20 "${MGRRPT}"
else
    echo "  (Archivo mgr.rpt no encontrado)"
fi

echo ""
echo "============================================================"
echo " Fin del reporte de estado"
echo "============================================================"
