import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primaa/boat_detail_screen.dart';
import 'package:primaa/models/boat_model.dart';
import 'package:primaa/screens/map_screen.dart';
import 'package:primaa/screens/cameras_screen.dart';
import 'package:primaa/screens/history_screen.dart';
import 'package:primaa/screens/settings_screen.dart';
import 'package:primaa/screens/notifications_screen.dart';
import 'package:primaa/add_boat_dialog.dart';
import 'package:primaa/screens/statistics_screen.dart';

class Home extends StatefulWidget {
  final String userEmail;

  const Home({super.key, required this.userEmail});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Boat> boats = Boat.getDemoBoats();
  String _selectedFilter = 'Tous'; // Tous, En mer, Au port, En maintenance

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        heroTag: 'addBoatFab',
        onPressed: _addBoat,
        backgroundColor: const Color.fromARGB(255, 119, 192, 216),
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          // Arrière-plan simple avec gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF5F7FA),
                  Color(0xFFE8F2FD),
                  Color(0xFFDBEAFE),
                ],
              ),
            ),
          ),
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

  void _addBoat() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddBoatDialog(
          onAddBoat: (boat) {
            setState(() {
              boats.add(boat);
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _deleteBoat(Boat boat) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Supprimer le bateau'),
          content: Text('Êtes-vous sûr de vouloir supprimer ${boat.name} ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  boats.removeWhere((b) => b.id == boat.id);
                });
                Navigator.of(context).pop();
              },
              child: Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color.fromARGB(255, 119, 192, 216),
      iconTheme: const IconThemeData(color: Colors.white),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tableau de bord',
            style: GoogleFonts.bebasNeue(
              color: Colors.white,
              fontSize: 28,
              letterSpacing: 1.5,
            ),
          ),
          Text(
            'Bienvenue, ${widget.userEmail.split('@')[0]}',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
              color: Colors.white,
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDashboard(Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vue d\'ensemble',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          // Cartes modernes avec effet glassmorphism
          Row(
            children: [
              Expanded(
                child: _buildModernMetricCard(
                  'Flotte active',
                  stats['active'].toString(),
                  '${stats['total']} bateaux',
                  Icons.directions_boat,
                  const Color(0xFF3B82F6),
                  [
                    const Color(0xFF3B82F6).withOpacity(0.1),
                    const Color(0xFF1D4ED8).withOpacity(0.05),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildModernMetricCard(
                  'Caméras actives',
                  stats['cameras'].toString(),
                  '${stats['total']} total',
                  Icons.videocam,
                  const Color(0xFF10B981),
                  [
                    const Color(0xFF10B981).withOpacity(0.1),
                    const Color(0xFF059669).withOpacity(0.05),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernMetricCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    List<Color> gradientColors,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône avec fond moderne
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          // Valeur principale
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          // Titre
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
          // Sous-titre
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.6),
            ),
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.60), // Semi-transparent pour voir la vidéo
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.18), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(int count) {
    return Container(
      color: Colors.transparent, // Enlever la barre blanche arrière-plan
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
          const SizedBox(width: 8),
          _buildFilterChip(
            'En maintenance',
            _selectedFilter == 'En maintenance',
          ),
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
                // Footer avec dernière mise à jour et actions
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Dernière mise à jour: ${boat.lastUpdate}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    // Delete button
                    GestureDetector(
                      onTap: () => _deleteBoat(boat),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
      backgroundColor: const Color.fromARGB(255, 30, 58, 138),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 119, 192, 216),
              Color.fromARGB(255, 63, 114, 175),
              Color.fromARGB(255, 30, 58, 138),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 119, 192, 216),
                    Color.fromARGB(255, 63, 114, 175),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      255,
                      119,
                      192,
                      216,
                    ).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bienvenue',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.userEmail.split('@')[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildModernDrawerItem(
                    icon: Icons.home_rounded,
                    title: 'Accueil',
                    onTap: () {
                      Navigator.pop(context);
                    },
                    isActive: true,
                  ),
                  const SizedBox(height: 4),
                  _buildModernDrawerItem(
                    icon: Icons.map_rounded,
                    title: 'Carte',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MapScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  _buildModernDrawerItem(
                    icon: Icons.videocam_rounded,
                    title: 'Caméras',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CamerasScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  _buildModernDrawerItem(
                    icon: Icons.history_rounded,
                    title: 'Historique',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  _buildModernDrawerItem(
                    icon: Icons.bar_chart_rounded,
                    title: 'Statistiques',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StatisticsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  _buildModernDrawerItem(
                    icon: Icons.settings_rounded,
                    title: 'Paramètres',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFFE2E8F0),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildModernDrawerItem(
                    icon: Icons.logout_rounded,
                    title: 'Déconnexion',
                    onTap: () {
                      // Déconnexion
                    },
                    isDestructive: true,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isActive = false,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        gradient: isActive
            ? const LinearGradient(
                colors: [
                  Color.fromARGB(255, 119, 192, 216),
                  Color.fromARGB(255, 63, 114, 175),
                ],
              )
            : null,
        color: isActive ? null : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: isActive
            ? null
            : Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: isDestructive
                        ? const LinearGradient(
                            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                          )
                        : isActive
                        ? LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.1),
                            ],
                          )
                        : null,
                    color: isDestructive
                        ? null
                        : isActive
                        ? null
                        : Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: isDestructive
                        ? null
                        : isActive
                        ? Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          )
                        : Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: isDestructive
                        ? Colors.white
                        : isActive
                        ? Colors.white
                        : Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? const Color(0xFFEF4444)
                          : isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.9),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Actif',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
