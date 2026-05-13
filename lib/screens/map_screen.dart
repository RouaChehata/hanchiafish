import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/boat_model.dart';
import 'dart:async';
import 'package:primaa/api_service.dart';
import 'app_theme.dart';

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
      case 'En mer':
        return AppColors.success;
      case 'Au port':
        return Colors.orange;
      case 'En maintenance':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaritimeScaffold(
      appBar: MaritimeAppBar(
        title: 'Cartographie Flotte',
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded, color: AppColors.white),
            onPressed: _loadGps,
          ),
          IconButton(
            icon: const Icon(Icons.hub_rounded, color: AppColors.white),
            onPressed: () => _mapController.move(
              const LatLng(35.661970525816834, 10.958101377208251),
              14,
            ),
          ),
        ],
      ),
      headerContent: _buildMapStatsHeader(),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.xxl),
              topRight: Radius.circular(AppRadius.xxl),
            ),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _realPosition,
                initialZoom: 10,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onTap: (_, __) => setState(() => _selectedBoat = null),
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
                      radius: 800,
                      useRadiusInMeter: true,
                      color: AppColors.primaryLight.withOpacity(0.12),
                      borderColor: AppColors.primaryLight.withOpacity(0.5),
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: _boats.map((boat) {
                    final isReal = boat.id == '1';
                    final color = _statusColor(boat.status);
                    final point = isReal
                        ? _realPosition
                        : LatLng(boat.latitude, boat.longitude);
                    return Marker(
                      width: 70,
                      height: 70,
                      point: point,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedBoat = boat);
                          _mapController.move(point, 13);
                        },
                        child: _buildBoatMarker(boat, color, isReal),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Liste bateaux flottante
          Positioned(
            top: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: _buildFloatingBoatsList(),
          ),

          // Vitesse GPS flottante
          Positioned(
            bottom: _selectedBoat != null ? 220 : AppSpacing.xl,
            right: AppSpacing.lg,
            child: _buildSpeedBadge(),
          ),

          // Card info sélection
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

  Widget _buildMapStatsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatHeaderTile(
          label: 'Unités',
          value: '${_boats.length}',
          icon: Icons.directions_boat_rounded,
        ),
        _StatHeaderTile(
          label: 'En Mer',
          value: '${_boats.where((b) => b.status == 'En mer').length}',
          icon: Icons.waves_rounded,
        ),
        _StatHeaderTile(
          label: 'Vitesse Moy.',
          value: '12.4 kn',
          icon: Icons.speed_rounded,
        ),
      ],
    );
  }

  Widget _buildBoatMarker(Boat boat, Color color, bool isReal) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: AppShadows.premium,
            border: Border.all(color: color, width: 3),
          ),
          child: Icon(
            Icons.sailing_rounded,
            color: color,
            size: 24,
          ),
        ),
        if (isReal)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
                boxShadow: AppShadows.subtle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFloatingBoatsList() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.elevated,
        border: Border.all(color: AppColors.white.withOpacity(0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          itemCount: _boats.length,
          itemBuilder: (_, i) {
            final boat = _boats[i];
            final isSelected = _selectedBoat?.id == boat.id;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedBoat = boat);
                _mapController.move(LatLng(boat.latitude, boat.longitude), 13);
              },
              child: AnimatedContainer(
                duration: AppDurations.normal,
                width: 110,
                margin: EdgeInsets.only(right: AppSpacing.sm),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderLight,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_boat_rounded,
                      color: isSelected ? AppColors.white : AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      boat.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? AppColors.white : AppColors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSpeedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryBar,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.premium,
        border: Border.all(color: AppColors.white.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.speed_rounded, color: AppColors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            '${_currentSpeed.toStringAsFixed(1)}',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            'KM/H',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoatInfoCard(Boat boat) {
    final statusColor = _statusColor(boat.status);
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppShadows.premium,
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Image.asset(
                    boat.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.directions_boat_filled,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          boat.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: AppColors.primary),
                        ),
                        if (isReal) ...[
                          SizedBox(width: 6),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'GPS',
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4),
                    MaritimeBadge(
                      label: boat.status,
                      color: statusColor,
                      icon: Icons.circle,
                      filled: false,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => setState(() => _selectedBoat = null),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _buildInfoChip(
                Icons.speed,
                isReal
                    ? '${_currentSpeed.toStringAsFixed(1)} km/h'
                    : '${boat.speed.toStringAsFixed(1)} nœuds',
                AppColors.primaryLight,
              ),
              SizedBox(width: AppSpacing.lg),
              _buildInfoChip(
                Icons.people,
                '${boat.crewMembers} membres',
                AppColors.primary,
              ),
              SizedBox(width: AppSpacing.lg),
              _buildInfoChip(
                boat.cameraActive ? Icons.videocam : Icons.videocam_off,
                boat.cameraActive ? 'Caméra ON' : 'OFF',
                boat.cameraActive ? AppColors.success : AppColors.textSecondary,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 14,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 4),
              Text(
                isReal
                    ? 'Lat: ${_realPosition.latitude.toStringAsFixed(5)}, Lng: ${_realPosition.longitude.toStringAsFixed(5)}'
                    : 'Lat: ${boat.latitude.toStringAsFixed(5)}, Lng: ${boat.longitude.toStringAsFixed(5)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
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
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
