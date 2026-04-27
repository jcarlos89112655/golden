-- =============================================================================
-- Script  : 03_grant_privileges.sql
-- Propósito: Otorgar los privilegios mínimos necesarios al usuario GoldenGate
--            en la base de datos FUENTE. Debe ejecutarse como SYSDBA.
-- Versión : Oracle 19c (ajustar para 12c o 21c según corresponda)
-- =============================================================================

-- Sustituir GG_OWNER por C##GG_OWNER si se trabaja en entorno CDB
DEFINE GG_USER = 'GG_OWNER'

-- -----------------------------------------------------------------------
-- Privilegios de sistema
-- -----------------------------------------------------------------------
GRANT CREATE SESSION                  TO &GG_USER;
GRANT ALTER SESSION                   TO &GG_USER;
GRANT SELECT ANY DICTIONARY           TO &GG_USER;
GRANT SELECT ANY TABLE                TO &GG_USER;
GRANT FLASHBACK ANY TABLE             TO &GG_USER;
GRANT EXECUTE ON DBMS_FLASHBACK       TO &GG_USER;

-- Necesario para Extract integrado (12c+)
GRANT LOGMINING                       TO &GG_USER;

-- Necesario para el proceso Manager (creación de objetos de control GG)
GRANT CREATE TABLE                    TO &GG_USER;
GRANT CREATE SEQUENCE                 TO &GG_USER;
GRANT CREATE PROCEDURE                TO &GG_USER;

-- Acceso a los paquetes internos de GoldenGate
GRANT EXECUTE ON DBMS_GOLDENGATE_AUTH TO &GG_USER;

-- -----------------------------------------------------------------------
-- Vistas del diccionario necesarias
-- -----------------------------------------------------------------------
GRANT SELECT ON V_$DATABASE           TO &GG_USER;
GRANT SELECT ON V_$LOG                TO &GG_USER;
GRANT SELECT ON V_$LOGFILE            TO &GG_USER;
GRANT SELECT ON V_$ARCHIVED_LOG       TO &GG_USER;
GRANT SELECT ON V_$ARCHIVE_DEST       TO &GG_USER;
GRANT SELECT ON V_$TRANSACTION        TO &GG_USER;
GRANT SELECT ON V_$SESSION            TO &GG_USER;
GRANT SELECT ON DBA_OBJECTS           TO &GG_USER;
GRANT SELECT ON DBA_TABLES            TO &GG_USER;
GRANT SELECT ON DBA_COLUMNS           TO &GG_USER;
GRANT SELECT ON DBA_CONSTRAINTS       TO &GG_USER;
GRANT SELECT ON DBA_CONS_COLUMNS      TO &GG_USER;
GRANT SELECT ON DBA_LOG_GROUPS        TO &GG_USER;
GRANT SELECT ON DBA_LOG_GROUP_COLUMNS TO &GG_USER;
GRANT SELECT ON DBA_SEQUENCES         TO &GG_USER;
GRANT SELECT ON DBA_INDEXES           TO &GG_USER;
GRANT SELECT ON DBA_INDEX_COLUMNS     TO &GG_USER;
GRANT SELECT ON DBA_USERS             TO &GG_USER;
GRANT SELECT ON DBA_SEGMENTS          TO &GG_USER;

-- -----------------------------------------------------------------------
-- Otorgar rol GOLDENGATE_PRIVS si existe (19c+)
-- -----------------------------------------------------------------------
-- GRANT GOLDENGATE_PRIVS TO &GG_USER;  -- Descomentar si está disponible

-- -----------------------------------------------------------------------
-- Registrar el usuario en GoldenGate (ejecutar en GGSCI antes de arrancar)
-- DBLOGIN USERID gg_owner, PASSWORD GG_Owner#2024
-- REGISTER EXTRACT ext_src DATABASE
-- -----------------------------------------------------------------------

COMMIT;
