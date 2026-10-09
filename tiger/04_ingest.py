"""Ingestão de candles de 1 minuto no Tiger Cloud.

Fonte padrão: Coinbase Exchange (API pública, sem chave).
Se TWELVE_DATA_API_KEY estiver definida, usa a Twelve Data.

Uso:
    set -a && . .env && set +a       # define TIMESCALE_SERVICE_URL
    python tiger/04_ingest.py --once BTC-USD ETH-USD
"""

import os
import sys
import time
from datetime import datetime, timezone

import psycopg
import requests

DSN = os.environ.get("TIMESCALE_SERVICE_URL") or os.environ["TIGER_DSN"]
TWELVE_DATA_API_KEY = os.environ.get("TWELVE_DATA_API_KEY")
POLL_SECONDS = 60
HEADERS = {"User-Agent": "ghw-hacktoberfest-ingest/1.0"}

UPSERT = """
INSERT INTO ticks (time, symbol, open, high, low, close, volume)
VALUES (%s, %s, %s, %s, %s, %s, %s)
ON CONFLICT (time, symbol) DO UPDATE
SET close = EXCLUDED.close,
    high = GREATEST(ticks.high, EXCLUDED.high),
    low = LEAST(ticks.low, EXCLUDED.low),
    volume = EXCLUDED.volume
"""


def fetch_coinbase(symbol: str) -> list[tuple]:
    response = requests.get(
        f"https://api.exchange.coinbase.com/products/{symbol}/candles",
        params={"granularity": 60},
        headers=HEADERS,
        timeout=30,
    )
    response.raise_for_status()
    # Cada candle: [time, low, high, open, close, volume]
    return [
        (
            datetime.fromtimestamp(row[0], tz=timezone.utc),
            symbol,
            float(row[3]),
            float(row[2]),
            float(row[1]),
            float(row[4]),
            float(row[5]),
        )
        for row in response.json()
    ]


def fetch_twelve_data(symbol: str, size: int = 30) -> list[tuple]:
    response = requests.get(
        "https://api.twelvedata.com/time_series",
        params={
            "symbol": symbol,
            "interval": "1min",
            "outputsize": size,
            "apikey": TWELVE_DATA_API_KEY,
        },
        timeout=30,
    )
    response.raise_for_status()
    payload = response.json()
    if payload.get("status") == "error":
        raise RuntimeError(f"{symbol}: {payload.get('message')}")
    return [
        (
            row["datetime"],
            symbol,
            float(row["open"]),
            float(row["high"]),
            float(row["low"]),
            float(row["close"]),
            float(row.get("volume") or 0),
        )
        for row in payload["values"]
    ]


fetch = fetch_twelve_data if TWELVE_DATA_API_KEY else fetch_coinbase


def main(symbols: list[str], once: bool) -> None:
    with psycopg.connect(DSN) as conn:
        with conn.cursor() as cur:
            cur.executemany(
                "INSERT INTO symbols (symbol, name) VALUES (%s, %s) "
                "ON CONFLICT (symbol) DO NOTHING",
                [(s, s) for s in symbols],
            )
        conn.commit()

        while True:
            for symbol in symbols:
                try:
                    rows = fetch(symbol)
                except (requests.RequestException, RuntimeError) as exc:
                    print(f"skip {symbol}: {exc}", file=sys.stderr)
                    continue
                with conn.cursor() as cur:
                    cur.executemany(UPSERT, rows)
                conn.commit()
                print(f"{symbol}: {len(rows)} candles")
            if once:
                return
            time.sleep(POLL_SECONDS)


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if a != "--once"]
    main(args or ["BTC-USD", "ETH-USD"], once="--once" in sys.argv)
