import 'package:flutter/material.dart';
import '../models/boat.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<Boat> _boats = Boat.getDemoBoats();
  String? _selectedBoatId;
  String _selectedFilter = 'Aujourd\'hui'; // Aujourd'hui, Semaine, Mois

  // Données d'historique simulées
  List<Map<String, dynamic>> _getHistoryData() {
    final boat = _boats.firstWhere(
      (b) => b.id == _selectedBoatId,
      orElse: () => _boats.first,
    );

    return [
      {
        'time': '14:30',
        'date': 'Aujourd\'hui',
        'latitude': boat.latitude + 0.001,
        'longitude': boat.longitude + 0.001,
        'speed': boat.speed + 2.5,
        'status': 'En mer',
      },
      {
        'time': '12:15',
        'date': 'Aujourd\'hui',
        'latitude': boat.latitude + 0.0005,
        'longitude': boat.longitude + 0.0005,
        'speed': boat.speed + 1.2,
        'status': 'En mer',
      },
      {
        'time': '10:00',
        'date': 'Aujourd\'hui',
        'latitude': boat.latitude,
        'longitude': boat.longitude,
        'speed': boat.speed,
        'status': 'En mer',
      },
      {
        'time': '18:45',
        'date': 'Hier',
        'latitude': boat.latitude - 0.002,
        'longitude': boat.longitude - 0.002,
        'speed': boat.speed - 1.5,
        'status': 'En mer',
      },
      {
        'time': '16:20',
        'date': 'Hier',
        'latitude': boat.latitude - 0.001,
        'longitude': boat.longitude - 0.001,
        'speed': boat.speed - 0.8,
        'status': 'En mer',
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _selectedBoatId = _boats.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final historyData = _getHistoryData();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historique',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
            // Sélecteur de bateau et filtre
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Sélecteur de bateau
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
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
                    child: DropdownButton<String>(
                      value: _selectedBoatId,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down),
                      items: _boats.map((boat) {
                        return DropdownMenuItem<String>(
                          value: boat.id,
                          child: Row(
                            children: [
                              Icon(
                                Icons.directions_boat,
                                color: const Color(0xFF1E3A8A),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                boat.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBoatId = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Filtres de période
                  Row(
                    children: [
                      _buildFilterChip('Aujourd\'hui', _selectedFilter == 'Aujourd\'hui'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Semaine', _selectedFilter == 'Semaine'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Mois', _selectedFilter == 'Mois'),
                    ],
                  ),
                ],
              ),
            ),
            // Liste de l'historique
            Expanded(
              child: Container(
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
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          const Text(
                            'Trajet récent',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${historyData.length} points',
                              style: const TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: historyData.length,
                        itemBuilder: (context, index) {
                          return _buildHistoryItem(
                            historyData[index],
                            index == 0,
                            index == historyData.length - 1,
                          );
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

  Widget _buildFilterChip(String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF1E3A8A)
                  : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? const Color(0xFF1E3A8A)
                  : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    Map<String, dynamic> data,
    bool isFirst,
    bool isLast,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne de temps verticale
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFirst
                      ? Colors.green
                      : const Color(0xFF1E3A8A),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      data['time'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        data['status'],
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      data['date'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Lat: ${data['latitude'].toStringAsFixed(5)}, '
                        'Lng: ${data['longitude'].toStringAsFixed(5)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.speed, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${data['speed'].toStringAsFixed(1)} nœuds',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.map, size: 18),
                      color: const Color(0xFF1E3A8A),
                      onPressed: () {
                        // Ouvrir la position sur la carte
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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
}
