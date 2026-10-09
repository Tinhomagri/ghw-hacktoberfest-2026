# Prompts para o GitHub Copilot

Três challenges do GHW pedem o Copilot por nome. Abra o VS Code com o Copilot
ativo e cole os prompts abaixo no chat lateral (modo Agent, quando disponível).

---

## Challenge 4 — Getting Started with GitHub Copilot

Repo já criado: `Tinhomagri/getting-started-with-github-copilot`

O exercício é guiado: a Mona publica um passo por vez na issue #1 do repo. Abra
o repo num Codespace e siga. Os prompts que o exercício pede são, em ordem:

1. `@workspace explique o que este projeto faz e como ele está estruturado`
2. `Adicione um campo de busca na página para filtrar as atividades por nome`
3. `/tests gere testes para o endpoint de inscrição de alunos`
4. `/fix` — no erro que aparecer ao rodar a aplicação
5. No pull request, use **Copilot → Summary** para gerar a descrição

Submeta: link do repo + print da issue #1 fechada.

---

## Challenge 5 — Build a Simple Application with Copilot

Crie uma pasta vazia, abra no VS Code e peça ao Copilot:

> Crie um *Habit Tracker* como página HTML única, sem dependências externas.
> Requisitos: adicionar e remover hábitos; marcar cada dia dos últimos 30 dias
> como feito ou não; mostrar a sequência atual e a maior sequência de cada
> hábito; persistir tudo em localStorage; layout responsivo com CSS Grid; tema
> claro e escuro seguindo `prefers-color-scheme`. Sem framework, sem CDN.

Depois, duas ou três iterações para mostrar o ciclo de trabalho:

> O contador de sequência está errado quando pulo um dia no meio. Corrija.

> Adicione um botão que exporta os dados em JSON e outro que importa.

> Torne a grade de 30 dias navegável por teclado, com foco visível.

Submeta: link do repo + duas frases sobre o que o Copilot gerou.

---

## Challenge 6 — Use Copilot to complete another challenge

Reaproveita o trabalho da trilha Tiger Data. Abra este repositório no VS Code e
peça:

> Leia `tiger/01_hypertable.sql` e `tiger/02_continuous_aggregate.sql`. Crie
> `dashboard/app.py`: um app Flask que lê a connection string da variável de
> ambiente `TIMESCALE_SERVICE_URL`, consulta a view `app_metrics_hourly` e
> serve uma página com um gráfico de latência média e p95 por hora, por serviço.
> Use psycopg3 com queries parametrizadas, Chart.js via CDN, e trate o caso de
> a view estar vazia. Não escreva credenciais no código.

Validação antes de submeter:

```bash
set -a && . .env && set +a
.venv/bin/pip install flask
.venv/bin/python dashboard/app.py
```

Submeta: link deste repo + print do dashboard rodando.

---

## Disclosure

O MLH exige declarar o uso de IA. A trilha Tiger Data deste repositório foi
construída com Claude Code (Opus 5); as challenges acima são feitas com GitHub
Copilot. Declare os dois.
