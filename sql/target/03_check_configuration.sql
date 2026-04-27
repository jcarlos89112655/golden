-- =============================================================================
-- Script  : 03_check_configuration.sql
-- Propósito: Verificar la configuración de la BD destino para GoldenGate.
-- Versión : Oracle 12.2+
-- =============================================================================

PROMPT ============================================================
PROMPT  VERIFICACIÓN DE CONFIGURACIÓN GOLDENGATE – BASE DE DATOS DESTINO
PROMPT ============================================================

-- 1. Usuario GoldenGate Apply
PROMPT
PROMPT [1] Usuario GoldenGate Apply:
SELECT USERNAME, ACCOUNT_STATUS, DEFAULT_TABLESPACE
FROM DBA_USERS
WHERE USERNAME IN ('GG_APPLY');

-- 2. Tablas de checkpoint (deben existir tras ADD CHECKPOINTTABLE)
PROMPT
PROMPT [2] Tablas de checkpoint GoldenGate:
SELECT OWNER, TABLE_NAME, CREATED
FROM DBA_TABLES
WHERE OWNER = 'GG_APPLY'
  AND TABLE_NAME LIKE '%CHKPT%';

-- 3. Tablas heartbeat (deben existir tras ADD HEARTBEATTABLE)
PROMPT
PROMPT [3] Tablas de Heartbeat GoldenGate:
SELECT OWNER, TABLE_NAME, CREATED
FROM DBA_TABLES
WHERE TABLE_NAME IN (
    'GGS_HEARTBEAT',
    'GGS_HEARTBEAT_HISTORY'
);

-- 4. Parámetro GoldenGate (opcional en destino, recomendado habilitarlo)
PROMPT
PROMPT [4] Parámetro ENABLE_GOLDENGATE_REPLICATION:
SELECT NAME, VALUE FROM V$PARAMETER WHERE NAME = 'enable_goldengate_replication';

-- 5. Verificar objetos del schema objetivo
PROMPT
PROMPT [5] Tablas del schema objetivo (APP_OWNER):
SELECT TABLE_NAME, NUM_ROWS, LAST_ANALYZED
FROM DBA_TABLES
WHERE OWNER = 'APP_OWNER'
ORDER BY TABLE_NAME;

PROMPT
PROMPT ============================================================
PROMPT  Fin de verificación
PROMPT ============================================================
