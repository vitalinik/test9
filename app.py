import os
import socket
import requests
from flask import Flask, send_from_directory

app = Flask(__name__)

IMDS_BASE = "http://169.254.169.254"
IMDS_TOKEN_URL = f"{IMDS_BASE}/latest/api/token"
IMDS_DOC_URL = f"{IMDS_BASE}/latest/dynamic/instance-identity/document"


def _get_imds_token():
    try:
        r = requests.put(
            IMDS_TOKEN_URL,
            headers={"X-aws-ec2-metadata-token-ttl-seconds": "60"},
            timeout=0.2,
        )
        if r.status_code == 200:
            return r.text
    except requests.RequestException:
        pass
    return None


def get_instance_identity():
    token = _get_imds_token()
    headers = {"X-aws-ec2-metadata-token": token} if token else {}
    try:
        r = requests.get(IMDS_DOC_URL, headers=headers, timeout=0.2)
        if r.status_code == 200:
            data = r.json()
            return {
                "instance_id": data.get("instanceId", "unknown"),
                "region": data.get("region", "unknown"),
                "az": data.get("availabilityZone", "unknown"),
            }
    except requests.RequestException:
        pass
    return {"instance_id": "unknown", "region": "unknown", "az": "unknown"}


def get_north_pole_weather():
    url = (
        "https://api.open-meteo.com/v1/forecast"
        "?latitude=90.0&longitude=0.0&current_weather=true&timezone=UTC"
    )
    try:
        r = requests.get(url, timeout=1.5)
        if r.status_code == 200:
            data = r.json()
            current = data.get("current_weather", {})
            temp = current.get("temperature")
            wind = current.get("windspeed")
            return {
                "temperature": temp,
                "windspeed": wind,
                "units": "°C / km/h",
            }
    except requests.RequestException:
        pass
    return {"temperature": None, "windspeed": None, "units": None}


@app.route("/health")
def health():
    return "ok", 200


@app.route("/images/<path:filename>")
def images(filename):
    return send_from_directory("images", filename)


@app.route("/")
def index():
    release = os.getenv("RELEASE_NAME", "unknown")
    hostname = socket.gethostname()
    meta = get_instance_identity()
    weather = get_north_pole_weather()

    weather_text = "unavailable"
    if weather["temperature"] is not None:
        weather_text = (
            f"{weather['temperature']}°C, wind {weather['windspeed']} km/h"
        )

        html = f"""
        <html>
            <head>
                <title>CMTR Canary Demo</title>
                <style>
                    body {{ font-family: Arial, sans-serif; margin: 40px; }}
                    .card {{ border: 1px solid #ddd; padding: 20px; max-width: 600px; }}
                    h1 {{ margin-top: 0; }}
                    .hero {{ display: flex; align-items: center; gap: 16px; }}
                    .hero img {{ width: 80px; height: 80px; }}
                </style>
            </head>
            <body>
                <div class="card">
                    <div class="hero">
                        <img alt="North Pole" src="/images/north-pole.svg" />
                        <h1>Deployment Status</h1>
                    </div>
                    <p><b>Release:</b> {release}</p>
                    <p><b>Instance ID:</b> {meta['instance_id']}</p>
                    <p><b>Region:</b> {meta['region']}</p>
                    <p><b>Availability Zone:</b> {meta['az']}</p>
                    <p><b>Hostname:</b> {hostname}</p>
                    <p><b>North Pole Weather:</b> {weather_text}</p>
                </div>
            </body>
        </html>
        """
    return html


if __name__ == "__main__":
    port = int(os.getenv("PORT", "8080"))
    app.run(host="0.0.0.0", port=port)
