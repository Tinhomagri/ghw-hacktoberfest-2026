-- GHW Hacktoberfest / Tiger Data #2: primeira hypertable
-- Tema: telemetria de requisições de uma API web.

CREATE TABLE IF NOT EXISTS app_metrics (
    time        TIMESTAMPTZ      NOT NULL,
    service     TEXT             NOT NULL,
    route       TEXT             NOT NULL,
    status_code SMALLINT         NOT NULL,
    latency_ms  DOUBLE PRECISION NOT NULL
);

SELECT create_hypertable('app_metrics', by_range('time'), if_not_exists => TRUE);

CREATE INDEX IF NOT EXISTS app_metrics_service_time_idx
    ON app_metrics (service, time DESC);

-- Dados sintéticos: 7 dias, 1 ponto por minuto, 3 serviços.
INSERT INTO app_metrics (time, service, route, status_code, latency_ms)
SELECT
    t,
    s.service,
    (ARRAY['/api/habitos', '/api/metas', '/api/login'])[1 + floor(random() * 3)::int],
    CASE WHEN random() < 0.03 THEN 500 WHEN random() < 0.08 THEN 404 ELSE 200 END,
    round((20 + random() * 180)::numeric, 2)
FROM generate_series(now() - INTERVAL '7 days', now(), INTERVAL '1 minute') AS t
CROSS JOIN (VALUES ('backend'), ('frontend'), ('worker')) AS s(service);

-- Consultas de verificação.
SELECT hypertable_name, num_chunks
FROM timescaledb_information.hypertables
WHERE hypertable_name = 'app_metrics';

SELECT
    time_bucket('1 hour', time) AS bucket,
    service,
    count(*)                        AS requests,
    round(avg(latency_ms)::numeric, 2) AS avg_latency_ms,
    max(latency_ms)                 AS max_latency_ms
FROM app_metrics
WHERE time > now() - INTERVAL '24 hours'
GROUP BY bucket, service
ORDER BY bucket DESC, service;
