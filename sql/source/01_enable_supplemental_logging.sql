-- =============================================================================
-- Script  : 01_enable_supplemental_logging.sql
-- Propósito: Habilitar ARCHIVELOG y supplemental logging mínimo en la base de
--            datos fuente. Debe ejecutarse como SYSDBA.
-- Versión : Oracle 12.2+
-- =============================================================================

-- 1. Verificar modo ARCHIVELOG
SELECT LOG_MODE FROM V$DATABASE;
-- Si el resultado es NOARCHIVELOG, ejecutar los pasos comentados a continuación:
-- SHUTDOWN IMMEDIATE;
-- STARTUP MOUNT;
-- ALTER DATABASE ARCHIVELOG;
-- ALTER DATABASE OPEN;

-- 2. Habilitar supplemental logging mínimo a nivel de base de datos
--    (obligatorio para GoldenGate)
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;

-- 3. Habilitar supplemental logging para PRIMARY KEY y UNIQUE INDEX
--    (recomendado para captura exacta de cambios en tablas con PK)
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (PRIMARY KEY, UNIQUE) COLUMNS;

-- 4. Habilitar ENABLE_GOLDENGATE_REPLICATION (12c+)
--    Permite al Extract acceder a los redo logs sin necesidad de LogMiner
ALTER SYSTEM SET ENABLE_GOLDENGATE_REPLICATION = TRUE SCOPE=BOTH;

-- 5. Verificar configuración final
SELECT
    SUPPLEMENTAL_LOG_DATA_MIN    AS SUPP_LOG_MIN,
    SUPPLEMENTAL_LOG_DATA_PK     AS SUPP_LOG_PK,
    SUPPLEMENTAL_LOG_DATA_UI     AS SUPP_LOG_UI,
    SUPPLEMENTAL_LOG_DATA_FK     AS SUPP_LOG_FK,
    SUPPLEMENTAL_LOG_DATA_ALL    AS SUPP_LOG_ALL,
    LOG_MODE
FROM V$DATABASE;

SELECT NAME, VALUE
FROM V$PARAMETER
WHERE NAME = 'enable_goldengate_replication';

COMMIT;
