import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:primaa/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:primaa/models/boat_model.dart';
import 'package:primaa/screens/app_theme.dart'; // ← Design System partagé
import '../services/pdf_service.dart';
import '../widgets/animated_speed_gauge.dart';
import '../widgets/wave_background_card.dart';
import '../widgets/live_indicator.dart';
import '../widgets/flip_stat_card.dart';

class BoatDetailScreen extends StatefulWidget {
  final Boat boat;
  const BoatDetailScreen({super.key, required this.boat});

  @override
  State<BoatDetailScreen> createState() => _BoatDetailScreenState();
}

class _BoatDetailScreenState extends State<BoatDetailScreen>
    with TickerProviderStateMixin {
  late LatLng _currentPosition;
  late double _currentSpeed;
  late String _lastUpdate;
  bool _followOnMap = true;
  String? _rapport;
  bool _rapportLoading = false;
  bool _showRapport = false;
  bool _isLoadingGps = false;
  final TextEditingController _responsableCtrl = TextEditingController();

  final MapController _mapController = MapController();
  Timer? _gpsTimer;
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late AnimationController _sonarController;

  @override
  void initState() {
    super.initState();
    _currentPosition = LatLng(widget.boat.latitude, widget.boat.longitude);
    _currentSpeed = widget.boat.speed;
    _lastUpdate = widget.boat.lastUpdate;

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _sonarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _loadGps();
    _gpsTimer = Timer.periodic(const Duration(seconds: 60), (_) => _loadGps());
  }

  Future<void> _loadGps() async {
    if (widget.boat.id != '1') {
      setState(() => _isLoadingGps = false);
      return;
    }
    setState(() => _isLoadingGps = true);
    try {
      final response = await http
          .get(Uri.parse('${ApiService.baseUrl}/gps'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _currentPosition = LatLng(data['latitude'], data['longitude']);
          _currentSpeed = (data['speed'] ?? 0.0).toDouble();
          _lastUpdate = 'Il y a quelques secondes';
          if (_followOnMap) {
            _mapController.move(_currentPosition, _mapController.camera.zoom);
          }
        });
      }
    } catch (_) {
      // serveur injoignable — on garde la position actuelle
    } finally {
      setState(() => _isLoadingGps = false);
    }
  }

  @override
  void dispose() {
    _gpsTimer?.cancel();
    _waveController.dispose();
    _pulseController.dispose();
    _sonarController.dispose();
    _responsableCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boat = widget.boat;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar ──────────────────────
          SliverAppBar(
            expandedHeight: 450,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.background,
            leading: _appBarButton(
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.primary,
                size: 18,
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
            actions: [
              _appBarButton(
                onTap: _loadGps,
                child: _isLoadingGps
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryLight,
                        ),
                      )
                    : const Icon(
                        Icons.refresh,
                        color: AppColors.primary,
                        size: 18,
                      ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'images/cage.png',
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: const BoxDecoration(
                          gradient: AppGradients.cardHeader,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.04),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Center(child: _buildDashboardHeader(boat)),
                  ),
                ],
              ),
            ),
          ),
          // ── Body ─────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.xxl),
                  topRight: Radius.circular(AppRadius.xxl),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSpacing.xxl),
                  // Infos générales
                  _sectionPadding(
                    _buildSectionHeader('Informations générales'),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  _sectionPadding(_buildStatsGrid(boat)),
                  SizedBox(height: AppSpacing.xxl),
                  // GPS
                  _sectionPadding(
                    _buildSectionHeader('Position GPS & Temps réel'),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  _sectionPadding(_buildGpsInfo()),
                  SizedBox(height: AppSpacing.xl),
                  // Jauge vitesse
                  _sectionPadding(_buildSpeedGaugeSection()),
                  SizedBox(height: AppSpacing.xl),
                  // Carte
                  _sectionPadding(_buildMapCard()),
                  SizedBox(height: AppSpacing.xl),
                  // Rapport IA
                  _sectionPadding(_buildGroqRapportSection(boat)),
                  SizedBox(height: AppSpacing.huge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionPadding(Widget child) =>
      Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: child);

  // ── AppBar bouton (retour / refresh) ─────────
  Widget _appBarButton({required Widget child, required VoidCallback onTap}) {
    return Container(
      margin: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.subtle,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: child,
        padding: EdgeInsets.all(AppSpacing.sm),
      ),
    );
  }

  // ── Dashboard header (carte d'identité bateau)
  Widget _buildDashboardHeader(Boat boat) {
    final statusColor = MaritimeStatusColor.fromStatus(boat.status);
    final statusIcon = _statusIconData(boat.status);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          boxShadow: AppShadows.premium,
          border: Border.all(
            color: AppColors.white.withOpacity(0.6),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar with animated pulse background
            Stack(
              alignment: Alignment.center,
              children: [
                _buildPulseCircle(90, AppColors.primaryLight.withOpacity(0.1)),
                _buildPulseCircle(110, AppColors.primaryLight.withOpacity(0.05)),
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.premium,
                    border: Border.all(
                      color: AppColors.white,
                      width: 4,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      boat.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: const BoxDecoration(
                          gradient: AppGradients.cardHeader,
                        ),
                        child: const Icon(
                          Icons.directions_boat_rounded,
                          color: AppColors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              boat.name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                'NAV-ID : ${boat.id}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryLight,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statusBadgeDetail(boat.status, statusColor, statusIcon),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.success.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LiveIndicator(
                        text: '',
                        size: 8,
                        showText: false,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _lastUpdate.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseCircle(double size, Color color) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: size * (1 + _pulseController.value * 0.1),
          height: size * (1 + _pulseController.value * 0.1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        );
      },
    );
  }

  Widget _statusBadgeDetail(String status, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header ────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 24,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primaryLight, AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats grid ───────────────────────────────
  Widget _buildStatsGrid(Boat boat) {
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FlipStatCard(
            icon: Icons.speed_rounded,
            value: '${_currentSpeed.toStringAsFixed(0)}',
            label: 'nœuds',
            detailTitle: 'Vitesse actuelle',
            detailContent:
                'Le bateau navigue à ${_currentSpeed.toStringAsFixed(1)} nœuds.',
            iconColor: AppColors.primaryLight,
          ),
          SizedBox(width: AppSpacing.md),
          FlipStatCard(
            icon: Icons.group_rounded,
            value: '${boat.crewMembers}',
            label: 'marins',
            detailTitle: 'Équipage',
            detailContent: '${boat.crewMembers} membres d\'équipage à bord.',
            iconColor: AppColors.primary,
          ),
          SizedBox(width: AppSpacing.md),
          FlipStatCard(
            icon: boat.cameraActive
                ? Icons.videocam_rounded
                : Icons.videocam_off_rounded,
            value: boat.cameraActive ? 'ON' : 'OFF',
            label: 'caméra',
            detailTitle: 'Système de surveillance',
            detailContent: boat.cameraActive
                ? 'Caméras actives et enregistrant.'
                : 'Caméras désactivées.',
            iconColor: boat.cameraActive
                ? AppColors.success
                : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  // ── GPS Info ─────────────────────────────────
  Widget _buildGpsInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppShadows.premium,
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppGradients.cardHeader,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.subtle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rapport Géolocalisation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Satellite connecté',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Large Speed Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: AppShadows.premium,
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VITESSE INSTANTANÉE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_currentSpeed.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6, left: 4),
                          child: Text(
                            'km/h',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.speed_rounded, color: AppColors.white, size: 28),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Coordinates Row
          Row(
            children: [
              Expanded(
                child: _premiumCoordCard(
                  'LATITUDE',
                  _currentPosition.latitude.toStringAsFixed(6),
                  Icons.north_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _premiumCoordCard(
                  'LONGITUDE',
                  _currentPosition.longitude.toStringAsFixed(6),
                  Icons.east_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _coordCol(String label, IconData icon, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: color, size: 15),
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  // ── Speed gauge section ───────────────────────
  Widget _buildSpeedGaugeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Vitesse en temps réel'),
        SizedBox(height: AppSpacing.lg),
        WaveBackgroundCard(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Center(
            child: AnimatedSpeedGauge(
              speed: _currentSpeed,
              maxSpeed: 50.0,
              unit: 'nœuds',
              size: 240.0,
            ),
          ),
        ),
      ],
    );
  }

  // ── Map card ──────────────────────────────────
  Widget _buildMapCard() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.primaryLight.withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg + 4),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition,
                initialZoom: 13,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.primaa',
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: const LatLng(
                        35.661970525816834,
                        10.958101377208251,
                      ),
                      radius: 500,
                      useRadiusInMeter: true,
                      color: AppColors.primaryLight.withOpacity(0.15),
                      borderColor: AppColors.primaryLight,
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
                      child: _buildBoatMarker(),
                    ),
                  ],
                ),
              ],
            ),
            // Contrôles carte
            Positioned(
              top: 20,
              right: 20,
              child: Column(
                children: [
                  _mapControl(
                    icon: Icons.my_location_rounded,
                    onTap: () => _mapController.move(
                      _currentPosition,
                      _mapController.camera.zoom,
                    ),
                    tooltip: 'Centrer sur la position',
                  ),
                  SizedBox(height: AppSpacing.md),
                  _mapControl(
                    icon: _followOnMap
                        ? Icons.gps_fixed_rounded
                        : Icons.location_searching_rounded,
                    isActive: _followOnMap,
                    onTap: () => setState(() => _followOnMap = !_followOnMap),
                    tooltip: _followOnMap ? 'Suivi activé' : 'Activer le suivi',
                  ),
                  SizedBox(height: AppSpacing.md),
                  _mapControl(
                    icon: Icons.layers_rounded,
                    onTap: () {},
                    tooltip: 'Changer de carte',
                  ),
                ],
              ),
            ),
            // Bouton suivre
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: _buildFollowButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoatMarker() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _sonarController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            _sonarCircle(0.0, 1.0),
            _sonarCircle(0.3, 0.8),
            _sonarCircle(0.6, 0.6),
            Container(
              width: 55 + _pulseController.value * 10,
              height: 55 + _pulseController.value * 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withOpacity(
                  0.2 - _pulseController.value * 0.15,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryLight.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: EdgeInsets.all(AppSpacing.sm),
              child: const Icon(
                Icons.directions_boat_filled,
                color: AppColors.white,
                size: 28,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _sonarCircle(double delay, double maxOpacity) {
    final v = (_sonarController.value + delay) % 1.0;
    final size = 30.0 + v * 50.0;
    final op = maxOpacity * (1.0 - v);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(op),
          width: 2.0,
        ),
      ),
    );
  }

  Widget _mapControl({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.card,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.border,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            size: 22,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildFollowButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.xxl,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
        ),
        onPressed: () {
          setState(() => _followOnMap = true);
          _mapController.move(_currentPosition, _mapController.camera.zoom);
        },
        icon: const Icon(Icons.map_rounded, size: 20),
        label: const Text(
          'Suivre le bateau sur la carte',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }

  // ── Rapport IA ───────────────────────────────
  Widget _buildGroqRapportSection(Boat boat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bouton générer
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            onPressed: _rapportLoading ? null : () => _generateRapport(boat),
            icon: _rapportLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('⚡', style: TextStyle(fontSize: 18)),
            label: Text(
              _rapportLoading
                  ? 'Groq génère le rapport...'
                  : 'Générer Rapport IA',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        // Rapport affiché
        if (_showRapport && _rapport != null) ...[
          SizedBox(height: AppSpacing.lg),
          Container(
            padding: EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.primaryLight.withOpacity(0.3),
              ),
              boxShadow: AppShadows.subtle,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: AppColors.white,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Rapport Généré',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => setState(() => _showRapport = false),
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Divider(color: AppColors.primaryLight.withOpacity(0.4)),
                SizedBox(height: AppSpacing.sm),
                Text(
                  _rapport!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.7,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
                Text(
                  'Nom du responsable',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _responsableCtrl,
                  decoration: InputDecoration(
                    hintText: 'Ex: Roua Chehata',
                    hintStyle: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColors.primaryLight,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: AppColors.primaryLight.withOpacity(0.4),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(
                        color: AppColors.primaryLight,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => _downloadPdf(boat),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text(
                      'Télécharger PDF',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Rapport IA — génération ────────────────
  Future<void> _generateRapport(Boat boat) async {
    setState(() {
      _rapportLoading = true;
      _rapport = null;
      _showRapport = true;
    });

    const apiKey = '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';
    final prompt =
        '''
Tu es un officier maritime. Génère un rapport d\'état professionnel en français.

DONNÉES DU BATEAU:
- Nom: ${boat.name}
- Statut: ${boat.status}
- Position GPS: Lat ${_currentPosition.latitude.toStringAsFixed(4)}, Lon ${_currentPosition.longitude.toStringAsFixed(4)}
- Vitesse: ${_currentSpeed.toStringAsFixed(1)} noeuds
- Dernière mise à jour: $_lastUpdate

Le rapport doit inclure:
1. RÉSUMÉ DE L\'ÉTAT
2. POSITION & NAVIGATION
3. ÉTAT TECHNIQUE
4. RECOMMANDATIONS
''';

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 800,
          'temperature': 0.7,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _rapport = data['choices'][0]['message']['content']);
      } else {
        final error = jsonDecode(response.body);
        setState(() => _rapport = 'Erreur: ${error['error']['message']}');
      }
    } catch (e) {
      setState(() => _rapport = 'Erreur connexion: $e');
    } finally {
      setState(() => _rapportLoading = false);
    }
  }

  // ── PDF ───────────────────────────────────
  Future<void> _downloadPdf(Boat boat) async {
    if (_rapport == null) return;
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final responsable = _responsableCtrl.text.trim().isEmpty
        ? 'Non renseigné'
        : _responsableCtrl.text.trim();

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (_) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.blue800, width: 2),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "RAPPORT D'ETAT MARITIME",
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.Text(
                    boat.name,
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.blue700,
                    ),
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue700,
                  borderRadius: pw.BorderRadius.circular(20),
                ),
                child: pw.Text(
                  boat.status,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Row(
          // On change "_" en "context"
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Généré le $dateStr — CONFIDENTIEL',
              style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 8),
            ),
            pw.Text(
              // On utilise "context" ici au lieu de "_"
              'Page ${context.pageNumber} / ${context.pagesCount}',
              style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 8),
            ),
          ],
        ),
        build: (_) => [
          pw.SizedBox(height: 20),
          pw.Text(
            "RAPPORT D'ETAT DÉTAILLÉ",
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.Divider(color: PdfColors.blue200),
          pw.SizedBox(height: 8),
          pw.Text(
            _rapport!,
            style: const pw.TextStyle(fontSize: 10.5, lineSpacing: 4),
          ),
          pw.SizedBox(height: 30),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue200),
              borderRadius: pw.BorderRadius.circular(8),
              color: PdfColors.blue50,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'DÉCLARATION DE RESPONSABILITÉ',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Je, $responsable, déclare que les informations contenues dans ce rapport sont exactes. '
                  'Je suis responsable de la sécurité et de la maintenance du ${boat.name}.',
                  style: const pw.TextStyle(fontSize: 10, lineSpacing: 3),
                ),
                pw.SizedBox(height: 14),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Date : $dateStr',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Signature : $responsable',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'rapport_${boat.name}.pdf',
    );
  }

  IconData _statusIconData(String status) {
    switch (status) {
      case 'En mer':
        return Icons.water;
      case 'Au port':
        return Icons.anchor;
      case 'En maintenance':
        return Icons.build;
      default:
        return Icons.help_outline;
    }
  }
}

// ── SubtleWavePainter (inchangé) ──────────────
class SubtleWavePainter extends CustomPainter {
  final double animationValue;
  SubtleWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;
    final paint = Paint()..style = PaintingStyle.fill;
    _drawSubtleWave(
      canvas,
      size,
      paint..color = Colors.white.withOpacity(0.02),
      0.85,
      animationValue * 2 * math.pi,
      30,
    );
    _drawSubtleWave(
      canvas,
      size,
      paint..color = Colors.white.withOpacity(0.015),
      0.9,
      animationValue * 2 * math.pi + math.pi / 2,
      20,
    );
  }

  void _drawSubtleWave(
    Canvas canvas,
    Size size,
    Paint paint,
    double yPos,
    double phase,
    double amp,
  ) {
    if (size.width == 0 || size.height == 0) return;
    final path = ui.Path();
    final y = size.height * yPos;
    final waveLen = size.width / 3;
    path.moveTo(0, y);
    for (double x = 0; x <= size.width; x += 3) {
      path.lineTo(x, y + math.sin((x / waveLen * 2 * math.pi) + phase) * amp);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SubtleWavePainter old) =>
      old.animationValue != animationValue;
}
