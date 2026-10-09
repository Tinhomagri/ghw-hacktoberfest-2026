# Tiger Cloud — setup (challenge "Tiger CLI + MCP")

## 1. Conta e serviço
1. Criar conta em https://console.cloud.timescale.com (free trial, sem cartão).
2. `Create service` → PostgreSQL + TimescaleDB → região mais próxima.
3. Salvar a connection string exibida uma única vez.

## 2. CLI
Não existe host `tiger-cli.timescale.com`. O binário vem das releases do GitHub:

```bash
V=0.26.0
curl -fsSL -O https://github.com/timescale/tiger-cli/releases/download/v$V/tiger-cli_Linux_x86_64.tar.gz
tar xzf tiger-cli_Linux_x86_64.tar.gz
install -m755 tiger ~/.local/bin/tiger
tiger version && tiger auth login && tiger service list
```

O arquivo `.sha256` publicado contém só o hash, sem o nome do arquivo, então
`sha256sum -c` falha — compare manualmente com `sha256sum` do tarball.

## 3. MCP no Claude Code
```bash
claude mcp add tiger -- tiger mcp start
```
Depois: `/mcp` para confirmar que o servidor `tiger` conectou.

Teste em linguagem natural: *"liste meus serviços Tiger e descreva o schema do banco"*.

## 4. Credenciais
O console entrega um `.env` pronto. Ele está em `ghw-hacktoberfest/.env` e é
ignorado pelo git (`.gitignore`), porque contém a senha em claro.

```bash
set -a && . .env && set +a
```
Isso define `TIMESCALE_SERVICE_URL` e as variáveis `PG*` padrão, usadas tanto
pelo `psql` quanto pelo `04_ingest.py`.

## 5. Ordem de execução
```bash
psql "$TIMESCALE_SERVICE_URL" -f 01_hypertable.sql
psql "$TIMESCALE_SERVICE_URL" -f 02_continuous_aggregate.sql
psql "$TIMESCALE_SERVICE_URL" -f 03_iot_sensors.sql
psql "$TIMESCALE_SERVICE_URL" -f 04_financial_schema.sql
python 04_ingest.py BTC/USD ETH/USD
psql "$TIMESCALE_SERVICE_URL" -f 05_pgvector.sql
```
