-- =============================================================================
-- Script  : 02_create_gg_user.sql
-- Propósito: Crear el usuario dedicado para Oracle GoldenGate en la BD fuente.
--            Debe ejecutarse como SYSDBA.
-- Versión : Oracle 12.2+  (Common User en CDB, Local User en PDB)
-- =============================================================================

-- NOTA: En arquitectura CDB, crear el usuario como Common User (C##GG_OWNER)
--       para que tenga visibilidad de los redo logs del contenedor raíz.
--       En base de datos no-CDB, usar simplemente GG_OWNER.

-- -----------------------------------------------------------------------
-- Opción A: Base de datos NO CDB (12.1 y anteriores, o non-CDB 12.2/19c)
-- -----------------------------------------------------------------------
-- Ajustar tablespace y cuota según la instalación
CREATE USER gg_owner
    IDENTIFIED BY "GG_Owner#2024"   -- ¡Cambiar por una contraseña segura!
    DEFAULT TABLESPACE users
    TEMPORARY TABLESPACE temp
    QUOTA UNLIMITED ON users;

-- -----------------------------------------------------------------------
-- Opción B: Base de datos CDB (comentar opción A y descomentar ésta)
-- -----------------------------------------------------------------------
-- ALTER SESSION SET CONTAINER = CDB$ROOT;
-- CREATE USER c##gg_owner
--     IDENTIFIED BY "GG_Owner#2024"
--     DEFAULT TABLESPACE users
--     TEMPORARY TABLESPACE temp
--     QUOTA UNLIMITED ON users
--     CONTAINER = ALL;

COMMIT;
