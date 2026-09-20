# Dossier de candidatura — ESA BIC Valencia Region (3ª convocatoria)

**Convocatoria:** ESA BIC Valencia Region, Aeropuerto de Castellón (Aerocas / Generalitat / ValSpace / Agencia Espacial Española)
**Plazas:** 4 · **Dotación:** 60.000 € + tutorización + acceso al ecosistema ESA
**Plazo:** 21 septiembre – **18 diciembre 2026** · **Solicitud:** esabic.aeroportcastello.com
**Perfil del promotor:** electrónica, óptica y sistemas embarcados

> Documento de trabajo. Las cifras de mercado y precio son **hipótesis a validar** con entrevistas de cliente antes de presentar, no datos verificados.

---

## 1. Resumen ejecutivo

Desarrollamos **terminales de comunicación óptica en espacio libre (FSO) de bajo peso, tamaño y consumo para plataformas aéreas no tripuladas**: la carga de pago que convierte un dron en un nodo de comunicaciones de alta capacidad y difícil de interceptar.

Entramos al mercado por el enlace **dron → tierra** (vigilancia e ISR, donde el vídeo de alta resolución satura el espectro radioeléctrico disponible) y escalamos hacia el enlace **dron → satélite**, donde nuestra plataforma resuelve el problema estructural de las comunicaciones ópticas espaciales: **una nube corta el enlace, y un receptor que vuela por encima de la capa nubosa no**.

El terminal óptico es la capa troncal de una **pasarela de comunicaciones de tres capas**: óptico para sacar el dato del incidente, VHF/UHF para dar cobertura sobre él, y baja frecuencia para alcanzar a quien está bajo dosel forestal, en barranco o sepultado. El dron traduce entre los tres regímenes.

No fabricamos drones. Fabricamos la carga útil. Los fabricantes de drones son nuestros clientes, no nuestros competidores.

**Nombres de trabajo:** *Aurea Photonics* · *Millars Optical* · *Nodo Aéreo Óptico (NAO)*

---

## 2. El problema

### 2.1 En el enlace aéreo actual
El espectro radioeléctrico disponible para drones está congestionado y regulado. Un dron con sensor electroóptico o radar moderno genera mucho más dato del que puede bajar. Consecuencias operativas:

- Se transmite vídeo comprimido con pérdida, degradando justo la información por la que se voló la misión.
- El enlace de radio es detectable e interferible. En entorno de defensa o seguridad, emitir en RF es revelar la posición.
- Las bandas libres no ofrecen garantía de servicio cuando hay varios operadores sobre el mismo incidente.

### 2.2 En el enlace espacial
Las comunicaciones ópticas multiplican por dos órdenes de magnitud la capacidad de bajada frente a la radiofrecuencia. Su limitación crítica y reconocida es la **cobertura nubosa**: la literatura del DLR concluye que los enlaces ópticos directos requieren una red de estaciones terrestres geográficamente diversa, o hibridación con RF, para garantizar disponibilidad media.

Europa despliega infraestructura óptica (HydRON, IRIS², EuroQCI) y necesita nodos receptores. Una estación fija en superficie está a merced de la meteorología local. **Un receptor aerotransportado a 4.000–6.000 m está por encima de la mayor parte de la nubosidad baja y media.**

### 2.3 En emergencias (nuestro cliente de entrada por urgencia)
Cuando cae la red terrestre —inundación, incendio forestal, terremoto— o simplemente cuando la orografía la bloquea, los equipos de intervención pierden comunicación. En la Comunitat Valenciana esto no es hipotético: la DANA de octubre de 2024 dejó comarcas enteras incomunicadas, y en incendio forestal la pérdida de radio en barrancos y vaguadas es un factor documentado de riesgo para las brigadas.

---

## 3. Producto

Tres configuraciones sobre un mismo núcleo tecnológico, escalonadas en el tiempo.

### Configuración A — Terminal óptico dron ↔ tierra *(producto de entrada, meses 0–12)*
| Parámetro | Objetivo |
|---|---|
| Alcance | 1–5 km línea de vista |
| Capacidad | ≥ 1 Gbps (objetivo fase 1: 500 Mbps demostrados) |
| Longitud de onda | 1550 nm (componentes telecom COTS, mejor clasificación de seguridad ocular) |
| Masa del terminal aéreo | < 2,5 kg |
| Consumo | < 25 W |
| Apuntamiento | Cardán de 2 ejes (grueso, ~1 mrad) + espejo de dirección rápida (fino, < 20 µrad) |
| Respaldo | Canal RF de baja tasa para adquisición, telemetría y conmutación ante corte |

### Configuración B — Nodo relé de emergencia *(meses 12–24)*
Terminal A + enlace satelital + célula de cobertura local. El dron sube sobre el incidente y restituye un enlace de datos de alta capacidad y comunicación para los equipos de tierra. Se vende como **capacidad desplegable**, no como hardware suelto.

### Configuración C — Estación óptica terrestre aerotransportada *(meses 24+, visión)*
Receptor óptico sobre plataforma que vuela por encima de la capa nubosa para recibir bajadas de satélite. Es la configuración que justifica la valoración a largo plazo y el encaje con IRIS² y EuroQCI.

---

### 3.4 Arquitectura multibanda: por qué la baja frecuencia cierra el sistema

El enlace óptico tiene capacidad enorme y una debilidad absoluta: exige línea de vista. Pero el problema operativo
que resolvemos —equipos de intervención incomunicados— es, por definición, un problema de **ausencia** de línea de
vista. La solución no es elegir una banda, es escalonarlas.

| Capa | Banda | Capacidad | Función |
|---|---|---|---|
| **Troncal** | Óptico FSO / satcom | Gbps | Sacar el dato del incidente. **Sostiene el requisito de conexión espacial** |
| **Área local** | VHF/UHF, interoperable con TETRA (380–400 MHz) | kbps–Mbps | Cobertura radioeléctrica sobre el incidente |
| **Penetración** | HF / LF | bits por segundo | Alcanzar a quien está bajo dosel, en barranco o sepultado |

#### Fundamento físico de la capa baja

- **Penetración en terreno.** El efecto pelicular es inversamente proporcional a la frecuencia: VLF penetra decenas
  de metros en roca o agua salada, mientras las frecuencias altas se extinguen de inmediato. Los sistemas de rescate
  en cueva lo explotan: HeyPhone y Nicola operan en banda lateral única a 87 kHz; Cave-Link entre 20 y 140 kHz con
  30 W según distancia. Tecnología de esta familia se empleó en el rescate de Tham Luang.
- **Penetración en follaje.** Las hojas y ramas absorben más UHF que VHF, porque su tamaño físico se aproxima a la
  longitud de onda de UHF. Un dosel denso es más hostil a UHF que a VHF, razón por la que los servicios forestales
  han permanecido históricamente en VHF.

#### El precio físico, reconocido explícitamente

La resistencia de radiación de un dipolo escala con **(L/λ)²**. A 87 kHz la longitud de onda es de 3,4 km: una antena
de 3 m montada en un dron es λ/1000, con eficiencia de radiación ínfima. **La capa baja entrega bits por segundo, no
megabits**: posición, estado, recuento de personal y mensajería breve. No voz continua ni vídeo. Las vías conocidas
—cable remolcado o bucle resonante sintonizado— penalizan el vuelo.

**Clasificación honesta de madurez, que debe aparecer así en la memoria:**

| Capa | Estado | Horizonte |
|---|---|---|
| Troncal óptica | Desarrollo, es el núcleo del proyecto | Meses 0–18 |
| Repetidor VHF/UHF interoperable con TETRA | **Integración de componentes comerciales** | Meses 6–12, primer producto vendible |
| Penetración LF/VLF desde plataforma aérea | **Línea de I+D, no producto comprometido** | Año 2–3 |

#### El límite que no se negocia

**Por debajo de ~30 MHz la ionosfera refleja la señal, no la deja pasar.** Ningún satélite puede recibir HF ni bandas
inferiores; es el mismo fenómeno que hace que la HF rebote alrededor del planeta. El enlace satelital solo es posible
de VHF/UHF hacia arriba (el IoT satelital vive en torno a 137–450 MHz). Por tanto **la baja frecuencia no sustituye
nunca a la capa troncal**: la complementa por el extremo opuesto.

> **Riesgo de posicionamiento.** Si el relato se desplaza hacia «radio de emergencias», se pierde el requisito
> eliminatorio de conexión espacial. La capa troncal óptica y satelital debe seguir siendo la columna vertebral de
> la memoria; la baja frecuencia entra como capa de cierre, no como producto principal.

### 3.5 Cliente ancla identificado: la red COMDES

La Generalitat opera **COMDES**, la red digital de comunicaciones móviles de emergencia y seguridad de la Comunitat
Valenciana: 206 estaciones base, más del 98 % de cobertura territorial y 99,5 % de población, 17.712 usuarios de 360
flotas —bomberos forestales, consorcios provinciales, 112CV, policías locales y protección civil de 289 municipios—
sobre estándar TETRA en **banda UHF 380–400 MHz**.

Dos consecuencias comerciales:

1. La red de emergencias opera en la banda que **peor atraviesa el bosque denso**, y el porcentaje de territorio sin
   cobertura se concentra previsiblemente en orografía cerrada: barranco, vaguada y monte. Es decir, donde arde y
   donde inunda. *(Hipótesis a contrastar con el operador de la red antes de presentar.)*
2. El cliente está **agrupado en una sola red, con presupuesto, y gestionado por la misma administración que
   cofinancia la incubadora**. La interoperabilidad con TETRA deja de ser un requisito técnico y pasa a ser el
   argumento comercial central.

**Acción:** solicitar reunión con los responsables de COMDES para validar el hueco de cobertura y los requisitos de
interoperabilidad. Es la entrevista de cliente de mayor valor de todo el plan.

## 4. Conexión con el sector espacial *(requisito eliminatorio de la convocatoria)*

Debe quedar explícito desde la primera línea de la memoria. Nuestra conexión es triple:

1. **Tecnología de origen espacial.** La arquitectura de apuntamiento, adquisición y seguimiento (PAT) y los subsistemas ópticos son herencia directa de los terminales de comunicación láser intersatelital. Estamos adaptando tecnología espacial a plataforma aérea.
2. **El producto termina hablando con satélites.** La configuración C es, literalmente, segmento terrestre de una constelación óptica.
3. **Encaje con programa europeo.** ESA ScyLight / HydRON y los programas de conectividad segura (IRIS², EuroQCI) necesitan diversidad de nodos receptores. Nuestra hoja de ruta es una respuesta directa a esa necesidad.

> Una empresa de drones genérica no cumple este requisito. Una empresa de terminales ópticos sí. **La memoria debe posicionarnos como empresa de fotónica y comunicaciones, no como empresa de drones.**

---

## 5. Estado del arte y madurez tecnológica

**El concepto está demostrado, no inventado.** El DLR, junto con Airbus Defence & Space y ViaLight, demostró en el proyecto DODfast un enlace óptico de **1,25 Gbps desde un caza Panavia Tornado volando a Mach 0,7** contra una estación óptica terrestre transportable. Si el apuntamiento se resuelve a 850 km/h con vibración estructural de plataforma de combate, es un problema tratable —no trivial, pero tratable— en un dron estable a velocidad baja.

| | Hoy | Objetivo fin de incubación |
|---|---|---|
| TRL | 2–3 (concepto formulado, componentes conocidos) | **5** (subsistema validado en entorno relevante) |
| Evidencia | Análisis de balance de enlace y arquitectura PAT | Enlace dron-tierra en vuelo, con tasa y disponibilidad medidas |

**Riesgo técnico dominante:** estabilización del apuntamiento frente a la vibración del rotor y a las perturbaciones aerodinámicas. Mitigación: arquitectura de dos etapas (cardán + espejo rápido) con realimentación inercial, que es la solución estándar del sector, y caracterización temprana en banco antes de volar.

---

## 6. Diferenciación y competencia

| Competidor / categoría | Qué hacen | Nuestra diferencia |
|---|---|---|
| Fabricantes de terminales ópticos espaciales (Tesat, Mynaric y equivalentes) | Terminales satélite-satélite y aire-aire, gama alta | Nos centramos en el escalón de peso y precio que ellos no atienden: dron táctico y plataforma pequeña |
| Estaciones ópticas terrestres (Cailabs y similares) | Infraestructura fija en superficie | Plataforma aerotransportada: resolvemos la nubosidad, que es su limitación estructural |
| Enlaces RF para drones | Estándar del mercado | Mayor capacidad, sin consumo de espectro, baja probabilidad de detección e interceptación |
| Valyra Aerospace *(ya en la incubadora)* | Drones de largo alcance para vigilancia y zonas remotas | **No competimos: son plataforma y cliente potencial** |

> **Acción prioritaria:** verificar el estado societario y de producto actual de cada competidor antes de presentar. El sector de terminales ópticos ha vivido movimientos corporativos relevantes y una tabla desactualizada resta credibilidad.

### La jugada de posicionamiento
Valyra, Arkadia, Nerva, Collimate y Synaptyx no son competencia: son **el primer mercado accesible y la prueba de que la incubadora genera cadena de valor interna**. Una carta de intención de Valyra en el expediente vale más que veinte páginas de proyección financiera, y le da al ESA BIC un argumento de sinergia que puede presumir ante la ESA en su renovación.

---

## 7. Mercado y clientes

### 7.1 Advertencia previa: la administración no es un buen primer cliente

Conviene decirlo antes que nada, porque sostiene todo el orden de segmentos que sigue.

**Evidencia de cómo compra realmente el sector público de emergencias:**

- El **Consorcio Provincial de Bombers de València** mantiene abierta una licitación para el suministro de
  «un dron, sus accesorios y sus cámaras», en singular, con plazo de ofertas en abril de 2026. Compra **unidades
  sueltas de catálogo, por precio**. No compra desarrollo ni tecnología a TRL 5.
- Donde sí hay volumen, la barrera de entrada es infranqueable para una empresa joven: la Generalitat licita la
  extinción aérea de incendios forestales —7 aviones de carga en tierra, 2 anfibios y 1 de coordinación— por un
  **valor estimado de 58,6 M€**, adjudicable solo a operadores aeronáuticos consolidados con flota, certificación
  e historial.
- El comprador está **fragmentado**: tres consorcios provinciales, la Generalitat, brigadas municipales y el Estado,
  sin ventanilla única. Ciclos de 18 a 36 meses.

**Conclusión operativa: una empresa en fase semilla no puede depender de un pedido público.** La emergencia es
nuestro relato de misión y un segmento de madurez, no la línea de ingresos del año uno.

**La distinción que sí importa:** el sector público es mal *cliente* a corto plazo, pero excelente *inversor*. El
Plan Industrial y Tecnológico para la Seguridad y la Defensa, aprobado en abril de 2025, moviliza **10.471 M€ con
foco explícito en tecnologías de doble uso** y prevé elevar la I+D+i estatal un 18 %. España alcanzó el **2 % del
PIB en defensa en 2025 y lo mantiene en 2026**, con el **44,2 % del gasto dedicado a equipamiento**, quinto puesto
de la OTAN: el incremento va a material y tecnología. El modelo correcto es **financiarse con inversión pública y
facturar a integradores privados y a defensa**.

### 7.2 Segmentos por orden de entrada

| # | Cliente | Racional | Horizonte |
|---|---|---|---|
| 1 | **Integradores y fabricantes de drones ISR europeos** | Compran componente para diferenciar producto; ciclo comercial normal y ticket de hardware | Año 1 |
| 2 | **Defensa y doble uso** | El enlace de baja probabilidad de detección es requisito, no mejora. Contexto presupuestario excepcional | Año 1–2 |
| 3 | **Infraestructura crítica privada** | Puertos, refinería, red eléctrica, plantas fotovoltaicas. Capex privado y decisión rápida. PortCastelló ya ha ensayado drones para control y vigilancia portuaria | Año 2 |
| 4 | **Operadores aeronáuticos de extinción** | **Vía de acceso al presupuesto público sin sufrir la compra pública**: el adjudicatario del contrato de 58,6 M€ integra nuestro equipo en su oferta para diferenciarse en la siguiente licitación. Decide como empresa privada | Año 2–3 |
| 5 | **Protección civil y administración directa** | Solo con producto certificado e historial de servicio acumulado | Año 3+ |
| 6 | **Operadores de satélite y programas europeos** | Configuración C | 2029+ |

> **Regla de honestidad para la memoria:** declarar esta secuencia de forma explícita. «Nuestra misión es la
> resiliencia de las comunicaciones en emergencia; nuestro ingreso del año uno procede de integradores de drones y
> de defensa, porque el ciclo de compra pública no sostiene a una empresa en fase semilla.» Un evaluador que lee
> esto ve criterio. Una proyección financiera con pedidos públicos imaginarios se detecta y descarta.

### Hipótesis de precio *(a validar en entrevistas)*
- Terminal A: **25.000–60.000 €/unidad**, según capacidad y cualificación
- Ingeniería de integración a medida: **30.000–120.000 €** por programa
- Configuración B como servicio: tarifa por día de despliegue o contrato marco de disponibilidad anual

---

## 8. Modelo de negocio

Tres flujos, en este orden:

1. **Ingeniería no recurrente (NRE)** — integración del terminal en la plataforma del cliente. Financia el desarrollo con dinero de cliente, no de inversor. Es el flujo que arranca en el mes 6.
2. **Venta de hardware** — terminales, con margen creciente según se estandariza el producto.
3. **Servicio** — capacidad desplegable para emergencias y, a largo plazo, minutos de contacto óptico.

La barrera de entrada no es la idea: es el **historial de vuelo demostrado** y, más adelante, la cualificación. Cada enlace validado con un cliente real es foso competitivo acumulado.

---

## 9. Plan de hitos y uso de los 60.000 €

### Hitos

| Meses | Hito | Criterio de éxito verificable |
|---|---|---|
| 0–2 | Constitución, sede en CV, instalación en el aeropuerto | Contrato de incubación firmado |
| 0–3 | Balance de enlace cerrado y arquitectura PAT congelada | Documento de diseño revisado por un asesor externo |
| 2–4 | Acuerdos: UPV/NTC o DAS Photonics (técnico) + Valyra u otro integrador (LOI) | Documentos firmados |
| 3–7 | Banco de laboratorio: enlace óptico estático sobre mesa, con perturbación inyectada | ≥ 500 Mbps con tasa de error acotada bajo vibración representativa |
| 6–10 | Tramitación de operación en categoría específica (SORA) y corredor de ensayo | Autorización operativa obtenida |
| 8–12 | **Primer vuelo con enlace: dron → tierra, 1–2 km** | Tasa, disponibilidad y tiempo de readquisición medidos → **TRL 4–5** |
| 10–15 | Primer contrato NRE con integrador | Facturación ≥ 40.000 € |
| 12–18 | Expediente de financiación de continuidad presentado | CDTI Neotec + ESA ScyLight/ARTES |

### Desglose presupuestario (hipótesis de partida)

| Partida | € |
|---|---|
| Optomecánica: telescopio compacto, cardán, espejo de dirección rápida | 18.000 |
| Electrónica y fotónica: SoC/FPGA, láser 1550 nm, detectores, moduladores | 12.000 |
| Banco de ensayo y metrología: mesa óptica, colimador, autocolimador, IMU de referencia | 8.000 |
| Horas de vuelo: alquiler de plataforma, piloto, seguros | 6.000 |
| Regulatorio: SORA, seguros de operación, tasas | 4.000 |
| Propiedad industrial y constitución societaria | 4.000 |
| Acción comercial: ferias del sector, visitas a cliente | 3.000 |
| Contingencia | 5.000 |
| **Total** | **60.000** |

> **Nota de honestidad presupuestaria, y conviene que aparezca en la memoria:** estos 60.000 € cubren material y validación, **no salarios**. El plan asume dedicación del promotor cubierta por ENISA Emprendedores, Neotec o recursos propios. Reconocerlo explícitamente transmite criterio; ocultarlo se detecta en la primera revisión financiera.

---

## 10. Equipo y necesidades

**Promotor:** electrónica, óptica y sistemas embarcados — cubre el núcleo tecnológico (diseño del terminal, electrónica de control, procesado embarcado).

**Huecos a cubrir, en orden de urgencia:**
1. **Control y mecatrónica de apuntamiento** — es el riesgo técnico número uno. Contratación o colaboración con grupo universitario.
2. **Operaciones de vuelo y regulatorio UAS** — piloto con habilitación y experiencia en categoría específica. Puede ser externalizado en fase inicial.
3. **Desarrollo de negocio en defensa** — perfil con acceso a compra pública de defensa y seguridad. Prescindible el primer año, crítico el segundo.

---

## 11. Ecosistema y socios a activar *(antes del 18 de diciembre)*

| Socio | Qué aporta | Estado |
|---|---|---|
| **Centro de Tecnología Nanofotónica (NTC-UPV)** | Laboratorio de fotónica de referencia europea, caracterización óptica | Por contactar |
| **DAS Photonics** (spin-off del NTC, ~100 empleados, fotónica volada en Hispasat y Eutelsat 7C) | Socio industrial de fotónica espacial a 70 km, posible cliente o partner | Por contactar |
| **Valyra Aerospace** (incubada) | Plataforma de vuelo, LOI, sinergia interna del programa | **Prioridad máxima** |
| **Aerocas / ENAIRE** | Espacio aéreo de ensayo: el aeropuerto tiene espacio aéreo controlado con tráfico comercial residual | Por explorar — **no afirmar en la memoria como existente hasta confirmarlo** |
| **PortCastelló** | Caso de uso de vigilancia de infraestructura, ya ha ensayado drones | Por contactar |
| **Red COMDES (Generalitat)** | Cliente ancla: red TETRA de emergencias, 360 flotas. Valida el hueco de cobertura | **Prioridad alta** |
| **ValSpace** | Consorcio espacial valenciano, prescripción ante el comité | Por contactar |

---

## 12. Riesgos y mitigación

| Riesgo | Sev. | Mitigación |
|---|---|---|
| Apuntamiento inestable por vibración de rotor | Alta | Arquitectura de dos etapas; caracterización en banco antes de volar; amortiguación pasiva en el anclaje |
| Bloqueo regulatorio BVLOS (es lo que mata negocios de drones en Europa) | Alta | Fase 1 dentro del alcance visual; tramitación SORA desde el mes 6; negociar corredor con Aerocas |
| Meteorología: niebla y lluvia degradan el óptico | Media | Canal RF de respaldo con conmutación automática — es la recomendación explícita de la literatura del sector |
| Entrada de un gran integrador en el nicho | Media | Velocidad, foco en plataforma pequeña, historial de vuelo acumulado |
| 60 k€ no cubren salarios | Alta | Encadenar ENISA / Neotec desde el mes 6; NRE de cliente desde el mes 10 |
| Ciclo de venta de defensa más largo de lo previsto | Media | Segmentos 1 y 3 (integradores civiles e infraestructura crítica) como puente de caja |
| Dependencia de compra pública para facturar | **Alta** | Ningún ingreso del año 1 procede de administración. Acceso al presupuesto público vía operadores privados adjudicatarios (segmento 4) |
| Deriva del relato hacia «radio de emergencias» y pérdida del requisito espacial | Alta | La capa troncal óptica encabeza siempre la memoria; la baja frecuencia se presenta como capa de cierre |
| Eficiencia de antena inviable en la capa LF desde dron | Alta | Se declara como línea de I+D, no como producto comprometido; producto del año 1 es la capa VHF/UHF |

---

## 13. Financiación posterior a la incubación

- **CDTI Neotec** — hasta ~250–500 k€ para empresa de base tecnológica joven. Objetivo: presentar en la convocatoria siguiente al mes 12.
- **ENISA Emprendedores** — préstamo participativo, sin dilución, cubre salarios.
- **ESA ScyLight / ARTES / GSTP** — programas de comunicaciones ópticas y tecnología. El acceso al ecosistema ESA que da la incubadora es precisamente la puerta de entrada.
- **EIC Accelerator** — horizonte año 3, una vez haya TRL 6 y tracción comercial.
- **Fondos de defensa europeos (EDF) y programas de doble uso** — horizonte año 2–3.

---

## 14. Calendario hasta la presentación

| Semana | Acción |
|---|---|
| 1 | Contactar Valyra, NTC-UPV y DAS Photonics. Es lo primero, porque las cartas tardan |
| 1–2 | 8–10 entrevistas de cliente: integradores de drones, bomberos, seguridad de infraestructura. Validar precio y necesidad |
| 2–3 | Cerrar balance de enlace y presupuesto técnico con números reales |
| 3–4 | Verificar competencia actualizada; ajustar posicionamiento |
| 4–6 | Redactar memoria técnica y plan de negocio |
| 6–8 | Conseguir al menos **una LOI firmada** |
| 8–10 | Revisión externa de la memoria por alguien del sector |
| 10–11 | Constituir la SL o dejar la constitución preparada; domicilio en la Comunitat Valenciana |
| **Antes del 18 dic** | Presentar en esabic.aeroportcastello.com con margen, no el último día |

---

## Anexo — Las preguntas difíciles del comité, y la respuesta

**«¿Esto no es simplemente una empresa de drones?»**
No. No fabricamos plataforma. Fabricamos la carga de pago de comunicación óptica. El dron es el vehículo de nuestro cliente. Nuestra tecnología es fotónica y control de precisión, herencia directa de terminales de comunicación láser espaciales.

**«¿Dónde está la conexión con el espacio?»**
En tres niveles: tecnología heredada del enlace intersatelital, hoja de ruta que termina en enlace dron-satélite, y encaje con la necesidad europea de diversidad de nodos receptores ópticos en IRIS² y EuroQCI.

**«Tesat y Mynaric ya hacen terminales ópticos.»**
Para satélite y para plataforma grande, en una gama de precio y de peso inaccesible al dron táctico. Nuestro nicho es el escalón inferior de peso, tamaño, consumo y coste, que hoy no está atendido.

**«El apuntamiento desde un dron que vibra es imposible.»**
El DLR ya demostró 1,25 Gbps desde un caza a Mach 0,7 con una arquitectura de dos etapas. Nuestro entorno dinámico es menos exigente. El riesgo es real y está presupuestado: es el primer hito de banco, antes de gastar en vuelo.

**«¿Por qué en Castellón y no en cualquier sitio?»**
Por el Centro de Tecnología Nanofotónica de la UPV y por DAS Photonics, que ha metido fotónica en satélites de comunicaciones reales, ambos a menos de una hora. Por el espacio aéreo del propio aeropuerto para ensayos. Y porque Valyra, en esta misma incubadora, es plataforma de integración y primer cliente.

**«¿Por qué baja frecuencia si su producto es óptico?»**
Porque resuelven problemas opuestos y el sistema necesita ambos. El óptico da capacidad pero exige línea de vista; la
baja frecuencia atraviesa follaje y terreno pero entrega bits por segundo. Nuestro valor está en la pasarela que
traduce entre ambos regímenes. Y somos explícitos en el límite: por debajo de 30 MHz la ionosfera refleja la señal,
así que la baja frecuencia nunca podrá ser el enlace espacial —solo la capa de cierre hacia las personas.

**«¿De verdad va a comprar esto una administración?»**
A corto plazo, no, y no lo planificamos así. Los consorcios de bomberos compran unidades de catálogo por precio, y
los grandes contratos de medios aéreos solo son accesibles a operadores consolidados. Nuestro año uno factura a
integradores de drones y a defensa. Al presupuesto público llegamos en año 2–3 por la puerta correcta: vendiendo al
operador que sí gana esas licitaciones. Lo público es nuestro inversor —el Plan Industrial y Tecnológico de
Seguridad y Defensa moviliza 10.471 M€ en doble uso—, no nuestro primer cliente.

**«¿Qué pasa si hay nubes o niebla?»**
Es la limitación conocida del óptico y por eso el sistema es híbrido con respaldo RF y conmutación automática. Y es, paradójicamente, nuestra tesis a largo plazo: volar por encima de la capa nubosa es precisamente lo que una estación fija no puede hacer.

---

## Fuentes

- ESA BIC Valencia Region, 3ª convocatoria — [Última Hora](https://www.ultimahora.es/noticias/comunidades/2026/09/20/2712557/aeropuerto-castellon-abre-tercera-convocatoria-para-sumar-cuatro-nuevas-startup-incubadora-esa.html) · [Valencia News](https://valencianews.es/comunidad-valenciana/aeropuerto-castellon-cuatro-start-ups-esa-bic/)
- Startups incubadas (ediciones 1 y 2) — [El Español / Invertia](https://www.elespanol.com/invertia/disruptores/ecosistema-startup/aceleradoras/20260331/collimate-space-synaptyx-valyra-aerospace-umibots-nuevo-cuarteto-disruptor-aeropuerto-castellon/1003744190488_0.html)
- Enlace láser 1,25 Gbps desde plataforma aérea rápida, proyecto DODfast (DLR / Airbus / ViaLight) — [SPIE](https://spie.org/news/5928-laser-communication-between-fast-flying-platform-and-ground-station)
- Enlaces ópticos directos de alta velocidad y limitación por nubosidad — [DLR](https://elib.dlr.de/66370/1/Direct_Optical_HighSpeed_DL_-_16th_Ka-Band_20101021.pdf)
- DAS Photonics, spin-off del NTC-UPV — [UPV Innovación](https://innovacion.upv.es/empresas/das-photonics/)
- Pruebas de dron para control y vigilancia portuaria — [PortCastelló](https://www.portcastello.com/en/communication/press-releases/2025/portcastello-carries-out-drone-flight-tests-for-port-control-and-surveillance/)
- Operación BVLOS y categoría específica en España — [ENAIRE](https://www.enaire.es/servicios/drones/todo_lo_necesario_para_volar_tu_dron/como_volar_drones_en_espacio_aereo_no_controlado)
- Plan Industrial y Tecnológico para la Seguridad y la Defensa, 10.471 M€ en doble uso — [La Moncloa](https://www.lamoncloa.gob.es/consejodeministros/resumenes/Documents/2025/230425-plan-industrial-y-tecnologico-para-la-seguridad-y-la-defensa.pdf)
- España mantiene el 2 % del PIB en defensa en 2026 — [Euronews](https://es.euronews.com/2026/03/16/espana-mantendra-en-2026-el-gasto-en-defensa-del-2-por-ciento-del-pib)
- Contratación del Consorci Provincial de Bombers de València — [bombersdv.es](https://www.bombersdv.es/es/category/contractacio-es/)
- Red COMDES, TETRA 380–400 MHz, 206 estaciones base y 360 flotas — [Generalitat Valenciana](https://comdes.gva.es/es/la-red-comdes)
- Comunicación a través del terreno (TTE): HeyPhone y Nicola a 87 kHz, Cave-Link 20–140 kHz — [Through-the-earth communications](https://en.wikipedia.org/wiki/Through-the-earth_mine_communications)
- Atenuación por follaje y comparativa VHF/UHF — [Wireless Wave Attenuation in Forests: An Overview of Models, MDPI Forests](https://www.mdpi.com/1999-4907/15/9/1587)
