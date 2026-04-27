import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/boat_model.dart';
import 'dart:async';
import 'package:primaa/api_service.dart';

// Design System - Colors
class AppColors {
  static const Color primary = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color accent = Color(0xFF77C0D8);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFE11D48);
  static const Color surface = Color(0xFFF5F7FA);
  static const Color background = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color shadow = Color(0x0A000000);
  
  // Status colors
  static const Color statusAtSea = Color(0xFF10B981);
  static const Color statusAtPort = Color(0xFFF59E0B);
  static const Color statusMaintenance = Color(0xFFE11D48);
  static const Color statusInactive = Color(0xFF94A3B8);
  
  // Map colors
  static const Color mapMarker = Color(0xFF1E3A8A);
  static const Color mapCircle = Color(0xFF3B82F6);
  static const Color mapSelected = Color(0xFF77C0D8);
}

// Design System - Typography
class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle small = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );
  
  static TextStyle appBarTitle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );
  
  static TextStyle cardTitle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static TextStyle cardSubtitle = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}

// Design System - Spacing
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;
  static const double massive = 48.0;
}

// Design System - Border Radius
class AppBorderRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double round = 100.0;
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final List<Boat> _boats = Boat.getDemoBoats();
  Boat? _selectedBoat;

  Timer? _timer;
  LatLng _currentPosition = LatLng(33.5731, -7.5898);
  double _currentSpeed = 0.0;

@override
void initState() {
  super.initState();
  _loadGps();
  // يجيب el position kol 5 thniya
  _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
    _loadGps();
  });
}

Future<void> _loadGps() async {
  final data = await ApiService.getGps();
  if (data != null) {
    setState(() {
      _currentPosition = LatLng(data['latitude'], data['longitude']);
      _currentSpeed = (data['speed'] ?? 0.0).toDouble();
    });
    _mapController.move(_currentPosition, 13);
  }
}

@override
void dispose() {
  _timer?.cancel();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E3A8A).withOpacity(0.85),
                const Color(0xFF3B82F6).withOpacity(0.6),
              ],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        title: Text(
          'Carte des Bateaux',
          style: AppTextStyles.appBarTitle,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: AppColors.textOnPrimary),
            onPressed: _loadGps,
          ),
          IconButton(
            icon: const Icon(Icons.location_city, color: AppColors.textOnPrimary),
            onPressed: () {
              _mapController.move(
                const LatLng(35.661970525816834, 10.958101377208251),
                14,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Carte
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:  _currentPosition, // Casablanca
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
              CircleLayer(
                circles: [
                  CircleMarker(
      point: const LatLng(35.661970525816834, 10.958101377208251),
      radius: 500,
      useRadiusInMeter: true,
      color: AppColors.mapCircle.withOpacity(0.2),
      borderColor: AppColors.mapCircle,
      borderStrokeWidth: 2,
    ),
  ],
),
  
              MarkerLayer(
  markers: [
    Marker(
      width: 60,
      height: 60,
      point: _currentPosition,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppColors.success,
              width: 3,
            ),
          ),
          child: const Icon(
            Icons.directions_boat_filled,
            color: Colors.green,
            size: 30,
          ),
        ),
      ),
    ),
  ],
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
          // Badge vitesse GPS en temps réel
          Positioned(
            bottom: _selectedBoat != null ? 200 : 20,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.speed_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${_currentSpeed.toStringAsFixed(1)} km/h',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
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
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
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
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: _selectedBoat?.id == boat.id
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedBoat?.id == boat.id
                      ? AppColors.primary
                      : AppColors.border,
                  width: _selectedBoat?.id == boat.id ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_boat,
                    color: _selectedBoat?.id == boat.id
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    boat.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _selectedBoat?.id == boat.id
                          ? AppColors.primary
                          : AppColors.textPrimary,
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
                      color: AppColors.textSecondary,
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
            color: AppColors.shadow,
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
                  color: AppColors.border,
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
                AppColors.primaryLight,
              ),
              const SizedBox(width: 16),
              _buildInfoItem(
                Icons.people,
                '${boat.crewMembers} membres',
                AppColors.primary,
              ),
              const SizedBox(width: 16),
              _buildInfoItem(
                boat.cameraActive ? Icons.videocam : Icons.videocam_off,
                boat.cameraActive ? 'Caméra ON' : 'Caméra OFF',
                boat.cameraActive ? AppColors.success : AppColors.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'Lat: ${boat.latitude.toStringAsFixed(5)}, '
                'Lng: ${boat.longitude.toStringAsFixed(5)}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
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