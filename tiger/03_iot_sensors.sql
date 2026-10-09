-- GHW Hacktoberfest / Tiger Data #4: dataset IoT simulado
-- Metadados relacionais (sensors) + série temporal (sensor_data).

CREATE TABLE IF NOT EXISTS sensors (
    id       SERIAL PRIMARY KEY,
    type     TEXT NOT NULL,
    location TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS sensor_data (
    time        TIMESTAMPTZ      NOT NULL,
    sensor_id   INTEGER          NOT NULL REFERENCES sensors (id),
    temperature DOUBLE PRECISION NOT NULL,
    cpu         DOUBLE PRECISION NOT NULL
);

SELECT create_hypertable('sensor_data', by_range('time'), if_not_exists => TRUE);

INSERT INTO sensors (type, location)
SELECT type, location
FROM unnest(
    ARRAY['a', 'a', 'b', 'b'],
    ARRAY['floor', 'ceiling', 'floor', 'ceiling']
) AS s(type, location)
WHERE NOT EXISTS (SELECT 1 FROM sensors);

-- 24h de leituras, uma a cada 5 segundos, para cada sensor.
INSERT INTO sensor_data (time, sensor_id, temperature, cpu)
SELECT
    t,
    s.id,
    round((random() * 100)::numeric, 2),
    round(random()::numeric, 2)
FROM generate_series(now() - INTERVAL '24 hours', now(), INTERVAL '5 seconds') AS t
CROSS JOIN sensors AS s;

-- Médias por 30 minutos, com os metadados do sensor via JOIN.
SELECT
    time_bucket('30 minutes', sd.time) AS bucket,
    s.location,
    s.type,
    round(avg(sd.temperature)::numeric, 2) AS avg_temp,
    round(avg(sd.cpu)::numeric, 2)         AS avg_cpu
FROM sensor_data sd
JOIN sensors s ON s.id = sd.sensor_id
WHERE sd.time > now() - INTERVAL '6 hours'
GROUP BY bucket, s.location, s.type
ORDER BY bucket DESC, s.location;

-- Última leitura de cada sensor.
SELECT DISTINCT ON (sensor_id) sensor_id, time, temperature, cpu
FROM sensor_data
ORDER BY sensor_id, time DESC;
