import 'package:primaa/api_service.dart';

class Boat {
  final String id;
  final String name;
  String status;
  double latitude;
  double longitude;
  double speed;
  String lastUpdate;
  final String imageUrl;
  final bool cameraActive;
  final int crewMembers;

  Boat({
    required this.id,
    required this.name,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.lastUpdate,
    required this.imageUrl,
    required this.cameraActive,
    required this.crewMembers,
  });

  get events => null;

  // ✅ NOUVEAU : toJson → pour sauvegarder dans SharedPreferences
  Map<String, dynamic> toJson() => {
    'id':           id,
    'name':         name,
    'status':       status,
    'latitude':     latitude,
    'longitude':    longitude,
    'speed':        speed,
    'lastUpdate':   lastUpdate,
    'imageUrl':     imageUrl,
    'cameraActive': cameraActive,
    'crewMembers':  crewMembers,
  };

  // ✅ NOUVEAU : fromJson → pour charger depuis SharedPreferences
  factory Boat.fromJson(Map<String, dynamic> json) => Boat(
    id:           json['id']           as String,
    name:         json['name']         as String,
    status:       json['status']       as String,
    latitude:     (json['latitude']    as num).toDouble(),
    longitude:    (json['longitude']   as num).toDouble(),
    speed:        (json['speed']       as num).toDouble(),
    lastUpdate:   json['lastUpdate']   as String,
    imageUrl:     json['imageUrl']     as String,
    cameraActive: json['cameraActive'] as bool,
    crewMembers:  json['crewMembers']  as int,
  );

  // ✅ Update HanchiaFish-001 b data réelle mel Flask
  static Future<void> updateRealBoat(List<Boat> boats) async {
    try {
      final data = await ApiService.getGps();
      if (data != null) {
        final boat = boats.firstWhere((b) => b.id == '1');
        boat.latitude = data['latitude'];
        boat.longitude = data['longitude'];
        boat.speed = (data['speed'] ?? 0.0).toDouble();
        boat.lastUpdate = 'Temps réel';
        // Geofencing status
        final inPort = data['in_port'] ?? false;
        boat.status = inPort ? 'Au port' : 'En mer';
      }
    } catch (e) {
      // keep demo data
    }
  }

  static List<Boat> getDemoBoats() {
    return [
      Boat(
        id: '1',
        name: 'HanchiaFish-001',
        status: 'En mer',
        latitude: 35.6619,
        longitude: 10.9581,
        speed: 0.0,
        lastUpdate: 'Chargement...',
        imageUrl: 'images/téléchargement.png',
        cameraActive: true,
        crewMembers: 5,
      ),
      Boat(
        id: '2',
        name: 'HanchiaFish-002',
        status: 'Au port',
        latitude: 35.6620,
        longitude: 10.9582,
        speed: 0.0,
        lastUpdate: 'Il y a 2 min',
        imageUrl: 'images/téléchargement.png',
        cameraActive: false,
        crewMembers: 3,
      ),
      Boat(
        id: '3',
        name: 'HanchiaFish-003',
        status: 'En mer',
        latitude: 35.6700,
        longitude: 10.9700,
        speed: 15.2,
        lastUpdate: 'Il y a 8 min',
        imageUrl: 'images/téléchargement.png',
        cameraActive: true,
        crewMembers: 6,
      ),
      Boat(
        id: '4',
        name: 'HanchiaFish-004',
        status: 'En maintenance',
        latitude: 35.6500,
        longitude: 10.9400,
        speed: 0.0,
        lastUpdate: 'Il y a 1 heure',
        imageUrl: 'images/téléchargement.png',
        cameraActive: false,
        crewMembers: 2,
      ),
      Boat(
        id: '5',
        name: 'HanchiaFish-005',
        status: 'En mer',
        latitude: 35.6800,
        longitude: 10.9800,
        speed: 18.7,
        lastUpdate: 'Il y a 3 min',
        imageUrl: 'images/téléchargement.png',
        cameraActive: true,
        crewMembers: 4,
      ),
    ];
  }

  static Future<void> updateAllBoats(boats) async {}
}