# Mejores Prácticas – Oracle GoldenGate en Producción

## Índice

1. [Seguridad](#seguridad)
2. [Rendimiento](#rendimiento)
3. [Alta disponibilidad](#alta-disponibilidad)
4. [Gestión de trail files](#gestión-de-trail-files)
5. [Monitoreo](#monitoreo)
6. [Mantenimiento preventivo](#mantenimiento-preventivo)
7. [DDL Replication](#ddl-replication)
8. [Initial Load](#initial-load)

---

## Seguridad

### Credenciales cifradas (Credential Store)

Nunca almacenar contraseñas en texto plano en los archivos `.prm`. Usar el **Credential Store** de GoldenGate:

```bash
GGSCI> ADD CREDENTIALSTORE
GGSCI> ALTER CREDENTIALSTORE ADD USER gg_owner@ORCL_SRC, PASSWORD <pwd>, ALIAS gg_src_alias DOMAIN OracleGoldenGate
GGSCI> ALTER CREDENTIALSTORE ADD USER gg_apply@ORCL_TGT, PASSWORD <pwd>, ALIAS gg_tgt_alias DOMAIN OracleGoldenGate
```

En los archivos `.prm`:
```
-- Correcto
USERIDALIAS gg_src_alias DOMAIN OracleGoldenGate

-- Incorrecto (NO usar en producción)
USERID gg_owner@ORCL_SRC, PASSWORD plaintext_password
```

### Principio de mínimo privilegio

Otorgar únicamente los privilegios necesarios al usuario GoldenGate. Evitar roles como `DBA` o `SYSDBA` a menos que sea estrictamente requerido.

### Cifrado de trail files y comunicación de red

```
-- En el archivo de parámetros del Pump
RMTHOST target-host, MGRPORT 7809, ENCRYPT AES256, KEYNAME oggkey
```

Para cifrar los trail files locales:
```
-- En mgr.prm
ENCRYPTTRAIL AES256
```

---

## Rendimiento

### Supplemental Logging granular

Habilitar supplemental logging **solo en las tablas que se replican**, no a nivel global, para reducir el tamaño de los redo logs:

```sql
-- Solo para tablas específicas
ALTER TABLE app_owner.orders ADD SUPPLEMENTAL LOG DATA (PRIMARY KEY) COLUMNS;
ALTER TABLE app_owner.orders ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS; -- solo si no hay PK
```

### Ajuste de CACHEMGR

Ajustar el tamaño del caché del Extract según la actividad de la base de datos:

```
-- Para sistemas con transacciones grandes o largas
CACHEMGR CACHESIZE 4096MB, CACHEDIRECTORY /u02/ggcache
```

### Parallel Replicat

Para cargas altas, usar el Replicat integrado con paralelismo ajustado a los CPUs disponibles:

```
DBOPTIONS INTEGRATEDPARAMS (PARALLELISM 8)
```

### GROUPTRANSOPS

Agrupar múltiples operaciones en un único COMMIT mejora el throughput del Replicat:

```
-- Agrupar hasta 5000 operaciones antes del COMMIT
GROUPTRANSOPS 5000
```

### Índices en el destino

Asegurarse de que las tablas destino tienen los mismos índices que el origen (especialmente PK y UK), ya que el Replicat los usa para localizar registros en UPDATE/DELETE.

---

## Alta Disponibilidad

### AUTORESTART en mgr.prm

Configurar el Manager para reiniciar automáticamente los procesos caídos:

```
AUTORESTART EXTRACT *, RETRIES 5, WAITMINUTES 2, RESETMINUTES 60
AUTORESTART REPLICAT *, RETRIES 5, WAITMINUTES 2, RESETMINUTES 60
```

### Heartbeat

Activar la tabla de heartbeat para medir el lag extremo a extremo (E2E) de forma precisa:

```bash
# En la BD origen
GGSCI> DBLOGIN USERIDALIAS gg_src_alias DOMAIN OracleGoldenGate
GGSCI> ADD HEARTBEATTABLE

# En la BD destino
GGSCI> DBLOGIN USERIDALIAS gg_tgt_alias DOMAIN OracleGoldenGate
GGSCI> ADD HEARTBEATTABLE
```

### GoldenGate Microservices Architecture (MA)

En entornos críticos, considerar **GoldenGate Microservices** (21c) que ofrece:
- Gestión vía REST API y UI web.
- Despliegue en contenedores (Docker/Kubernetes).
- Service Manager con alta disponibilidad nativa.

---

## Gestión de Trail Files

### Directorio dedicado

Usar un sistema de archivos dedicado para los trail files, separado del sistema operativo y del Oracle Home:

```
# Sistemas de archivos recomendados (en producción)
/u01/app/oracle  → Oracle Home y GG Home
/u02/gg_dirdat   → Trail files locales
/u03/gg_dirdat   → Trail files remotos (si es local)
```

### Purga automática

Configurar la purga automática en `mgr.prm` con un mínimo de días de retención:

```
PURGEOLDEXTRACTS ./dirdat/*, USECHECKPOINTS, MINKEEPDAYS 3, MINKEEPHOURS 24
```

### Tamaño de trail files

Ajustar el tamaño según el volumen de datos y la frecuencia de retransmisión:

```
-- Entornos de alto volumen: mayor tamaño para reducir la rotación de archivos
ADD EXTTRAIL ./dirdat/lt, EXTRACT EXTINT, MEGABYTES 1024

-- Entornos de bajo volumen: menor tamaño
ADD EXTTRAIL ./dirdat/lt, EXTRACT EXTINT, MEGABYTES 100
```

---

## Monitoreo

### Métricas clave

| Métrica | Umbral de alerta | Umbral crítico |
|---|---|---|
| Lag del Extract | > 5 min | > 30 min |
| Lag del Replicat | > 10 min | > 60 min |
| Uso de disco (dirdat) | > 70% | > 90% |
| Procesos en estado ABEND | > 0 | > 0 |

### Consultas SQL de monitoreo

```sql
-- Lag aproximado vía heartbeat
SELECT HB_SRC_EXTRACT, HB_LATENCY_SECONDS
FROM GGS_HEARTBEAT_HISTORY
WHERE ROWNUM <= 10
ORDER BY HB_HEARTBEAT_TIME DESC;

-- Espacio en archived logs
SELECT CEIL(SUM(BLOCKS*BLOCK_SIZE)/1024/1024/1024) GB_USED
FROM V$ARCHIVED_LOG
WHERE DELETED = 'NO';
```

---

## Mantenimiento Preventivo

| Frecuencia | Tarea |
|---|---|
| Diaria | Verificar estado de todos los procesos y lag |
| Diaria | Revisar archivos de discards (`.dsc`) |
| Semanal | Revisar el espacio en disco de trail files |
| Mensual | Validar integridad de datos con `GGCHECK` |
| Mensual | Revisar los reportes de estadísticas |
| Trimestral | Actualizar contraseñas del usuario GoldenGate |

---

## DDL Replication

La replicación de DDL debe planificarse cuidadosamente:

- Habilitar solo si es **estrictamente necesario**.
- Probar en entornos de pre-producción antes de activar en producción.
- Filtrar DDL para excluir objetos no relevantes:

```
DDL INCLUDE MAPPED OBJTYPE 'TABLE' OPTYPE 'ALTER, CREATE'
DDL EXCLUDE OBJNAME 'APP_OWNER.LOG_*'
```

---

## Initial Load

Para cargar los datos iniciales antes de activar la replicación continua:

### Opción 1: Export/Import con SCN

```sql
-- 1. Anotar el SCN actual antes del export
SELECT CURRENT_SCN FROM V$DATABASE;

-- 2. Exportar con Data Pump usando ese SCN
expdp system/... DIRECTORY=DATA_PUMP_DIR DUMPFILE=initial_load.dmp \
      SCHEMAS=APP_OWNER FLASHBACK_SCN=<scn_anotado>

-- 3. Importar en destino
impdp system/... DIRECTORY=DATA_PUMP_DIR DUMPFILE=initial_load.dmp \
      SCHEMAS=APP_OWNER REMAP_SCHEMA=APP_OWNER:APP_OWNER

-- 4. Iniciar el Extract desde ese SCN
```

```bash
# En GGSCI (origen)
GGSCI> ADD EXTRACT EXTINT, INTEGRATED TRANLOG, SCN <scn_anotado>
GGSCI> ADD EXTTRAIL ./dirdat/it, EXTRACT EXTINT, MEGABYTES 500
GGSCI> START EXTRACT EXTINT
```

### Opción 2: GoldenGate Initial Load (SOURCEISTABLE)

```bash
# En GGSCI: extract de carga inicial
GGSCI> ADD EXTRACT INITLOAD, SOURCEISTABLE
GGSCI> ADD RMTTRAIL ./dirdat/il, EXTRACT INITLOAD, MEGABYTES 500
GGSCI> START EXTRACT INITLOAD

# Replicat en modo especial para carga inicial
GGSCI> ADD REPLICAT INITREP, SPECIALRUN
GGSCI> START REPLICAT INITREP, AFTERCSN <scn_inicial>
```
