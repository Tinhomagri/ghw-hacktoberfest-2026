"""Small dashboard for the app_metrics_hourly continuous aggregate."""
from __future__ import annotations

import os
from pathlib import Path

import psycopg
from flask import Flask, jsonify, render_template

app = Flask(__name__, template_folder=str(Path(__file__).with_name("templates")))


def fetch_metrics(hours: int = 168) -> list[dict]:
    dsn = os.environ.get("TIMESCALE_SERVICE_URL")
    if not dsn:
        raise RuntimeError("TIMESCALE_SERVICE_URL is not configured")
    query = """
        SELECT bucket, service, avg_latency_ms, p95_latency_ms
        FROM app_metrics_hourly
        WHERE bucket >= now() - (%s * INTERVAL '1 hour')
        ORDER BY bucket ASC, service ASC
    """
    with psycopg.connect(dsn) as connection:
        with connection.cursor() as cursor:
            cursor.execute(query, (hours,))
            return [
                {
                    "bucket": row[0].isoformat(),
                    "service": row[1],
                    "avg": round(float(row[2]), 2),
                    "p95": round(float(row[3]), 2),
                }
                for row in cursor.fetchall()
            ]


@app.get("/api/metrics")
def metrics():
    return jsonify(fetch_metrics())


@app.get("/")
def dashboard():
    return render_template("dashboard.html")


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=int(os.environ.get("PORT", "5000")), debug=False)
