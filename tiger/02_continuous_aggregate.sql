-- GHW Hacktoberfest / Tiger Data #3: continuous aggregate (CAGG)
-- Pré-requisito: 01_hypertable.sql

CREATE MATERIALIZED VIEW IF NOT EXISTS app_metrics_hourly
WITH (timescaledb.continuous) AS
SELECT
    time_bucket('1 hour', time)                        AS bucket,
    service,
    count(*)                                           AS requests,
    count(*) FILTER (WHERE status_code >= 500)         AS errors,
    avg(latency_ms)                                    AS avg_latency_ms,
    approx_percentile(0.95, percentile_agg(latency_ms)) AS p95_latency_ms,
    max(latency_ms)                                    AS max_latency_ms
FROM app_metrics
GROUP BY bucket, service
WITH NO DATA;

-- Refresh automático em background: janela de 30 dias até 1h atrás, a cada 30 min.
SELECT add_continuous_aggregate_policy('app_metrics_hourly',
    start_offset      => INTERVAL '30 days',
    end_offset        => INTERVAL '1 hour',
    schedule_interval => INTERVAL '30 minutes',
    if_not_exists     => TRUE);

CALL refresh_continuous_aggregate('app_metrics_hourly', NULL, NULL);

-- Antes x depois: compare o custo das duas consultas.
EXPLAIN ANALYZE
SELECT time_bucket('1 hour', time), service, avg(latency_ms)
FROM app_metrics
WHERE time > now() - INTERVAL '7 days'
GROUP BY 1, 2;

EXPLAIN ANALYZE
SELECT bucket, service, avg_latency_ms
FROM app_metrics_hourly
WHERE bucket > now() - INTERVAL '7 days';

SELECT bucket, service, requests, errors,
       round(avg_latency_ms::numeric, 2) AS avg_ms,
       round(p95_latency_ms::numeric, 2) AS p95_ms
FROM app_metrics_hourly
ORDER BY bucket DESC
LIMIT 20;
