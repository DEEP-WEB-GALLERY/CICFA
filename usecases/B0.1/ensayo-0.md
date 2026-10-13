# B0.1 · Ensayo 0 — Circuito cerrado: CICFA se encarga a sí misma

> *English summary:* the discriminating experiment. A TEST mission on cicfa.lol whose object is CICFA's own Operation 001 — a consenting institution (us), no real money (Sepolia), real conflict (our own failure). It measures what the platform completes and whether the exported record reads as artwork, conflict or report. Designed, not scheduled; blocked until the agreements below exist.

```
ESTADO          diseñado · planificado · bloqueado (ver precondiciones)
QUÉ DISCRIMINA  H-circuito contra H-antagonismo (hipotesis.md)
OBJETO          Operación 001 / MOMA.SYM — la institución consiente trivialmente: somos nosotros
ENTORNO         misión marcada TEST en cicfa.lol · pools y liquidación en Sepolia · ningún fondo real · ninguna institución real
```

## Objeto

Una misión `demand` marcada TEST cuyo encargo es reconstruir, con fuentes públicas, la economía visible de la Operación 001: el pot lanzado el 2026-03-17 (v2 el 2026-03-18); la única contribución que recibió (Ξ0.000662, 2026-03-19); el sweep del 2026-07-10 hacia una dirección colectora que vació 77 billeteras en doce días; el fork público del repositorio; el jurado que nunca se sentó (0/5); las cero submissions (verificado 2026-10-11). Todo está en el archivo público del programa; nada requiere acceso a sistemas de nadie.

// el conflicto es real porque la falla es nuestra. no hace falta inventar un adversario para que duela.

## Participantes mínimos

| Rol | Quién | Restricción |
|---|---|---|
| Proponente | un colaborador — **no Boris** | publica la misión y fija las reglas; el circuito tiene que correr sin el principal adentro |
| Ejecutor | un colaborador | toma el encargo y entrega con fuentes |
| Revisor humano independiente | un colaborador distinto de los dos anteriores | dictamina en paralelo a la curaduría LLM; su desacuerdo se conserva |
| Disputante | un colaborador | ensaya una disputa real dentro de la ventana |
| Lectores a ciegas | Boris + 2 | califican el registro exportado sin saber quién hizo qué |

## Etapas a cubrir

1. **Publicación** — el proponente emite la misión TEST con `objective / brief / rules` según `reglas-marco.md`.
2. **Toma** — el ejecutor la reclama; se registra si la plataforma distingue "tomar" de "entregar".
3. **Evidencia** — entrega con fuentes públicas, en las cinco secciones de la regla 9.
4. **Evaluación** — curaduría LLM y revisor humano, en paralelo; se registran ambos veredictos y sus desacuerdos.
5. **Disputa ensayada** — el disputante impugna; se mide si existe ventana, cómo se entra a `CHALLENGED`, quién resuelve.
6. **Liquidación de prueba** — settlement en Sepolia; se registra la tx y quién la ejecutó.
7. **Registro exportable** — todo lo anterior en un formato abierto que sobreviva a la plataforma.

## Mediciones

- **Mecánica** — por etapa: completada en plataforma · completada fuera de plataforma · no completada. Cada fila con su nivel de evidencia; `verificado por ejecución` es lo que este ensayo viene a producir.
- **Lectura** — tres lectores califican a ciegas el registro exportado en una escala de tres: ¿lee como **obra**, como **conflicto**, o como **informe** de investigación convencional? Se registran los tres votos y una línea de justificación cada uno. No hay promedio: tres lecturas, no una.

## Reglas de decisión

- ≥2 etapas no completables en plataforma → prioridad a requisitos de plataforma antes de cualquier decisión de variante.
- Circuito completo pero registro que lee "informe" → H-antagonismo gana peso; reformular hacia las variantes de estrés / auditoría-performance (`variantes.md`).
- Circuito completo y registro que lee como obra → H-circuito sobrevive; la elección de variante sigue con criterios institución-agnósticos.

## Precondiciones y bloqueos

| Bloqueo | Responsable | Estado |
|---|---|---|
| Acceso de lectura al repositorio de la plataforma | Manu (plataforma) | pendiente |
| Acuerdo para una misión marcada TEST | Manu | pendiente |
| Curaduría en modo asistido: el veredicto LLM no cierra la misión; el humano confirma | Manu | pendiente |
| Custodia y fondos de prueba en Sepolia: quién tiene las llaves, quién ejecuta la tx | Manu / desconocido | pendiente |
| Entorno: producción con flag TEST o staging separado | Manu | pendiente |
| Participantes (cuatro roles + dos lectores) | Boris | pendiente |
| Alcance exacto del encargo y plazo | Boris | pendiente |
| Aprobación del ensayo | Boris | pendiente |
| **Bisagra (run-01):** desacoplar el pago del veredicto FULFILLED — retener las misiones con fondos en `FULFILLED_PENDING` durante una ventana declarada y/o hasta confirmación humana. Hoy el barrido se mina ~1 min después del veredicto, así que las etapas 4–6 no pueden ejercerse. | Manu | pendiente — **es el bloqueo mínimo** |
| Observar el formulario Broadcast con una cuenta (campos, TYPE, pool, opciones de curaduría/TEST) — un humano tiene que hacer el login | Boris | pendiente (D12) |
| Condición de validez, no de plataforma: la cuenta operadora de la plataforma debe rotar su passphrase antes del ensayo (alegación pública de credenciales débiles + una misión posteada bajo esa cuenta por un tercero; nada probado por nosotros) | Manu (avisado por Boris) | pendiente (D13) |

Ninguna acción sobre la plataforma — publicar, respaldar, reclamar, disputar — ocurre antes de que todas las filas digan "acordado".

## Plantilla del registro exportable

```
MISIÓN        id · tipo · título · flag TEST · fecha de publicación · handle del proponente
ENCARGO       objective · brief · rules (verbatim, con hash)
POOL          monto (ETH Sepolia) · backers (handles) · custodia declarada
TOMA          handle del ejecutor · fecha · estado al tomar
ENTREGA       hechos · interpretaciones · contradicciones · preguntas abiertas · no establecido · fuentes (URL + fecha de acceso)
CURADURÍA     modelo · veredicto · fecha · texto verbatim
REVISIÓN      revisor humano · veredicto · desacuerdos con la curaduría
DISPUTA       disputante · argumento · estado alcanzado · resolución · fecha
LIQUIDACIÓN   tx hash (Sepolia) · fecha · monto · destinatario · quién ejecutó
MECÁNICA      por etapa: en plataforma / fuera / no completada · nivel de evidencia
LECTURA       3 lectores × {obra, conflicto, informe} + justificación
EXPORT        formato · fecha · hash del archivo · dónde se archiva
```

// lo que no entre en esta plantilla no pasó. lo que no se exporte, pasó en una base de datos ajena.

Una simulación local prepara el camino; no cuenta como verificación de la plataforma.
