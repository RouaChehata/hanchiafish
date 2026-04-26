from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
import sqlite3
import math
import os
import base64
from datetime import datetime

app = Flask(__name__)
CORS(app)

# Zone portuaire Teboulba
PORT_TEBOULBA = {
    "lat": 35.661970525816834,
    "lon": 10.958101377208251,
    "radius_m": 500
}

boat_status = {"in_port": None}
latest_image = {"data": None, "timestamp": None}

def haversine(lat1, lon1, lat2, lon2):
    R = 6371000
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)
    a = math.sin(dphi/2)**2 + math.cos(phi1)*math.cos(phi2)*math.sin(dlambda/2)**2
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))

def check_geofencing(lat, lon):
    distance = haversine(lat, lon, PORT_TEBOULBA["lat"], PORT_TEBOULBA["lon"])
    return distance <= PORT_TEBOULBA["radius_m"]

def check_security_mode(in_port, conn):
    if not in_port:
        return
    current_hour = datetime.now().hour
    if current_hour >= 0:
        c = conn.cursor()
        c.execute("""SELECT * FROM alertes WHERE type='Mode Sécurité' 
                     AND date(timestamp)=date('now')""")
        existing = c.fetchone()
        if not existing:
            c.execute("INSERT INTO alertes (type, message) VALUES (?, ?)",
                      ("Mode Sécurité", "Mode sécurité activé — Bateau au port après 18h00"))

def init_db():
    conn = sqlite3.connect('hanchia.db')
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS gps_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL,
        longitude REAL,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )''')
    c.execute('''CREATE TABLE IF NOT EXISTS alertes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        message TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )''')
    conn.commit()
    conn.close()

# GPS routes
@app.route('/gps', methods=['POST'])
def save_gps():
    data = request.json
    lat = data['latitude']
    lon = data['longitude']

    conn = sqlite3.connect('hanchia.db')
    c = conn.cursor()
    c.execute("INSERT INTO gps_data (latitude, longitude) VALUES (?, ?)", (lat, lon))

    in_port = check_geofencing(lat, lon)

    if boat_status["in_port"] is None:
        boat_status["in_port"] = in_port
    elif in_port != boat_status["in_port"]:
        if in_port:
            type_alerte = "Entrée au port"
            message = "Bateau entré dans le port de Teboulba"
        else:
            type_alerte = "Sortie du port"
            message = "Bateau sorti du port de Teboulba"
        c.execute("INSERT INTO alertes (type, message) VALUES (?, ?)",
                  (type_alerte, message))
        boat_status["in_port"] = in_port

    check_security_mode(in_port, conn)
    conn.commit()
    conn.close()

    return jsonify({"message": "OK", "in_port": in_port}), 200

@app.route('/gps', methods=['GET'])
def get_gps():
    conn = sqlite3.connect('hanchia.db')
    c = conn.cursor()
    c.execute("SELECT * FROM gps_data ORDER BY timestamp DESC LIMIT 1")
    row = c.fetchone()
    conn.close()
    if row:
        return jsonify({"latitude": row[1], "longitude": row[2]}), 200
    return jsonify({"message": "Pas de data"}), 404

@app.route('/gps/history', methods=['GET'])
def get_gps_history():
    conn = sqlite3.connect('hanchia.db')
    c = conn.cursor()
    c.execute("SELECT * FROM gps_data ORDER BY timestamp DESC LIMIT 50")
    rows = c.fetchall()
    conn.close()
    history = [{"id": r[0], "latitude": r[1], "longitude": r[2], "timestamp": r[3]} for r in rows]
    return jsonify(history), 200

# Alertes routes
@app.route('/alerte', methods=['POST'])
def save_alerte():
    data = request.json
    conn = sqlite3.connect('hanchia.db')
    c = conn.cursor()
    c.execute("INSERT INTO alertes (type, message) VALUES (?, ?)",
              (data['type'], data['message']))
    conn.commit()
    conn.close()
    return jsonify({"message": "Alerte enregistrée"}), 200

@app.route('/alertes', methods=['GET'])
def get_alertes():
    conn = sqlite3.connect('hanchia.db')
    c = conn.cursor()
    c.execute("SELECT * FROM alertes ORDER BY timestamp DESC")
    rows = c.fetchall()
    conn.close()
    alertes = [{"id": r[0], "type": r[1], "message": r[2], "timestamp": r[3]} for r in rows]
    return jsonify(alertes), 200

# ✅ Camera routes JDIDA
@app.route('/camera', methods=['POST'])
def save_camera():
    data = request.json
    latest_image["data"] = data.get("image")
    latest_image["timestamp"] = datetime.now().strftime('%H:%M:%S')
    return jsonify({"message": "Image reçue"}), 200

@app.route('/camera', methods=['GET'])
def get_camera():
    if latest_image["data"]:
        return jsonify({
            "image": latest_image["data"],
            "timestamp": latest_image["timestamp"]
        }), 200
    return jsonify({"message": "Pas d'image"}), 404

if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', debug=True, port=5000)