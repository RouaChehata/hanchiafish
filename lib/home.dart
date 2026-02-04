import 'package:flutter/material.dart';
import 'package:primaa/boat.dart';
import '../../models/boat.dart';

class Home extends StatefulWidget {
  final String userEmail;
  
  const Home({super.key, required this.userEmail});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Boat> boats = Boat.getDemoBoats();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Suivi des Bateaux',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
              Color(0xFFE0F2FE),
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Barres d'information (9 barres)
            _buildInfoBars(),
            
            // Liste des bateaux
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 20),
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
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Flotte de Bateaux',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: boats.length,
                        itemBuilder: (context, index) {
                          return _buildBoatCard(boats[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Color(0xFF1E3A8A),
                  ),
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
              // Navigation vers la carte
            },
          ),
          ListTile(
            leading: const Icon(Icons.videocam, color: Color(0xFF1E3A8A)),
            title: const Text('Caméras'),
            onTap: () {
              // Navigation vers les caméras
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Color(0xFF1E3A8A)),
            title: const Text('Historique'),
            onTap: () {
              // Navigation vers l'historique
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF1E3A8A)),
            title: const Text('Paramètres'),
            onTap: () {
              // Navigation vers les paramètres
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
            onTap: () {
              // Déconnexion
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBars() {
    final int totalBoats = boats.length;
    final int boatsAtSea = boats.where((b) => b.status == 'En mer').length;
    final int boatsAtPort = boats.where((b) => b.status == 'Au port').length;
    final int boatsInMaintenance = boats.where((b) => b.status == 'En maintenance').length;
    final int activeCameras = boats.where((b) => b.cameraActive).length;
    final double averageSpeed = boats.map((b) => b.speed).reduce((a, b) => a + b) / boats.length;
    final int totalCrew = boats.map((b) => b.crewMembers).reduce((a, b) => a + b);
    final int onlineBoats = boats.where((b) => b.lastUpdate.contains('min')).length;
    final double totalDistance = 1250.5; // Exemple de distance totale

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildInfoBar('Total Bateaux', totalBoats.toString(), Icons.directions_boat, Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _buildInfoBar('En Mer', boatsAtSea.toString(), Icons.water, Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _buildInfoBar('Au Port', boatsAtPort.toString(), Icons.anchor, Colors.orange)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildInfoBar('Maintenance', boatsInMaintenance.toString(), Icons.build, Colors.red)),
              const SizedBox(width: 8),
              Expanded(child: _buildInfoBar('Caméras', activeCameras.toString(), Icons.videocam, Colors.purple)),
              const SizedBox(width: 8),
              Expanded(child: _buildInfoBar('Vitesse Moy.', '${averageSpeed.toStringAsFixed(1)} nœuds', Icons.speed, Colors.teal)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildInfoBar('Équipage', totalCrew.toString(), Icons.people, Colors.indigo)),
              const SizedBox(width: 8),
              Expanded(child: _buildInfoBar('En Ligne', onlineBoats.toString(), Icons.wifi, Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _buildInfoBar('Distance', '${totalDistance.toStringAsFixed(1)} km', Icons.straighten, Colors.amber)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBar(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBoatCard(Boat boat) {
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
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () {
          // Navigation vers les détails du bateau
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image du bateau
              Container(
                width: 80,
                height: 80,
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
                      return const Icon(Icons.directions_boat, size: 40, color: Colors.grey);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Informations du bateau
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            boat.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            boat.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.speed, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${boat.speed.toStringAsFixed(1)} nœuds',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.people, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${boat.crewMembers} membres',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          boat.cameraActive ? Icons.videocam : Icons.videocam_off,
                          size: 16,
                          color: boat.cameraActive ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          boat.cameraActive ? 'Caméra active' : 'Caméra inactive',
                          style: TextStyle(
                            fontSize: 12,
                            color: boat.cameraActive ? Colors.green : Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          boat.lastUpdate,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}