# Oracle GoldenGate – Ingeniería de Replicación de Datos

Repositorio de referencia para arquitectura, configuración y operación de **Oracle GoldenGate** con bases de datos Oracle. Contiene scripts SQL, archivos de parámetros, scripts de shell y documentación completa pensada para entornos de producción.

---

## Tabla de Contenidos

1. [Arquitectura](#arquitectura)
2. [Estructura del Repositorio](#estructura-del-repositorio)
3. [Requisitos Previos](#requisitos-previos)
4. [Configuración Rápida](#configuración-rápida)
5. [Parámetros Disponibles](#parámetros-disponibles)
6. [Monitoreo y Mantenimiento](#monitoreo-y-mantenimiento)
7. [Documentación Adicional](#documentación-adicional)

---

## Arquitectura

```
┌─────────────────────────────┐          ┌─────────────────────────────┐
│       BASE DE DATOS FUENTE   │          │       BASE DE DATOS DESTINO  │
│  (Oracle 19c / 21c)          │          │  (Oracle 19c / 21c)          │
│                              │          │                              │
│  ┌────────────┐              │  TRAILS  │   ┌────────────┐            │
│  │  EXTRACT   │─────────────►│──────────►──►│  REPLICAT  │            │
│  │  (EXT*)    │              │          │   │  (REP*)    │            │
│  └────────────┘              │          │   └────────────┘            │
│        │                     │          │                              │
│  ┌─────▼──────┐              │          │                              │
│  │    PUMP    │              │          │                              │
│  │  (PMP*)    │──────────────┘          │                              │
│  └────────────┘                         │                              │
│                              │          │                              │
│  Redo Logs / Archive Logs    │          │   Apply Engine               │
└─────────────────────────────┘          └─────────────────────────────┘
```

**Flujo de datos:**
1. **EXTRACT** lee los redo logs del origen y captura cambios transaccionales (DML/DDL).
2. **PUMP** (Data Pump) transmite los trail files locales al servidor destino.
3. **REPLICAT** aplica los cambios en la base de datos destino de manera transaccional.

---

## Estructura del Repositorio

```
golden/
├── README.md
├── docs/
│   ├── architecture.md          # Arquitectura detallada y modos de operación
│   ├── best-practices.md        # Mejores prácticas en producción
│   └── troubleshooting.md       # Diagnóstico y resolución de problemas
├── sql/
│   ├── source/
│   │   ├── 01_enable_supplemental_logging.sql
│   │   ├── 02_create_gg_user.sql
│   │   ├── 03_grant_privileges.sql
│   │   └── 04_check_configuration.sql
│   └── target/
│       ├── 01_create_gg_user.sql
│       ├── 02_grant_privileges.sql
│       └── 03_check_configuration.sql
├── params/
│   ├── extract/
│   │   ├── ext_classic.prm      # Extract clásico (LogMiner)
│   │   └── ext_integrated.prm   # Extract integrado
│   ├── pump/
│   │   └── pump_remote.prm      # Data Pump remoto
│   └── replicat/
│       ├── rep_classic.prm      # Replicat clásico
│       └── rep_integrated.prm   # Replicat integrado (paralelo)
└── scripts/
    ├── setup/
    │   ├── setup_extract.sh     # Alta del Extract en GGSCI
    │   └── setup_replicat.sh    # Alta del Replicat en GGSCI
    ├── monitoring/
    │   ├── check_status.sh      # Estado de todos los procesos GG
    │   └── lag_monitor.sh       # Monitor de lag con alertas
    └── maintenance/
        ├── cleanup_trails.sh    # Limpieza de trail files antiguos
        └── backup_trails.sh     # Copia de seguridad de trails
```

---

## Requisitos Previos

| Componente | Versión mínima |
|---|---|
| Oracle Database (origen/destino) | 12.2+ (recomendado 19c/21c) |
| Oracle GoldenGate | 19.1+ (recomendado 21c) |
| Sistema Operativo | Oracle Linux 7/8, RHEL 7/8 |
| Java (para GG Microservices) | JDK 11+ |

### Variables de Entorno

```bash
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
export GG_HOME=/u01/app/oracle/product/19.1.0/oggcore_1
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$GG_HOME:$LD_LIBRARY_PATH
export PATH=$GG_HOME:$ORACLE_HOME/bin:$PATH
```

---

## Configuración Rápida

### 1. Base de Datos Fuente

```bash
# Habilitar modo ARCHIVELOG y supplemental logging
sqlplus / as sysdba @sql/source/01_enable_supplemental_logging.sql

# Crear usuario GoldenGate y otorgar privilegios
sqlplus / as sysdba @sql/source/02_create_gg_user.sql
sqlplus / as sysdba @sql/source/03_grant_privileges.sql

# Verificar configuración
sqlplus / as sysdba @sql/source/04_check_configuration.sql
```

### 2. Base de Datos Destino

```bash
sqlplus / as sysdba @sql/target/01_create_gg_user.sql
sqlplus / as sysdba @sql/target/02_grant_privileges.sql
sqlplus / as sysdba @sql/target/03_check_configuration.sql
```

### 3. Configurar y Arrancar Procesos GoldenGate

```bash
# Configurar Extract
bash scripts/setup/setup_extract.sh

# Configurar Replicat
bash scripts/setup/setup_replicat.sh
```

### 4. Verificar Estado

```bash
bash scripts/monitoring/check_status.sh
```

---

## Parámetros Disponibles

| Archivo | Proceso | Descripción |
|---|---|---|
| `params/extract/ext_classic.prm` | EXTRACT | Captura clásica vía LogMiner |
| `params/extract/ext_integrated.prm` | EXTRACT | Captura integrada (recomendada 12c+) |
| `params/pump/pump_remote.prm` | PUMP | Transmisión remota al servidor destino |
| `params/replicat/rep_classic.prm` | REPLICAT | Aplicación clásica monohilo |
| `params/replicat/rep_integrated.prm` | REPLICAT | Aplicación paralela integrada |

---

## Monitoreo y Mantenimiento

```bash
# Verificar estado de todos los procesos
bash scripts/monitoring/check_status.sh

# Monitor de lag en tiempo real (actualización cada 60 s)
bash scripts/monitoring/lag_monitor.sh

# Eliminar trail files con más de 7 días
bash scripts/maintenance/cleanup_trails.sh 7

# Respaldar trail files actuales
bash scripts/maintenance/backup_trails.sh /backup/goldengate
```

---

## Documentación Adicional

- [Arquitectura detallada](docs/architecture.md)
- [Mejores prácticas](docs/best-practices.md)
- [Diagnóstico y troubleshooting](docs/troubleshooting.md)
- [Documentación oficial Oracle GoldenGate](https://docs.oracle.com/en/middleware/goldengate/)
