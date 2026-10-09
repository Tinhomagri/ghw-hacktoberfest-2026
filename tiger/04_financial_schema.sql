-- GHW Hacktoberfest / Tiger Data #5: pipeline de dados financeiros (schema)

CREATE TABLE IF NOT EXISTS symbols (
    symbol TEXT PRIMARY KEY,
    name   TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS ticks (
    time   TIMESTAMPTZ      NOT NULL,
    symbol TEXT             NOT NULL REFERENCES symbols (symbol),
    open   DOUBLE PRECISION NOT NULL,
    high   DOUBLE PRECISION NOT NULL,
    low    DOUBLE PRECISION NOT NULL,
    close  DOUBLE PRECISION NOT NULL,
    volume DOUBLE PRECISION NOT NULL,
    UNIQUE (time, symbol)
);

SELECT create_hypertable('ticks', by_range('time'), if_not_exists => TRUE);

-- Candles de 1 hora materializados a partir dos ticks de 1 minuto.
CREATE MATERIALIZED VIEW IF NOT EXISTS ticks_hourly
WITH (timescaledb.continuous) AS
SELECT
    time_bucket('1 hour', time) AS bucket,
    symbol,
    first(open, time) AS open,
    max(high)         AS high,
    min(low)          AS low,
    last(close, time) AS close,
    sum(volume)       AS volume
FROM ticks
GROUP BY bucket, symbol
WITH NO DATA;

SELECT add_continuous_aggregate_policy('ticks_hourly',
    start_offset      => INTERVAL '7 days',
    end_offset        => INTERVAL '1 hour',
    schedule_interval => INTERVAL '15 minutes',
    if_not_exists     => TRUE);

-- Compressão dos chunks antigos (economia de armazenamento no Tiger Cloud).
ALTER TABLE ticks SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'symbol',
    timescaledb.compress_orderby   = 'time DESC'
);
SELECT add_compression_policy('ticks', INTERVAL '7 days', if_not_exists => TRUE);
