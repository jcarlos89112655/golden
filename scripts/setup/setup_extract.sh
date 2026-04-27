#!/usr/bin/env bash
# =============================================================================
# Script  : setup_extract.sh
# Propósito: Registrar y configurar el proceso EXTRACT en GoldenGate desde
#            la línea de comandos GGSCI.
# Uso     : bash setup_extract.sh [classic|integrated]
#           Por defecto: integrated
# =============================================================================

set -euo pipefail

# ─── Variables ───────────────────────────────────────────────────────────────
GG_HOME="${GG_HOME:-/u01/app/oracle/product/19.1.0/oggcore_1}"
EXTRACT_NAME="${EXTRACT_NAME:-EXTINT}"
EXTRACT_TYPE="${1:-integrated}"       # classic | integrated
TRAIL_PREFIX="./dirdat/it"
GG_USER="gg_owner"
GG_ALIAS="gg_src_alias"
GG_PASSWD_FILE="${GG_HOME}/dirwlt/.passwd"   # archivo de credencial cifrada

# Determinar parámetro según tipo
if [[ "${EXTRACT_TYPE}" == "integrated" ]]; then
    EXTRACT_TYPE_FLAG="INTEGRATED TRANLOG"
    PARAM_FILE="params/extract/ext_integrated.prm"
else
    EXTRACT_TYPE_FLAG="TRANLOG"
    PARAM_FILE="params/extract/ext_classic.prm"
fi

echo "======================================================"
echo " Configurando EXTRACT '${EXTRACT_NAME}' (${EXTRACT_TYPE})"
echo "======================================================"

# ─── Copiar archivo de parámetros ─────────────────────────────────────────
cp "${PARAM_FILE}" "${GG_HOME}/dirprm/${EXTRACT_NAME,,}.prm"
echo "[OK] Archivo de parámetros copiado a ${GG_HOME}/dirprm/${EXTRACT_NAME,,}.prm"

# ─── Ejecutar comandos GGSCI ──────────────────────────────────────────────
"${GG_HOME}/ggsci" <<-GGSCI_CMDS
    -- Conectar a la base de datos fuente
    DBLOGIN USERIDALIAS ${GG_ALIAS} DOMAIN OracleGoldenGate

    -- Registrar el Extract (solo modo integrado)
    $(if [[ "${EXTRACT_TYPE}" == "integrated" ]]; then
        echo "REGISTER EXTRACT ${EXTRACT_NAME} DATABASE"
    fi)

    -- Agregar el Extract
    ADD EXTRACT ${EXTRACT_NAME}, ${EXTRACT_TYPE_FLAG}, BEGIN NOW

    -- Agregar el trail file local
    ADD EXTTRAIL ${TRAIL_PREFIX}, EXTRACT ${EXTRACT_NAME}, MEGABYTES 500

    -- Iniciar el Extract
    START EXTRACT ${EXTRACT_NAME}

    -- Verificar estado
    INFO EXTRACT ${EXTRACT_NAME}, DETAIL

    EXIT
GGSCI_CMDS

echo "======================================================"
echo " EXTRACT '${EXTRACT_NAME}' configurado y arrancado."
echo " Verificar con: INFO EXTRACT ${EXTRACT_NAME}, DETAIL"
echo "======================================================"
