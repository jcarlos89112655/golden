# Arquitectura de Oracle GoldenGate

## Índice

1. [Componentes principales](#componentes-principales)
2. [Modos de captura](#modos-de-captura)
3. [Modos de aplicación](#modos-de-aplicación)
4. [Topologías comunes](#topologías-comunes)
5. [Trail Files](#trail-files)
6. [Proceso Manager](#proceso-manager)

---

## Componentes Principales

### EXTRACT (Captura)

El proceso **Extract** es el encargado de leer los cambios transaccionales directamente desde los **redo logs** de la base de datos Oracle fuente. Opera en dos modos:

- **Classic Capture**: Lee los redo logs directamente a través de la API de Oracle (antes se llamaba LogMiner).
- **Integrated Capture**: Utiliza el motor interno de LogMiner del servidor Oracle para capturar los cambios. Más eficiente y soporta características avanzadas (compresión, columnas cifradas, etc.).

El Extract escribe los cambios en **trail files locales**.

### DATA PUMP (Bomba de datos)

El **Data Pump** es un Extract secundario (tipo `PASSTHRU`) que lee los trail files locales y los transmite a través de la red al servidor GoldenGate de destino. Sus beneficios son:

- **Desacoplamiento**: El Extract principal no se ve afectado por problemas de red.
- **Reintentos**: El Pump puede reintentar la transmisión sin afectar la captura.
- **Compresión y cifrado**: Se puede habilitar a nivel de red.
- **Fan-out**: Un Extract puede alimentar múltiples Pumps hacia diferentes destinos.

### REPLICAT (Aplicación)

El proceso **Replicat** lee los trail files remotos y aplica los cambios en la base de datos destino. Soporta:

- **Classic Apply**: Aplica los cambios de forma serial, en orden de transacción.
- **Integrated Apply**: Usa el motor interno de apply de Oracle para aplicar en paralelo.
- **Parallel Replicat (coordinated)**: Divide el trabajo por tablas o transacciones en múltiples hilos.

### MANAGER

El **Manager** es el proceso daemon central de GoldenGate. Gestiona:

- Inicio/parada de todos los procesos GG.
- Gestión del espacio en disco de los trail files.
- Enrutamiento de comunicaciones entre procesos.
- Purga automática de trail files obsoletos.

---

## Modos de Captura

| Modo | Disponible desde | Ventajas | Limitaciones |
|---|---|---|---|
| Classic | GG 10.x | Simple, universal | No soporta algunas features de 12c+ |
| Integrated | GG 11.2 / DB 11.2 | Soporta CDB, compresión, cifrado | Requiere `LOGMINING` privilege |

### Captura integrada en entorno CDB

En un entorno **Container Database (CDB)**, el Extract integrado se conecta al **CDB$ROOT** y puede capturar cambios de una o varias PDBs. El parámetro `SOURCECATALOG` especifica la PDB de origen.

```
-- Ejemplo en ext_integrated.prm para CDB
SOURCECATALOG ORCLPDB1
TABLE HR.EMPLOYEES;
TABLE HR.DEPARTMENTS;
```

---

## Modos de Aplicación

### Classic Replicat

- Aplica transacciones **en orden estricto**.
- Un único hilo de apply.
- Adecuado cuando la consistencia transaccional es crítica.
- Performance limitada: ~5.000 – 20.000 operaciones/segundo.

### Integrated Replicat

- Usa el motor de **In-Memory Apply** de Oracle Database.
- Soporta **apply en paralelo** con múltiples hilos.
- Preserva el orden transaccional por dependencias.
- Performance alta: >100.000 operaciones/segundo con paralelismo adecuado.
- Requiere Oracle 12.2+.

### Parallel Replicat (coordinated)

- Divide el trabajo en **coordinadores** y **workers**.
- Cada worker aplica un subconjunto de tablas.
- Máxima flexibilidad para ajustar el paralelismo.

---

## Topologías Comunes

### 1. Replicación Unidireccional (A → B)

La más común. Los cambios fluyen del origen al destino.

```
[Origen DB] → EXTRACT → PUMP → (red) → REPLICAT → [Destino DB]
```

### 2. Replicación Bidireccional (A ↔ B)

Ambas bases de datos son activas. Requiere **loop prevention** (parámetro `SOURCEDEFS` y filtros de origen).

```
[DB_A] ←→ EXTRACT/REPLICAT ←→ [DB_B]
```

### 3. Fan-out (A → B, C, D)

Un origen alimenta múltiples destinos. Se usa un Extract y múltiples Pumps/Replicats.

```
[Origen] → EXTRACT → PUMP_B → [Destino B]
                   → PUMP_C → [Destino C]
                   → PUMP_D → [Destino D]
```

### 4. Consolidación (A, B → C)

Múltiples orígenes convergen en un único destino. Útil en migraciones o consolidación de datos.

```
[DB_A] → EXTRACT_A → PUMP_A ↘
[DB_B] → EXTRACT_B → PUMP_B  →  [DB_C]
```

### 5. Cascada (A → B → C)

El destino intermedio también actúa como origen para el siguiente salto.

```
[DB_A] → EXT/PUMP → [DB_B] → EXT/PUMP → [DB_C]
```

---

## Trail Files

Los **trail files** son archivos secuenciales que actúan como buffer entre los procesos GoldenGate. Características:

| Atributo | Detalle |
|---|---|
| Formato | Propietario Oracle GG (binario) |
| Tamaño por defecto | 500 MB (configurable con `MEGABYTES`) |
| Nomenclatura | `<prefijo><secuencia>` (ej: `lt000001`) |
| Ubicación local | `$GG_HOME/dirdat/` |
| Ubicación remota | Configurable con `RMTTRAIL` |

### Gestión del espacio

El Manager limpia automáticamente los trail files una vez que todos los procesos que los consumen los han procesado. Se puede configurar en `mgr.prm`:

```
PURGEOLDEXTRACTS ./dirdat/*, USECHECKPOINTS, MINKEEPDAYS 3
```

---

## Proceso Manager

El Manager debe estar en ejecución antes de iniciar cualquier otro proceso. Su archivo de parámetros se encuentra en `$GG_HOME/dirprm/mgr.prm`.

### Ejemplo de mgr.prm

```
-- Puerto de escucha (por defecto 7809)
PORT 7809

-- Puertos dinámicos para los procesos hijos
DYNAMICPORTLIST 7810-7900

-- Limpieza automática de trail files
PURGEOLDEXTRACTS ./dirdat/*, USECHECKPOINTS, MINKEEPDAYS 3, MINKEEPHOURS 24

-- Reinicio automático de procesos caídos
AUTORESTART EXTRACT *, RETRIES 5, WAITMINUTES 2, RESETMINUTES 60
AUTORESTART REPLICAT *, RETRIES 5, WAITMINUTES 2, RESETMINUTES 60

-- Reportes
LAGREPORTHOURS 1
LAGREPORTMINUTES 30
LAGINFOMINUTES 0
LAGCRITICALMINUTES 30
```
