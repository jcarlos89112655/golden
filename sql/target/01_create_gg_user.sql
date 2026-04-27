-- =============================================================================
-- Script  : 01_create_gg_user.sql
-- Propósito: Crear el usuario dedicado para Oracle GoldenGate en la BD destino.
--            Debe ejecutarse como SYSDBA.
-- Versión : Oracle 12.2+
-- =============================================================================

-- El usuario destino de GoldenGate aplica los cambios, no lee redo logs,
-- por lo que puede ser un usuario local (no necesita ser Common User en CDB).
-- Sin embargo, necesita privilegios de escritura sobre los schemas objetivo.

-- -----------------------------------------------------------------------
-- Opción A: Base de datos NO CDB
-- -----------------------------------------------------------------------
CREATE USER gg_apply
    IDENTIFIED BY "GG_Apply#2024"   -- ¡Cambiar por una contraseña segura!
    DEFAULT TABLESPACE users
    TEMPORARY TABLESPACE temp
    QUOTA UNLIMITED ON users;

-- -----------------------------------------------------------------------
-- Opción B: Base de datos CDB (Target en PDB)
-- -----------------------------------------------------------------------
-- ALTER SESSION SET CONTAINER = <PDB_DESTINO>;
-- CREATE USER gg_apply
--     IDENTIFIED BY "GG_Apply#2024"
--     DEFAULT TABLESPACE users
--     TEMPORARY TABLESPACE temp
--     QUOTA UNLIMITED ON users;

COMMIT;
