class Boat {
  final String id;
  final String name;
  final String status; // "En mer", "Au port", "En maintenance"
  final double latitude;
  final double longitude;
  final double speed; // en nœuds
  final String lastUpdate;
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

  // Données de démonstration
  static List<Boat> getDemoBoats() {
    return [
      Boat(
        id: '1',
        name: 'PrimaFish-001',
        status: 'En mer',
        latitude: 33.5731,
        longitude: -7.5898,
        speed: 12.5,
        lastUpdate: 'Il y a 5 min',
        imageUrl: 'images/pmm.png',
        cameraActive: true,
        crewMembers: 5,
      ),
      Boat(
        id: '2',
        name: 'PrimaFish-002',
        status: 'Au port',
        latitude: 33.5731,
        longitude: -7.5898,
        speed: 0.0,
        lastUpdate: 'Il y a 2 min',
        imageUrl: 'images/pmm.png',
        cameraActive: false,
        crewMembers: 3,
      ),
      Boat(
        id: '3',
        name: 'PrimaFish-003',
        status: 'En mer',
        latitude: 33.5831,
        longitude: -7.5998,
        speed: 15.2,
        lastUpdate: 'Il y a 8 min',
        imageUrl: 'images/pmm.png',
        cameraActive: true,
        crewMembers: 6,
      ),
      Boat(
        id: '4',
        name: 'PrimaFish-004',
        status: 'En maintenance',
        latitude: 33.5631,
        longitude: -7.5798,
        speed: 0.0,
        lastUpdate: 'Il y a 1 heure',
        imageUrl: 'images/pmm.png',
        cameraActive: false,
        crewMembers: 2,
      ),
      Boat(
        id: '5',
        name: 'PrimaFish-005',
        status: 'En mer',
        latitude: 33.5931,
        longitude: -7.6098,
        speed: 18.7,
        lastUpdate: 'Il y a 3 min',
        imageUrl: 'images/pmm.png',
        cameraActive: true,
        crewMembers: 4,
      ),
    ];
  }
}

