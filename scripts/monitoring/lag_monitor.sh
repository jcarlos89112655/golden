#!/usr/bin/env bash
# =============================================================================
# Script  : lag_monitor.sh
# Propósito: Monitorea el lag de los procesos GoldenGate en tiempo real.
#            Envía una alerta por correo o escribe en un archivo de log
#            si el lag supera el umbral definido.
# Uso     : bash lag_monitor.sh [intervalo_segundos] [umbral_segundos]
#           Defaults: intervalo=60s, umbral=300s (5 minutos)
# =============================================================================

set -euo pipefail

GG_HOME="${GG_HOME:-/u01/app/oracle/product/19.1.0/oggcore_1}"
INTERVAL="${1:-60}"         # Intervalo entre comprobaciones (segundos)
LAG_THRESHOLD="${2:-300}"   # Umbral de lag en segundos (alerta si se supera)
LOG_FILE="${GG_HOME}/dirrpt/lag_monitor.log"
ALERT_EMAIL="${ALERT_EMAIL:-dba-team@example.com}"

# Función para obtener lag en segundos desde la salida de GGSCI
get_lag_seconds() {
    local process_type="$1"  # EXTRACT | REPLICAT
    local process_name="$2"

    local lag_str
    lag_str=$( "${GG_HOME}/ggsci" <<-GGSCI 2>/dev/null | grep -i "^LAG" | head -1
        INFO ${process_type} ${process_name}
        EXIT
GGSCI
    )

    # Formato de lag: "HH:MM:SS" – usar patrones POSIX para máxima portabilidad
    local hh mm ss
    hh=$(echo "${lag_str}" | grep -o '[0-9][0-9]:[0-9][0-9]:[0-9][0-9]' | head -1 | cut -d: -f1 || echo "0")
    mm=$(echo "${lag_str}" | grep -o '[0-9][0-9]:[0-9][0-9]:[0-9][0-9]' | head -1 | cut -d: -f2 || echo "0")
    ss=$(echo "${lag_str}" | grep -o '[0-9][0-9]:[0-9][0-9]:[0-9][0-9]' | head -1 | cut -d: -f3 || echo "0")

    echo $(( hh * 3600 + mm * 60 + ss ))
}

send_alert() {
    local msg="$1"
    local ts
    ts=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[ALERTA] ${ts} – ${msg}" | tee -a "${LOG_FILE}"

    # Enviar correo si sendmail/mailx está disponible
    if command -v mailx &>/dev/null; then
        echo "${msg}" | mailx -s "[GoldenGate ALERT] Lag elevado – $(hostname)" "${ALERT_EMAIL}" || true
    fi
}

echo "======================================================="
echo " Monitor de lag GoldenGate iniciado"
echo " Intervalo: ${INTERVAL}s | Umbral: ${LAG_THRESHOLD}s"
echo " Log: ${LOG_FILE}"
echo "======================================================="

while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    # Obtener lista de procesos activos
    PROCESSES=$( "${GG_HOME}/ggsci" <<-'GGSCI' 2>/dev/null | grep -E "^(EXTRACT|REPLICAT)" | awk '{print $1, $2}'
        INFO ALL
        EXIT
GGSCI
    )

    while IFS=' ' read -r proc_type proc_name; do
        [[ -z "${proc_name}" ]] && continue

        lag_sec=$(get_lag_seconds "${proc_type}" "${proc_name}" || echo "0")
        lag_fmt=$(printf '%02d:%02d:%02d' $((lag_sec/3600)) $(( (lag_sec%3600)/60 )) $((lag_sec%60)))

        echo "${TIMESTAMP} | ${proc_type} ${proc_name} | Lag: ${lag_fmt} (${lag_sec}s)" | tee -a "${LOG_FILE}"

        if (( lag_sec > LAG_THRESHOLD )); then
            send_alert "${proc_type} ${proc_name} tiene un lag de ${lag_fmt} (${lag_sec}s), que supera el umbral de ${LAG_THRESHOLD}s"
        fi
    done <<< "${PROCESSES}"

    echo "-------------------------------------------------------" | tee -a "${LOG_FILE}"
    sleep "${INTERVAL}"
done
