-- GHW Hacktoberfest / Tiger Data #6: busca vetorial com pgvector
-- Híbrido: similaridade semântica + filtro temporal na mesma query.

CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS doc_embeddings (
    id        BIGSERIAL,
    time      TIMESTAMPTZ NOT NULL DEFAULT now(),
    source    TEXT        NOT NULL,
    content   TEXT        NOT NULL,
    embedding VECTOR(1536) NOT NULL
);

SELECT create_hypertable('doc_embeddings', by_range('time'), if_not_exists => TRUE);

-- Índice aproximado (HNSW) para distância por cosseno.
CREATE INDEX IF NOT EXISTS doc_embeddings_hnsw_idx
    ON doc_embeddings USING hnsw (embedding vector_cosine_ops);

-- Busca híbrida: top-5 mais parecidos, restritos aos últimos 30 dias.
-- $1 = vetor da consulta. Sempre parametrize; nunca concatene o embedding na string.
PREPARE hybrid_search (VECTOR(1536)) AS
SELECT id, time, source, left(content, 120) AS preview,
       1 - (embedding <=> $1) AS similarity
FROM doc_embeddings
WHERE time > now() - INTERVAL '30 days'
ORDER BY embedding <=> $1
LIMIT 5;

-- EXECUTE hybrid_search('[0.01, ...]'::vector);

-- Seed de demonstração: vetores aleatórios normalizados, só para exercitar o
-- índice HNSW. Em produção, o embedding vem de um modelo (OpenAI, Voyage, etc.).
INSERT INTO doc_embeddings (time, source, content, embedding)
SELECT
    now() - (i || ' hours')::INTERVAL,
    'ghw/docs',
    'Trecho de documentação #' || i,
    v.embedding
FROM generate_series(1, 200) AS i
CROSS JOIN LATERAL (
    -- O range depende de i para que a subquery seja correlacionada e reavaliada
    -- por linha; sem isso o planner a executa uma vez e todas as linhas ficam
    -- com o mesmo vetor.
    SELECT array_agg(random() - 0.5)::vector AS embedding
    FROM generate_series(i, i + 1535)
) AS v;

-- Prova de que a busca híbrida roda: usa o vetor da linha 1 como consulta.
-- (EXECUTE não aceita subquery como parâmetro; na aplicação o vetor chega
--  como parâmetro vindo do cliente, igual ao PREPARE acima.)
WITH q AS (SELECT embedding FROM doc_embeddings ORDER BY id LIMIT 1)
SELECT d.id, d.time, d.source, left(d.content, 40) AS preview,
       round((1 - (d.embedding <=> q.embedding))::numeric, 4) AS similarity
FROM doc_embeddings d, q
WHERE d.time > now() - INTERVAL '30 days'
ORDER BY d.embedding <=> q.embedding
LIMIT 5;
