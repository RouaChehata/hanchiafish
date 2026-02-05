import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:primaa/models/boat.dart';

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

  final MapController _mapController = MapController();
  Timer? _simulationTimer;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _currentPosition = LatLng(widget.boat.latitude, widget.boat.longitude);
    _currentSpeed = widget.boat.speed;
    _lastUpdate = widget.boat.lastUpdate;

    // Animation des vagues
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Simulation de données en temps réel pour la démo
    _simulationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        // On simule un léger déplacement du bateau
        _currentPosition = LatLng(
          _currentPosition.latitude + 0.0005,
          _currentPosition.longitude + 0.0005,
        );
        _currentSpeed = (_currentSpeed + 0.3) % 22;
        _lastUpdate = "Il y a quelques secondes";

        if (_followOnMap) {
          _mapController.move(_currentPosition, _mapController.camera.zoom);
        }
      });
    });
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boat = widget.boat;

    return Scaffold(
      backgroundColor: const Color(0xFF0A4D68),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          boat.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Arrière-plan avec vagues de mer
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavePainter(_waveController.value),
                );
              },
            ),
          ),
          // Contenu
          Column(
            children: [
            _buildHeader(boat),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Informations générales'),
                    const SizedBox(height: 8),
                    _buildGeneralInfo(boat),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Position GPS & Temps réel'),
                    const SizedBox(height: 8),
                    _buildGpsInfo(),
                    const SizedBox(height: 12),
                    _buildMapCard(),
                  ],
                ),
              ),
            ),
          ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Boat boat) {
    Color statusColor;
    String statusLabel = boat.status;

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
        statusLabel = 'Statut inconnu';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: Colors.white24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                boat.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.directions_boat_filled,
                    color: Colors.white,
                    size: 40,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  boat.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID : ${boat.id}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 10,
                            color: statusColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.wifi_tethering,
                            size: 14,
                            color: Colors.lightGreenAccent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Temps réel',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
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
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2933),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralInfo(Boat boat) {
    return Row(
      children: [
        Expanded(
          child: _infoCard(
            title: 'Vitesse',
            icon: Icons.speed,
            value: '${_currentSpeed.toStringAsFixed(1)} nœuds',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _infoCard(
            title: 'Équipage',
            icon: Icons.people,
            value: '${boat.crewMembers} marins',
            color: Colors.indigo,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _infoCard(
            title: 'Caméra',
            icon: boat.cameraActive ? Icons.videocam : Icons.videocam_off,
            value: boat.cameraActive ? 'Active' : 'Inactive',
            color: boat.cameraActive ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _infoCard({
    required String title,
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGpsInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_pin,
                color: Color(0xFF1E3A8A),
              ),
              const SizedBox(width: 8),
              const Text(
                'Coordonnées actuelles',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.circle,
                      size: 10,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _lastUpdate,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Lat: ${_currentPosition.latitude.toStringAsFixed(5)} | '
            'Lng: ${_currentPosition.longitude.toStringAsFixed(5)}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentPosition,
                  initialZoom: 11,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.primaa',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 50,
                        height: 50,
                        point: _currentPosition,
                        child: _buildBoatMarker(),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Column(
                  children: [
                    _mapCircleButton(
                      icon: Icons.my_location,
                      onTap: () {
                        _mapController.move(
                          _currentPosition,
                          _mapController.camera.zoom,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _mapCircleButton(
                      icon: _followOnMap ? Icons.gps_fixed : Icons.location_searching,
                      isActive: _followOnMap,
                      onTap: () {
                        setState(() {
                          _followOnMap = !_followOnMap;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: _buildFollowButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoatMarker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: const Icon(
        Icons.directions_boat_filled,
        color: Color(0xFF1E3A8A),
        size: 24,
      ),
    );
  }

  Widget _mapCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: isActive ? const Color(0xFF1E3A8A) : Colors.grey[300]!,
            width: 1.3,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? const Color(0xFF1E3A8A) : Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildFollowButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 6,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      onPressed: () {
        setState(() {
          _followOnMap = true;
        });
        _mapController.move(_currentPosition, _mapController.camera.zoom);
      },
      icon: const Icon(Icons.map),
      label: const Text(
        'Suivre le bateau sur la carte',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}

// Classe pour dessiner les vagues de mer
class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;
    
    final paint = Paint()..style = PaintingStyle.fill;

    // Dégradé de fond (ciel bleu vers mer)
    final gradient = ui.Gradient.linear(
      Offset(0, 0),
      Offset(0, size.height),
      [
        const Color(0xFF0A4D68), // Bleu profond du ciel
        const Color(0xFF088395), // Bleu de la mer profonde
        const Color(0xFF05BFDB), // Turquoise de la mer
        const Color(0xFF00D9FF), // Cyan clair
        const Color(0xFFF4E4BC), // Sable de la plage
      ],
      [0.0, 0.3, 0.6, 0.85, 1.0],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradientPaint = Paint()
      ..shader = gradient;
    canvas.drawRect(rect, gradientPaint);

    // Dessiner plusieurs couches de vagues
    _drawWave(
      canvas,
      size,
      paint..color = const Color(0xFF088395).withOpacity(0.8),
      0.65,
      animationValue * 2 * math.pi,
      100,
    );

    _drawWave(
      canvas,
      size,
      paint..color = const Color(0xFF05BFDB).withOpacity(0.85),
      0.75,
      animationValue * 2 * math.pi + math.pi / 3,
      80,
    );

    _drawWave(
      canvas,
      size,
      paint..color = const Color(0xFF00D9FF).withOpacity(0.9),
      0.82,
      animationValue * 2 * math.pi + math.pi / 2,
      60,
    );

    _drawWave(
      canvas,
      size,
      paint..color = const Color(0xFFF4E4BC).withOpacity(0.95),
      0.88,
      animationValue * 2 * math.pi + math.pi,
      50,
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    Paint paint,
    double yPosition,
    double phase,
    double amplitude,
  ) {
    if (size.width == 0 || size.height == 0) return;
    
    final path = ui.Path();
    final y = size.height * yPosition;
    final waveLength = size.width / 1.5; // Longueur d'onde plus courte pour des vagues plus visibles

    path.moveTo(0, y);

    // Dessiner la vague avec plus de points pour une courbe plus lisse
    for (double x = 0; x <= size.width; x += 0.5) {
      final waveY = y +
          math.sin((x / waveLength * 2 * math.pi) + phase) * amplitude;
      path.lineTo(x, waveY);
    }

    // Fermer le chemin pour créer la forme de vague
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
