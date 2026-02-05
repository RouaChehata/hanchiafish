import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/boat.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final List<Boat> _boats = Boat.getDemoBoats();
  Boat? _selectedBoat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Carte des Bateaux',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Carte
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(33.5731, -7.5898), // Casablanca
              initialZoom: 10,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedBoat = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.primaa',
              ),
              MarkerLayer(
                markers: _boats.map((boat) {
                  return Marker(
                    width: 60,
                    height: 60,
                    point: LatLng(boat.latitude, boat.longitude),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedBoat = boat;
                        });
                      },
                      child: _buildBoatMarker(boat),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          // Panneau d'information du bateau sélectionné
          if (_selectedBoat != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: _buildBoatInfoCard(_selectedBoat!),
            ),
          // Liste des bateaux en haut
          Positioned(
            top: 10,
            left: 16,
            right: 16,
            child: _buildBoatsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBoatMarker(Boat boat) {
    Color statusColor;
    switch (boat.status) {
      case 'En mer':
        statusColor = Colors.green;
        break;
      case 'Au port':
        statusColor = Colors.orange;
        break;
      case 'En maintenance':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: statusColor,
          width: 3,
        ),
      ),
      child: Icon(
        Icons.directions_boat_filled,
        color: statusColor,
        size: 30,
      ),
    );
  }

  Widget _buildBoatsList() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _boats.length,
        itemBuilder: (context, index) {
          final boat = _boats[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedBoat = boat;
              });
              _mapController.move(
                LatLng(boat.latitude, boat.longitude),
                13,
              );
            },
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedBoat?.id == boat.id
                    ? const Color(0xFF1E3A8A).withOpacity(0.1)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedBoat?.id == boat.id
                      ? const Color(0xFF1E3A8A)
                      : Colors.grey[300]!,
                  width: _selectedBoat?.id == boat.id ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_boat,
                    color: _selectedBoat?.id == boat.id
                        ? const Color(0xFF1E3A8A)
                        : Colors.grey[600],
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    boat.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _selectedBoat?.id == boat.id
                          ? const Color(0xFF1E3A8A)
                          : Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${boat.speed.toStringAsFixed(1)} nœuds',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBoatInfoCard(Boat boat) {
    Color statusColor;
    switch (boat.status) {
      case 'En mer':
        statusColor = Colors.green;
        break;
      case 'Au port':
        statusColor = Colors.orange;
        break;
      case 'En maintenance':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    boat.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.directions_boat_filled,
                        color: Color(0xFF1E3A8A),
                        size: 30,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      boat.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            boat.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectedBoat = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoItem(
                Icons.speed,
                '${boat.speed.toStringAsFixed(1)} nœuds',
                Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildInfoItem(
                Icons.people,
                '${boat.crewMembers} membres',
                Colors.indigo,
              ),
              const SizedBox(width: 16),
              _buildInfoItem(
                boat.cameraActive ? Icons.videocam : Icons.videocam_off,
                boat.cameraActive ? 'Caméra ON' : 'Caméra OFF',
                boat.cameraActive ? Colors.green : Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Lat: ${boat.latitude.toStringAsFixed(5)}, '
                'Lng: ${boat.longitude.toStringAsFixed(5)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

