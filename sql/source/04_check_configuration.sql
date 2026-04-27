-- =============================================================================
-- Script  : 04_check_configuration.sql
-- Propósito: Verificar que la base de datos fuente está correctamente
--            configurada para Oracle GoldenGate.
-- Versión : Oracle 12.2+
-- =============================================================================

PROMPT ============================================================
PROMPT  VERIFICACIÓN DE CONFIGURACIÓN GOLDENGATE – BASE DE DATOS FUENTE
PROMPT ============================================================

-- 1. Modo de archivado
PROMPT
PROMPT [1] Modo ARCHIVELOG (debe ser ARCHIVELOG):
SELECT LOG_MODE FROM V$DATABASE;

-- 2. Supplemental logging
PROMPT
PROMPT [2] Supplemental Logging (MIN debe ser YES):
SELECT
    SUPPLEMENTAL_LOG_DATA_MIN AS MIN_LOG,
    SUPPLEMENTAL_LOG_DATA_PK  AS PK_LOG,
    SUPPLEMENTAL_LOG_DATA_UI  AS UI_LOG,
    SUPPLEMENTAL_LOG_DATA_FK  AS FK_LOG,
    SUPPLEMENTAL_LOG_DATA_ALL AS ALL_LOG
FROM V$DATABASE;

-- 3. Parámetro GoldenGate
PROMPT
PROMPT [3] Parámetro ENABLE_GOLDENGATE_REPLICATION (debe ser TRUE):
SELECT NAME, VALUE FROM V$PARAMETER WHERE NAME = 'enable_goldengate_replication';

-- 4. Usuario GoldenGate
PROMPT
PROMPT [4] Usuario GoldenGate (debe existir):
SELECT USERNAME, ACCOUNT_STATUS, DEFAULT_TABLESPACE
FROM DBA_USERS
WHERE USERNAME IN ('GG_OWNER', 'C##GG_OWNER');

-- 5. Redo logs y archivos de log
PROMPT
PROMPT [5] Redo log groups y estado:
SELECT GROUP#, MEMBERS, BYTES/1024/1024 AS SIZE_MB, STATUS
FROM V$LOG
ORDER BY GROUP#;

-- 6. Destino de archived logs
PROMPT
PROMPT [6] Destino de Archive Logs:
SELECT DEST_ID, STATUS, TARGET, ARCHIVER, DESTINATION
FROM V$ARCHIVE_DEST
WHERE STATUS = 'VALID';

-- 7. Supplemental logging a nivel de tabla (muestra primeras 20)
PROMPT
PROMPT [7] Supplemental logging por tabla (primeras 20 tablas con log adicional):
SELECT OWNER, LOG_GROUP_NAME, TABLE_NAME, LOG_GROUP_TYPE
FROM DBA_LOG_GROUPS
WHERE OWNER NOT IN ('SYS','SYSTEM','AUDSYS','DBSNMP','OUTLN')
  AND ROWNUM <= 20
ORDER BY OWNER, TABLE_NAME;

PROMPT
PROMPT ============================================================
PROMPT  Fin de verificación
PROMPT ============================================================
