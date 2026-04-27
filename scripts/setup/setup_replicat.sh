#!/usr/bin/env bash
# =============================================================================
# Script  : setup_replicat.sh
# Propósito: Registrar y configurar el proceso REPLICAT en GoldenGate desde
#            la línea de comandos GGSCI.
# Uso     : bash setup_replicat.sh [classic|integrated]
#           Por defecto: integrated
# =============================================================================

set -euo pipefail

# ─── Variables ───────────────────────────────────────────────────────────────
GG_HOME="${GG_HOME:-/u01/app/oracle/product/19.1.0/oggcore_1}"
REPLICAT_NAME="${REPLICAT_NAME:-REPINT}"
REPLICAT_TYPE="${1:-integrated}"       # classic | integrated
TRAIL_PREFIX="./dirdat/rt"
GG_ALIAS="gg_tgt_alias"
CHKPT_TABLE="gg_apply.gg_chkpt"

# Determinar flag según tipo
if [[ "${REPLICAT_TYPE}" == "integrated" ]]; then
    REPLICAT_FLAG="INTEGRATED"
    PARAM_FILE="params/replicat/rep_integrated.prm"
else
    REPLICAT_FLAG=""
    PARAM_FILE="params/replicat/rep_classic.prm"
fi

echo "======================================================"
echo " Configurando REPLICAT '${REPLICAT_NAME}' (${REPLICAT_TYPE})"
echo "======================================================"

# ─── Copiar archivo de parámetros ─────────────────────────────────────────
cp "${PARAM_FILE}" "${GG_HOME}/dirprm/${REPLICAT_NAME,,}.prm"
echo "[OK] Archivo de parámetros copiado a ${GG_HOME}/dirprm/${REPLICAT_NAME,,}.prm"

# ─── Ejecutar comandos GGSCI ──────────────────────────────────────────────
"${GG_HOME}/ggsci" <<-GGSCI_CMDS
    -- Conectar a la base de datos destino
    DBLOGIN USERIDALIAS ${GG_ALIAS} DOMAIN OracleGoldenGate

    -- Crear tabla de checkpoint (si no existe)
    ADD CHECKPOINTTABLE ${CHKPT_TABLE}

    -- Agregar el Replicat
    ADD REPLICAT ${REPLICAT_NAME}, ${REPLICAT_FLAG} EXTTRAIL ${TRAIL_PREFIX}, CHECKPOINTTABLE ${CHKPT_TABLE}

    -- Iniciar el Replicat
    START REPLICAT ${REPLICAT_NAME}

    -- Verificar estado
    INFO REPLICAT ${REPLICAT_NAME}, DETAIL

    EXIT
GGSCI_CMDS

echo "======================================================"
echo " REPLICAT '${REPLICAT_NAME}' configurado y arrancado."
echo " Verificar con: INFO REPLICAT ${REPLICAT_NAME}, DETAIL"
echo "======================================================"
