# Diagnóstico y Resolución de Problemas – Oracle GoldenGate

## Índice

1. [Diagnóstico inicial](#diagnóstico-inicial)
2. [Problemas de Extract](#problemas-de-extract)
3. [Problemas de Pump](#problemas-de-pump)
4. [Problemas de Replicat](#problemas-de-replicat)
5. [Problemas de lag](#problemas-de-lag)
6. [Errores comunes de base de datos](#errores-comunes-de-base-de-datos)
7. [Comandos útiles de GGSCI](#comandos-útiles-de-ggsci)

---

## Diagnóstico Inicial

El primer paso siempre es revisar el estado de los procesos y sus reportes:

```bash
# Entrar a GGSCI
cd $GG_HOME && ./ggsci

# Ver estado de todos los procesos
GGSCI> INFO ALL

# Ver estado detallado de un proceso
GGSCI> INFO EXTRACT EXTINT, DETAIL
GGSCI> INFO REPLICAT REPINT, DETAIL

# Ver el lag actual
GGSCI> LAG EXTRACT *
GGSCI> LAG REPLICAT *

# Ver las últimas líneas del reporte de un proceso
GGSCI> VIEW REPORT EXTINT
GGSCI> VIEW REPORT REPINT
```

---

## Problemas de Extract

### Error: `OGG-01224` – Address already in use

**Causa**: El Manager intenta abrir un puerto ya en uso.

**Solución**:
1. Verificar qué proceso usa el puerto: `ss -tlnp | grep 7809`
2. Cambiar el `PORT` en `mgr.prm` o detener el proceso conflictivo.

---

### Error: `OGG-00446` – Could not find archived log

**Causa**: El Extract no puede encontrar el archived log requerido para continuar la captura.

**Solución**:
```sql
-- Verificar que el log existe
SELECT NAME, SEQUENCE#, FIRST_CHANGE#, NEXT_CHANGE#
FROM V$ARCHIVED_LOG
WHERE SEQUENCE# BETWEEN <seq_anterior> AND <seq_actual>
ORDER BY SEQUENCE#;

-- Si faltan logs, hacer initial load desde ese punto y reiniciar el Extract
```

---

### Error: `OGG-01028` – No active redo thread found

**Causa**: El Extract integrado no puede conectarse al servidor LogMiner.

**Solución**:
```sql
-- Verificar privilegio LOGMINING
SELECT GRANTEE, PRIVILEGE FROM DBA_SYS_PRIVS WHERE PRIVILEGE = 'LOGMINING';

-- Verificar que el parámetro GoldenGate está activo
SELECT NAME, VALUE FROM V$PARAMETER WHERE NAME = 'enable_goldengate_replication';

-- En GGSCI: re-registrar el Extract
DBLOGIN USERIDALIAS gg_src_alias DOMAIN OracleGoldenGate
UNREGISTER EXTRACT EXTINT DATABASE
REGISTER EXTRACT EXTINT DATABASE
```

---

### Error: `OGG-02024` – No tables found matching specification

**Causa**: Las tablas especificadas en el `TABLE` del parámetro no existen o el usuario no tiene acceso.

**Solución**:
```sql
-- Verificar que las tablas existen
SELECT OWNER, TABLE_NAME FROM DBA_TABLES WHERE OWNER = 'APP_OWNER';

-- Verificar que el usuario GG tiene SELECT
SELECT * FROM DBA_TAB_PRIVS WHERE GRANTEE = 'GG_OWNER';
```

---

## Problemas de Pump

### Error: `OGG-00664` – TCP/IP error, Connection refused

**Causa**: El Manager del servidor destino no está activo o no acepta conexiones.

**Solución**:
```bash
# En el servidor destino
cd $GG_HOME && ./ggsci
GGSCI> START MANAGER
GGSCI> INFO MANAGER

# Verificar firewall
telnet gg-target-host 7809
```

---

### Error: `OGG-01201` – Error opening trail file

**Causa**: El trail file local no existe o tiene permisos incorrectos.

**Solución**:
```bash
# Verificar trail files existentes
ls -lh $GG_HOME/dirdat/

# Verificar permisos del usuario de SO que ejecuta GoldenGate
stat $GG_HOME/dirdat/lt000001
```

---

## Problemas de Replicat

### Error: `OGG-01163` – Bad column index

**Causa**: La definición de columnas en el trail no coincide con la tabla destino (cambio de DDL no replicado).

**Solución**:
```bash
# Generar el archivo de definición de fuente
cd $GG_HOME && ./ggsci
GGSCI> DBLOGIN USERIDALIAS gg_src_alias DOMAIN OracleGoldenGate
GGSCI> DEFGEN TABLE APP_OWNER.ORDERS, NOSCHEDULETASKS
# Copiar el archivo defs al servidor destino y referenciar con SOURCEDEFS
```

---

### Error: `OGG-01004` – Aborted grouped transaction on... ORA-00001: unique constraint violated

**Causa**: El Replicat intenta insertar un registro que ya existe en el destino (conflicto de duplicado).

**Solución** (en `rep_classic.prm` o `rep_integrated.prm`):
```
-- Ignorar duplicados en INSERT (idempotencia)
MAP APP_OWNER.ORDERS, TARGET APP_OWNER.ORDERS,
    RESOLVECONFLICT (INSERTROWEXISTS, (DEFAULT, DISCARD));

-- O aplicar la estrategia "el más reciente gana" en UPDATE
RESOLVECONFLICT (UPDATEROWEXISTS, (DEFAULT, USEMAX (LAST_UPDATED)));
```

---

### Error: `ORA-01403` – No data found (en DELETE)

**Causa**: El Replicat intenta eliminar un registro que no existe en el destino.

**Solución** (`REPERROR`):
```
REPERROR (1403, DISCARD)
DISCARDFILE ./dirrpt/repint.dsc, APPEND, MEGABYTES 500
```

---

## Problemas de Lag

### Lag elevado en el Extract

**Diagnóstico**:
```bash
GGSCI> STATS EXTRACT EXTINT, TOTAL
GGSCI> LAG EXTRACT EXTINT
```

**Causas comunes**:
- Transacciones largas en el origen (transacciones de más de 30 min).
- Archived logs no disponibles localmente (archive log en NFS lento).
- Insuficiente memoria (`CACHEMGR CACHESIZE`).

**Soluciones**:
```
-- Aumentar el caché del Extract
CACHEMGR CACHESIZE 4096MB

-- Verificar transacciones largas
SELECT SID, SERIAL#, STATUS, TO_CHAR(LOGON_TIME,'DD/MM HH24:MI') LOGON,
       LAST_CALL_ET/60 ELAPSED_MIN, SQL_ID
FROM V$SESSION WHERE STATUS = 'ACTIVE' AND LAST_CALL_ET > 1800
ORDER BY LAST_CALL_ET DESC;
```

### Lag elevado en el Replicat

**Diagnóstico**:
```bash
GGSCI> STATS REPLICAT REPINT, TOTAL
```

**Causas comunes**:
- Índices faltantes en la tabla destino.
- Bloqueos (locks) en la base de datos destino.
- `GROUPTRANSOPS` demasiado bajo.

**Soluciones**:
```sql
-- Verificar índices en tablas destino (deben coincidir con las claves PK/UK del origen)
SELECT INDEX_NAME, UNIQUENESS FROM DBA_INDEXES WHERE TABLE_NAME = 'ORDERS';

-- Verificar bloqueos
SELECT L.SID, S.USERNAME, L.TYPE, L.MODE_HELD, L.MODE_REQUESTED
FROM V$LOCK L JOIN V$SESSION S ON L.SID = S.SID
WHERE S.USERNAME = 'GG_APPLY';
```

---

## Errores Comunes de Base de Datos

| Error Oracle | Descripción | Acción recomendada |
|---|---|---|
| `ORA-00054` | Resource busy (NOWAIT) | Esperar o aumentar `GROUPTRANSOPS` |
| `ORA-01555` | Snapshot too old | Aumentar UNDO tablespace |
| `ORA-08177` | Can't serialize access | Revisar aislamiento de transacciones |
| `ORA-04031` | Insufficient shared memory | Aumentar `shared_pool_size` |
| `ORA-12541` | TNS no listener | Verificar listener en servidor destino |

---

## Comandos Útiles de GGSCI

```bash
# ─── Manager ─────────────────────────────────────────────────────
START MANAGER
STOP MANAGER
INFO MANAGER

# ─── Extract ─────────────────────────────────────────────────────
START EXTRACT <nombre>
STOP EXTRACT <nombre>
STATUS EXTRACT <nombre>
INFO EXTRACT <nombre>, DETAIL
STATS EXTRACT <nombre>, TOTAL
LAG EXTRACT <nombre>
SEND EXTRACT <nombre>, STATUS
ALTER EXTRACT <nombre>, BEGIN NOW

# ─── Replicat ────────────────────────────────────────────────────
START REPLICAT <nombre>
STOP REPLICAT <nombre>
STATUS REPLICAT <nombre>
INFO REPLICAT <nombre>, DETAIL
STATS REPLICAT <nombre>, TOTAL
LAG REPLICAT <nombre>
SEND REPLICAT <nombre>, STATUS

# ─── Trail Files ─────────────────────────────────────────────────
INFO EXTRACT <nombre>, SHOWCH          -- Mostrar trail files con checkpoints
LIST TRAILS                            -- Listar todos los trails activos

# ─── Credenciales ────────────────────────────────────────────────
ADD CREDENTIALSTORE
ALTER CREDENTIALSTORE ADD USER gg_owner@ORCL_SRC, PASSWORD GG_Owner#2024, ALIAS gg_src_alias DOMAIN OracleGoldenGate
INFO CREDENTIALSTORE

# ─── Checkpoint Table ────────────────────────────────────────────
ADD CHECKPOINTTABLE gg_apply.gg_chkpt
DELETE CHECKPOINTTABLE gg_apply.gg_chkpt CHECKPOINTONLY

# ─── Heartbeat ───────────────────────────────────────────────────
ADD HEARTBEATTABLE
INFO HEARTBEATTABLE
```
