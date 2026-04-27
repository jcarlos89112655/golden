-- =============================================================================
-- Script  : 02_grant_privileges.sql
-- Propósito: Otorgar privilegios al usuario GoldenGate en la BD DESTINO.
--            Debe ejecutarse como SYSDBA.
-- Versión : Oracle 19c
-- =============================================================================

DEFINE GG_APPLY = 'GG_APPLY'
DEFINE SCHEMA_OWNER = 'APP_OWNER'   -- Schema cuyas tablas se van a replicar

-- -----------------------------------------------------------------------
-- Privilegios de sistema
-- -----------------------------------------------------------------------
GRANT CREATE SESSION                  TO &GG_APPLY;
GRANT ALTER SESSION                   TO &GG_APPLY;
GRANT SELECT ANY DICTIONARY           TO &GG_APPLY;
GRANT CREATE TABLE                    TO &GG_APPLY;
GRANT CREATE SEQUENCE                 TO &GG_APPLY;
GRANT CREATE PROCEDURE                TO &GG_APPLY;

-- Privilegios sobre el schema objetivo
GRANT INSERT, UPDATE, DELETE, SELECT ON &SCHEMA_OWNER.ORDERS      TO &GG_APPLY;
GRANT INSERT, UPDATE, DELETE, SELECT ON &SCHEMA_OWNER.ORDER_ITEMS TO &GG_APPLY;
GRANT INSERT, UPDATE, DELETE, SELECT ON &SCHEMA_OWNER.CUSTOMERS   TO &GG_APPLY;
-- Agregar aquí el resto de tablas que se replican

-- Alternativamente, si GG_APPLY es dueño del schema destino:
-- GRANT RESOURCE, CONNECT TO &GG_APPLY;

-- -----------------------------------------------------------------------
-- Permitir al Replicat manejar conflictos y errores
-- -----------------------------------------------------------------------
GRANT EXECUTE ON DBMS_GOLDENGATE_AUTH TO &GG_APPLY;
GRANT EXECUTE ON UTL_FILE             TO &GG_APPLY;

-- -----------------------------------------------------------------------
-- Tablas de control de GoldenGate (checkpoint, heartbeat)
-- -----------------------------------------------------------------------
-- GoldenGate crea automáticamente las tablas de checkpoint si se usa:
-- ADD CHECKPOINTTABLE gg_apply.gg_chkpt  (desde GGSCI)
-- Las tablas heartbeat se crean con: ADD HEARTBEATTABLE

COMMIT;
