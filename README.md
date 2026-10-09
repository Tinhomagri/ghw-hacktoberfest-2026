# GHW: Hacktoberfest — 09–15/out/2026

Evento: https://events.mlh.io/events/14553-global-hack-week-hacktoberfest
Status: **registrado**. Check-in é feito pelos organizadores, não há self check-in.

21 challenges, sem premiação em dinheiro — valem pontos de XP. Toda submissão
exige screenshot ou link, feitos por você na plataforma do MLH.

## Trilha Tiger Data (6) — código pronto em `tiger/`

| # | Challenge | Arquivo | Falta |
|---|---|---|---|
Serviço: `db-72010` — PostgreSQL 18.6 + TimescaleDB 2.30.2. Todos os scripts já
foram executados nele, exceto a ingestão financeira.

| # | Challenge | Arquivo | Estado | Falta |
|---|---|---|---|---|
| 1 | Tiger CLI + MCP | `tiger/00_setup.md` | **feito** — CLI 0.26.0, OAuth ok, MCP `✔ Connected` no Claude Code | screenshot |
| 2 | Primeira hypertable | `tiger/01_hypertable.sql` | **rodado** — `app_metrics`, 2 chunks, 30.240 linhas | screenshot |
| 3 | Continuous aggregates | `tiger/02_continuous_aggregate.sql` | **rodado** — `app_metrics_hourly`, 14,2 ms → 0,2 ms | screenshot do EXPLAIN |
| 4 | Dataset IoT simulado | `tiger/03_iot_sensors.sql` | **rodado** — `sensor_data`, 69.124 linhas, 4 sensores | screenshot |
| 5 | Pipeline financeiro | `tiger/04_financial_schema.sql` + `tiger/04_ingest.py` | **rodado** — 1.050 candles reais (BTC/ETH/SOL) via Coinbase, `ticks_hourly` materializado | screenshot |
| 6 | Busca vetorial pgvector | `tiger/05_pgvector.sql` | **rodado** — `doc_embeddings`, 200 vetores, HNSW, busca híbrida OK | screenshot |

O ingest usa a API pública da Coinbase (sem chave). Definir
`TWELVE_DATA_API_KEY` troca a fonte para a Twelve Data automaticamente.

```bash
set -a && . .env && set +a
.venv/bin/python tiger/04_ingest.py --once BTC-USD ETH-USD SOL-USD
```

Evidência da busca híbrida: o documento usado como consulta volta com
similaridade 1,0000 e os demais entre 0,05 e 0,07 — o esperado para vetores
aleatórios em 1536 dimensões.

## Trilha GitHub (7) — conta + screenshot

| # | Challenge | Estado |
|---|---|---|
| 1 | GitHub Student Developer Pack | precisa da sua verificação estudantil |
| 2 | Code with Codespaces | repo criado: `Tinhomagri/code-with-codespaces` — exige abrir um Codespace |
| 3 | Intro to Repository Management | **concluído** — `Tinhomagri/introduction-to-repository-management`, todos os 5 passos, exercício fechado |
| 4 | Getting Started with Copilot | repo criado: `Tinhomagri/getting-started-with-github-copilot` — exige Copilot no VS Code |
| 5 | Build a Simple Application com Copilot | exige Copilot |
| 6 | Usar Copilot em outra challenge | exige Copilot |

As challenges 4, 5 e 6 pedem o GitHub Copilot por nome. Este trabalho foi feito
com Claude Code, não com Copilot — submeter como se fosse Copilot seria falso.

## Trilha Cursor / Grok Bot (8) — apps desktop, não automatizáveis daqui

1. Cursor Pro (há promo code no evento — ver abaixo)
2. CHALLENGE 1: mini app com Cursor
3. CHALLENGE 2: benchmark de modelos do Cursor
4. CHALLENGE 3: primeiro Grok Bot
5. CHALLENGE 4: ensinar uma task ao Bot
6. CHALLENGE 5: database de oportunidades
7. CHALLENGE 6: workflow de browser
8. CHALLENGE 7: relay entre dois Bots

## Promo code disponível

**Cursor Pro** — exige, na sua conta MLH: telefone verificado, GitHub vinculado
e conta GitHub com 30+ dias. Resolva isso em mlh.io antes de pedir o código.

## Evidências

Screenshots do console do Tiger Cloud em `evidencias/` — um por challenge,
prontos para anexar na submissão do MLH.
