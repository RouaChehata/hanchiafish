import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/boat_model.dart';
import 'dart:async';
import 'package:primaa/api_service.dart';
import 'app theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Boat> _boats = Boat.getDemoBoats();
  Boat? _selectedBoat;
  Timer? _timer;
  double _currentSpeed = 0.0;

  // Position réelle HanchiaFish-001
  LatLng _realPosition = const LatLng(35.6619, 10.9581);

  @override
  void initState() {
    super.initState();
    _loadGps();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _loadGps());
  }

    Future<void> _loadBoats() async {
    // ✅ Plus de référence à _boats inexistant dans ce State
    await Boat.updateAllBoats(_boats);
    if (mounted) setState(() {});
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      await Boat.updateAllBoats(_boats);
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadGps() async {
    final data = await ApiService.getGps();
    if (data != null) {
      setState(() {
        _realPosition = LatLng(data['latitude'], data['longitude']);
        _currentSpeed = (data['speed'] ?? 0.0).toDouble();
        // Update HanchiaFish-001 b position réelle
        final boat001 = _boats.firstWhere((b) => b.id == '1');
        boat001.latitude = data['latitude'];
        boat001.longitude = data['longitude'];
        boat001.speed = _currentSpeed;
        boat001.status = (data['in_port'] ?? false) ? 'Au port' : 'En mer';
        boat001.lastUpdate = 'Temps réel';
      });
      _mapController.move(_realPosition, 13);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'En mer': return AppColors.success;
      case 'Au port': return Colors.orange;
      case 'En maintenance': return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MaritimeAppBar(
        title: 'Carte des Bateaux',
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: AppColors.white),
            onPressed: _loadGps,
          ),
          IconButton(
            icon: const Icon(Icons.location_city, color: AppColors.white),
            onPressed: () => _mapController.move(
              const LatLng(35.661970525816834, 10.958101377208251), 14),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _realPosition,
              initialZoom: 10,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
              onTap: (_, __) => setState(() => _selectedBoat = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.primaa',
              ),
              // Zone geofencing port Teboulba
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: const LatLng(35.661970525816834, 10.958101377208251),
                    radius: 500,
                    useRadiusInMeter: true,
                    color: AppColors.primaryLight.withOpacity(0.15),
                    borderColor: AppColors.primaryLight,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
              // Markers kol bateaux
              MarkerLayer(
                markers: _boats.map((boat) {
                  final isReal = boat.id == '1';
                  final color = _statusColor(boat.status);
                      final point = isReal 
                            ? _realPosition 
                            : LatLng(boat.latitude, boat.longitude);
                  return Marker(
                    width: 64,
                    height: 64,
                    point: point,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedBoat = boat);
                        _mapController.move(point, 13);
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: AppShadows.elevated,
                              border: Border.all(color: color, width: 3),
                            ),
                            child: Icon(
                              Icons.directions_boat_filled,
                              color: color,
                              size: 28,
                            ),
                          ),
                          // Badge GPS réel lel HanchiaFish-001
                          if (isReal)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Liste bateaux haut
          Positioned(
            top: 10,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: _buildBoatsList(),
          ),

          // Badge vitesse GPS
          Positioned(
            bottom: _selectedBoat != null ? 200 : AppSpacing.xl,
            left: AppSpacing.lg,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: AppGradients.primaryBar,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.elevated,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.speed_rounded, color: AppColors.white, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${_currentSpeed.toStringAsFixed(1)} km/h',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Info card bateau sélectionné
          if (_selectedBoat != null)
            Positioned(
              bottom: AppSpacing.xl,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              child: _buildBoatInfoCard(_selectedBoat!),
            ),
        ],
      ),
    );
  }

  Widget _buildBoatsList() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.elevated,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        itemCount: _boats.length,
        itemBuilder: (_, i) {
          final boat = _boats[i];
          final isSelected = _selectedBoat?.id == boat.id;
          final isReal = boat.id == '1';
          final color = _statusColor(boat.status);
          return GestureDetector(
            onTap: () {
              setState(() => _selectedBoat = boat);
              _mapController.move(LatLng(boat.latitude, boat.longitude), 13);
            },
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Icon(
                        Icons.directions_boat,
                        color: isSelected ? AppColors.primary : color,
                        size: 22,
                      ),
                      if (isReal)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    boat.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Status colored
                  Text(
                    boat.status,
                    style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
    final statusColor = _statusColor(boat.status);
    final isReal = boat.id == '1';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.elevated,
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
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  color: AppColors.lightGrey,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Image.asset(
                    boat.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.directions_boat_filled,
                        color: AppColors.primary,
                        size: 28),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(boat.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: AppColors.primary)),
                        if (isReal) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('GPS',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 4),
                    MaritimeBadge(
                        label: boat.status,
                        color: statusColor,
                        icon: Icons.circle,
                        filled: false),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => setState(() => _selectedBoat = null),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _buildInfoChip(
                  Icons.speed,
                  isReal
                      ? '${_currentSpeed.toStringAsFixed(1)} km/h'
                      : '${boat.speed.toStringAsFixed(1)} nœuds',
                  AppColors.primaryLight),
              const SizedBox(width: AppSpacing.lg),
              _buildInfoChip(Icons.people,
                  '${boat.crewMembers} membres', AppColors.primary),
              const SizedBox(width: AppSpacing.lg),
              _buildInfoChip(
                  boat.cameraActive ? Icons.videocam : Icons.videocam_off,
                  boat.cameraActive ? 'Caméra ON' : 'OFF',
                  boat.cameraActive
                      ? AppColors.success
                      : AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.location_on,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                isReal
                    ? 'Lat: ${_realPosition.latitude.toStringAsFixed(5)}, Lng: ${_realPosition.longitude.toStringAsFixed(5)}'
                    : 'Lat: ${boat.latitude.toStringAsFixed(5)}, Lng: ${boat.longitude.toStringAsFixed(5)}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}