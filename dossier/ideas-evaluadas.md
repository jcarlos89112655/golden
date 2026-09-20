# Ideas evaluadas para la convocatoria ESA BIC Valencia Region

Registro de las cinco opciones estudiadas y por qué se eligió la ganadora.

## Mapa de lo que ya está incubado (hueco competitivo)

| Vertical | Ocupado por |
|---|---|
| Propulsión | Arkadia Space, Nerva Technologies |
| Agro con datos satelitales | Nax Solutions, ODOS Technologies |
| Software de comunicaciones satelitales | Collimate Space, Synaptyx |
| Drones de largo alcance | Valyra Aerospace |
| Robótica autónoma terrestre | Umibots |
| **Materiales y componentes físicos** | **libre** |
| **Agua, clima y riesgo** | **libre** |
| **Seguridad criptográfica del enlace** | **libre** |
| **Incendios forestales** | **libre** |

## Comparativa

| # | Idea | "Por qué Castellón" | Solape interno | Viable con 60 k€ | Tiempo a 1er ingreso | Veredicto |
|---|---|---|---|---|---|---|
| 1 | **Terminal óptico FSO para dron** | Medio-alto (NTC-UPV, DAS Photonics) | Nulo si se hace la carga y no el dron | Medio | **Corto** | ✅ **ELEGIDA** |
| 2 | Cerámica técnica para espacio (CMC, TPS, toberas) | **Máximo** (clúster cerámico, ITC-AICE, UJI) | Nulo | Medio, usando laboratorios ajenos | Medio | Alternativa fuerte |
| 3 | Criptografía post-cuántica para el segmento de vuelo | Bajo | Nulo | **Alto** | Medio | Buena si el perfil fuera software |
| 4 | Extinción sin agente en hábitats espaciales (acústica en microgravedad) | Bajo | Nulo | Solo caracterización | Largo | La más original, la más lenta |
| 5 | Extintor acústico para incendios forestales | — | — | — | — | ❌ **Descartada** |

## Por qué se descartó la idea 5

El fenómeno acústico es real a escala de laboratorio: DARPA extinguió una llama de metano de 15 cm con sonido de 35–150 Hz, adelgazando la capa límite y separando la llama del combustible. No escala a incendio forestal por cuatro razones independientes, cada una suficiente:

1. **No enfría** → el combustible sigue sobre su temperatura de ignición y reenciende de inmediato. En sólidos, el calor está dentro del material.
2. **Longitud de onda** → a 50 Hz la onda mide ~7 m; enfocarla exigiría aperturas de varios metros, imposibles en un dron.
3. **Potencia** → la intensidad cae con el cuadrado de la distancia y solo funciona envolviendo la llama a decenas de centímetros. Un frente forestal libera decenas de MW por metro lineal.
4. **Efecto contrario** → mover aire rápido junto al fuego, más el downwash del rotor, aviva los bordes.

Nicho residual plausible: recintos confinados y pequeños (racks, armarios eléctricos, archivos) donde el agente extintor daña más que el fuego. Nunca campo abierto.

## Nota sobre "comunicaciones cuánticas rápidas"

Descartado como posicionamiento: la QKD **reduce** la velocidad, no la aumenta; distribuye claves a kbps, de noche y con cielo despejado. Lo que da velocidad es la óptica en espacio libre; lo que da seguridad desplegable hoy es la criptografía post-cuántica (ML-KEM, ML-DSA). Esa distinción, escrita explícitamente en la memoria, demuestra criterio técnico ante el comité.

## Reorientación de la línea "incendios"

El negocio en incendios forestales no está en el dispositivo de extinción, sino en detección precoz con térmico satelital, predicción de propagación y —sobre todo— **restitución de comunicaciones sobre el incidente**, que es exactamente la configuración B del producto elegido. La línea no se pierde: se convierte en un segmento de cliente.
