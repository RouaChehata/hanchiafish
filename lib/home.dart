import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primaa/boat_detail_screen.dart';
import 'package:primaa/models/boat.dart';
import 'package:primaa/screens/map_screen.dart';
import 'package:primaa/screens/cameras_screen.dart';
import 'package:primaa/screens/history_screen.dart';
import 'package:primaa/screens/settings_screen.dart';

class Home extends StatefulWidget {
  final String userEmail;

  const Home({super.key, required this.userEmail});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Boat> boats = Boat.getDemoBoats();
  String _selectedFilter = 'Tous'; // Tous, En mer, Au port, En maintenance
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset('videos/riraa.mp4');
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      _videoController!.setVolume(0); // Mute la vidéo
      _videoController!.play();
      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      // Si la vidéo n'existe pas, on continue sans vidéo
      print('Erreur lors du chargement de la vidéo: $e');
      _isVideoInitialized = false;
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredBoats = _getFilteredBoats();
    final stats = _calculateStats();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          // Vidéo en arrière-plan
          if (_isVideoInitialized && _videoController != null)
            Positioned.fill(
              child: Opacity(
                opacity:
                    0.8, // Opacité augmentée pour rendre la vidéo plus visible
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController!.value.size.width,
                      height: _videoController!.value.size.height,
                      child: VideoPlayer(_videoController!),
                    ),
                  ),
                ),
              ),
            )
          else
            // Fallback si pas de vidéo
            Container(color: const Color(0xFFF5F7FA)),
          // Contenu principal
          RefreshIndicator(
            onRefresh: () async {
              // Simuler un rafraîchissement
              await Future.delayed(const Duration(seconds: 1));
              setState(() {});
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashboard avec statistiques principales
                  _buildDashboard(stats),

                  // Filtres et titre de section
                  _buildSectionHeader(filteredBoats.length),

                  // Liste des bateaux
                  _buildBoatsList(filteredBoats),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tableau de bord',
            style: GoogleFonts.bebasNeue(
              color: const Color(0xFF1E3A8A),
              fontSize: 28,
              letterSpacing: 1.5,
            ),
          ),
          Text(
            'Bienvenue, ${widget.userEmail.split('@')[0]}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
          color: const Color(0xFF1E3A8A),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDashboard(Map<String, dynamic> stats) {
    return Container(
      color: Colors.white.withOpacity(
        0.60,
      ), // Semi-transparent pour voir la vidéo
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vue d\'ensemble',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          // Métriques principales
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Flotte active',
                  stats['active'].toString(),
                  '${stats['total']} bateaux',
                  Icons.directions_boat,
                  const Color(0xFF1E3A8A),
                  Colors.blue.shade50,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'En opération',
                  stats['atSea'].toString(),
                  'En mer',
                  Icons.water,
                  const Color(0xFF1E3A8A),
                  const Color(0xFFEFF6FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Vitesse moyenne',
                  '${stats['avgSpeed'].toStringAsFixed(1)}',
                  'nœuds',
                  Icons.speed,
                  const Color(0xFF1E40AF),
                  const Color.fromARGB(255, 228, 238, 250),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Caméras actives',
                  stats['cameras'].toString(),
                  '${stats['total']} total',
                  Icons.videocam,
                  const Color(0xFF1E3A8A),
                  const Color.fromARGB(255, 220, 234, 247),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.60), // Semi-transparent pour voir la vidéo
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(int count) {
    return Container(
      color: Colors.white.withOpacity(
        0.60,
      ), // Semi-transparent pour voir la vidéo
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          const Text(
            'Flotte',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const Spacer(),
          // Filtres
          _buildFilterChip('Tous', _selectedFilter == 'Tous'),
          const SizedBox(width: 8),
          _buildFilterChip('En mer', _selectedFilter == 'En mer'),
          const SizedBox(width: 8),
          _buildFilterChip('Au port', _selectedFilter == 'Au port'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildBoatsList(List<Boat> boatsList) {
    if (boatsList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.directions_boat_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun bateau trouvé',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: boatsList.length,
      itemBuilder: (context, index) {
        return _buildProfessionalBoatCard(boatsList[index]);
      },
    );
  }

  Widget _buildProfessionalBoatCard(Boat boat) {
    Color statusColor;
    IconData statusIcon;
    switch (boat.status) {
      case 'En mer':
        statusColor = Colors.green;
        statusIcon = Icons.water;
        break;
      case 'Au port':
        statusColor = Colors.orange;
        statusIcon = Icons.anchor;
        break;
      case 'En maintenance':
        statusColor = Colors.red;
        statusIcon = Icons.build;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12), // Réduit de 16 à 12
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(
          0.60,
        ), // Semi-transparent pour voir la vidéo
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => BoatDetailScreen(boat: boat)),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12), // Réduit de 16 à 12
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec nom et statut
                Row(
                  children: [
                    // Icône du bateau
                    Container(
                      width: 40, // Réduit de 50 à 45
                      height: 40, // Réduit de 50 à 45
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          boat.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.directions_boat,
                              color: Color(0xFF1E3A8A),
                              size: 28,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Nom et ID
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            boat.name,
                            style: const TextStyle(
                              fontSize: 16, // Réduit de 18 à 16
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ID: ${boat.id}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Badge de statut
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
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
                const SizedBox(height: 16),
                // Métriques
                Row(
                  children: [
                    Expanded(
                      child: _buildBoatMetric(
                        Icons.speed,
                        '${boat.speed.toStringAsFixed(1)} nœuds',
                        'Vitesse',
                        Colors.blue,
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.grey[200]),
                    Expanded(
                      child: _buildBoatMetric(
                        Icons.people,
                        '${boat.crewMembers}',
                        'Équipage',
                        Colors.indigo,
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.grey[200]),
                    Expanded(
                      child: _buildBoatMetric(
                        boat.cameraActive ? Icons.videocam : Icons.videocam_off,
                        boat.cameraActive ? 'Active' : 'Inactive',
                        'Caméra',
                        boat.cameraActive ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Footer avec dernière mise à jour
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Dernière mise à jour: ${boat.lastUpdate}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBoatMetric(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  Map<String, dynamic> _calculateStats() {
    final activeBoats = boats.where((b) => b.status == 'En mer').length;
    final atSea = boats.where((b) => b.status == 'En mer').length;
    final avgSpeed =
        boats.map((b) => b.speed).reduce((a, b) => a + b) / boats.length;
    final activeCameras = boats.where((b) => b.cameraActive).length;

    return {
      'total': boats.length,
      'active': activeBoats,
      'atSea': atSea,
      'avgSpeed': avgSpeed,
      'cameras': activeCameras,
    };
  }

  List<Boat> _getFilteredBoats() {
    if (_selectedFilter == 'Tous') {
      return boats;
    }
    return boats.where((boat) => boat.status == _selectedFilter).toList();
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Color(0xFF1E3A8A)),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.userEmail,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFF1E3A8A)),
            title: const Text('Accueil'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.map, color: Color(0xFF1E3A8A)),
            title: const Text('Carte'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.videocam, color: Color(0xFF1E3A8A)),
            title: const Text('Caméras'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CamerasScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Color(0xFF1E3A8A)),
            title: const Text('Historique'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF1E3A8A)),
            title: const Text('Paramètres'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              // Déconnexion
            },
          ),
        ],
      ),
    );
  }
}
