# B0.1 · Circuito

> *English summary:* the proposed 8-step performance circuit mapped against what cicfa.lol v0.1 shows from outside, one evidence level per row. External observation of 2026-10-11; pending independent review.

```
CIRCUITO      propuesta conceptual de la conversación de origen (Hermes); no se comprobó qué partes están implementadas
OBSERVACIÓN   cicfa.lol · 2026-10-11 · desde afuera, sin cuenta, sin repositorio · pendiente de revisión independiente
NIVELES       observado en interfaz · declarado · inferido · verificado en código · verificado por ejecución · desconocido
```

## Los 8 pasos

| # | Paso propuesto | Qué muestra cicfa.lol v0.1 | Nivel de evidencia | Brecha |
|---|---|---|---|---|
| 1 | Un usuario seudónimo publica el bounty | `/missions/new` "Broadcast", solo con login. "JACK IN": handle + passphrase; "Unknown handle mints a new identity. No email, no wallet, no trace." | observado en interfaz (el gate) · declarado (la identidad) | el formulario no fue visto; qué campos exige: desconocido |
| 2 | El proponente o un fondo colectivo financia la recompensa de antemano | columna `POOL (ETH)`; bloque `BACKERS` por misión; pools en Sepolia (testnet) | observado en interfaz | custodia del pool — escrow on-chain o registro en base de datos: desconocido |
| 3 | Un artista, investigador o colectivo toma el encargo | bloque `CLAIMS`; estados `ACTIVE → FULFILLED_PENDING` | observado en interfaz | si existe una "toma" previa al claim (reserva, plazo): desconocido |
| 4 | Produce la entrega y presenta sus fuentes | claims en texto, visibles en la página de la misión | observado en interfaz | adjuntos, hashes, formato de evidencia: desconocido |
| 5 | La institución recibe una invitación a responder, corregir, discutir o aportar documentación | ningún bloque, estado ni rol para la parte examinada | observado en interfaz (ausencia) | no existe en v0.1 (inferido); sería una etapa fuera de plataforma |
| 6 | Una revisión independiente verifica el cumplimiento; la IA asiste, no sustituye | bloque `CICFA CURATION`: veredictos firmados por `openai/gpt-oss-120b` ("testing mode — auto-fulfilled") y `llama-3.3-70b-versatile`; el CSS define `IN_CURATION`, `CHALLENGED` | declarado (los veredictos) · inferido (los estados en CSS) | revisión humana: no observada; "auto-fulfilled" invierte el criterio |
| 7 | Se distribuye la recompensa según reglas previamente publicadas, independientemente de que la institución coopere | bloque `Settlement`: "Paid. Dispute window cleared → payout released." + enlace a una tx en Sepolia; estado `PAID` | observado en interfaz (texto y enlace) | mecanismo detrás de "Paid": desconocido; ventana de disputa — duración y cumplimiento en código: desconocido |
| 8 | Se presenta el circuito completo como obra | la página de misión reúne `objective / brief / rules`, curaduría, settlement, backers, claims | observado en interfaz | exportación del registro: no observada; créditos, archivo, licencia: ausentes |

## Transversales

| Transversal | Qué muestra cicfa.lol v0.1 | Nivel de evidencia | Brecha |
|---|---|---|---|
| Identidad y rastro | "No email, no wallet, no trace" | declarado | qué se guarda de un handle; cómo cobra un handle sin wallet: desconocido |
| Reglas publicadas antes del primer claim | campo `rules` por misión (la misión 001 lo usa como formato de divulgación responsable) | observado en interfaz | inmutabilidad tras el primer claim: desconocido |
| Disputa | estado `CHALLENGED` en CSS; "Dispute window cleared" en settlement | inferido · declarado | quién puede disputar, cómo, con qué plazo: desconocido |
| Revisión humana independiente | — | observado en interfaz (ausencia) | no existe un rol; la Operación 001 lo diseñó (jurado 0/5) y nunca lo sentó |
| Derecho a réplica | — | observado en interfaz (ausencia) | fuera de plataforma hasta que exista |
| Registro exportable | — | desconocido | sin API pública: `/api`, `/robots.txt`, `/sitemap.xml` → 404 (observado en interfaz) |
| Entorno de prueba | misiones con títulos y handles de prueba (`@pentest_audit_…`) conviven con las reales en el board | inferido | flag TEST, staging: desconocido |
| Dinero real | pools y settlement en Sepolia | observado en interfaz | mainnet: no observado; la billetera comprometida (DEE-30) no interviene y no debe intervenir |

## Lectura

De los 8 pasos, la interfaz muestra algo para 1, 2, 3, 4, 6, 7 y 8; nada para 5. Lo que muestra es superficie: estados, bloques, textos, enlaces. Ningún paso está `verificado en código` ni `verificado por ejecución`. Las brechas que deciden el Ensayo 0 son dos: la revisión humana en paralelo a la curaduría (6) y el mecanismo real de liquidación y disputa (7).

// pendiente de revisión independiente: esta tabla se reescribe con la evidencia revisada de la primera corrida del OS.

**'No observado' no equivale a 'no existe'. 'Paid' en pantalla no prueba el mecanismo de liquidación.**
