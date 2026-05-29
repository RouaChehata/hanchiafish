from flask import Flask, request, jsonify
from flask_cors import CORS
import sqlite3
import math
from datetime import datetime

app = Flask(__name__)
CORS(app)

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
        speed REAL DEFAULT 0,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )''')
    c.execute('''CREATE TABLE IF NOT EXISTS alertes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        message TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )''')
    c.execute('''CREATE TABLE IF NOT EXISTS captures (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )''')
    conn.commit()
    conn.close()

@app.route('/gps', methods=['POST'])
def save_gps():
    data = request.json
    lat = data['latitude']
    lon = data['longitude']
    speed = data.get('speed', 0)

    conn = sqlite3.connect('hanchia.db')
    c = conn.cursor()
    c.execute("INSERT INTO gps_data (latitude, longitude, speed) VALUES (?, ?, ?)",
              (lat, lon, speed))

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
        return jsonify({
            "latitude": row[1],
            "longitude": row[2],
            "speed": row[3] if row[3] else 0
        }), 200
    return jsonify({"message": "Pas de data"}), 404

@app.route('/gps/history', methods=['GET'])
def get_gps_history():
    conn = sqlite3.connect('hanchia.db')
    c = conn.cursor()
    c.execute("SELECT * FROM gps_data ORDER BY timestamp DESC LIMIT 50")
    rows = c.fetchall()
    conn.close()
    history = [{"id": r[0], "latitude": r[1], "longitude": r[2],
                "speed": r[3] if r[3] else 0, "timestamp": r[4]} for r in rows]
    return jsonify(history), 200

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

@app.route('/capture', methods=['POST'])
def save_capture():
    data = request.json
    conn = sqlite3.connect('hanchia.db')
    c = conn.cursor()
    c.execute("INSERT INTO captures (image) VALUES (?)", (data['image'],))
    conn.commit()
    conn.close()
    return jsonify({"message": "Capture enregistrée"}), 200

@app.route('/captures', methods=['GET'])
def get_captures():
    conn = sqlite3.connect('hanchia.db')
    c = conn.cursor()
    c.execute("SELECT id, timestamp FROM captures ORDER BY timestamp DESC LIMIT 20")
    rows = c.fetchall()
    conn.close()
    captures = [{"id": r[0], "timestamp": r[1]} for r in rows]
    return jsonify(captures), 200

@app.route('/capture/<int:capture_id>', methods=['GET'])
def get_capture_image(capture_id):
    conn = sqlite3.connect('hanchia.db')
    c = conn.cursor()
    c.execute("SELECT image, timestamp FROM captures WHERE id=?", (capture_id,))
    row = c.fetchone()
    conn.close()
    if row:
        return jsonify({"image": row[0], "timestamp": row[1]}), 200
    return jsonify({"message": "Capture non trouvée"}), 404

@app.route('/captures/<int:id>', methods=['DELETE'])
def delete_capture(id):
    # supprimer de ta base de données
    conn = sqlite3.connect('hanchia.db')
    c = conn.cursor()
    c.execute("DELETE FROM captures WHERE id=?", (id,))
    conn.commit()
    conn.close()
    return '', 204

@app.route('/boats/status', methods=['GET'])
def get_boats_status():
    conn = sqlite3.connect('hanchia.db')
    c = conn.cursor()
    c.execute("SELECT * FROM gps_data ORDER BY timestamp DESC LIMIT 1")
    row = c.fetchone()
    conn.close()
    
    if row:
        in_port = check_geofencing(row[1], row[2])
        return jsonify({
            "boat_001": {
                "status": "Au port" if in_port else "En mer",
                "latitude": row[1],
                "longitude": row[2],
                "speed": row[3] if row[3] else 0
            }
        }), 200
    return jsonify({}), 404

if __name__ == '__main__':
    init_db()
import os
port = int(os.environ.get('PORT', 5000))
app.run(host='0.0.0.0', debug=False, port=port)
