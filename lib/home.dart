import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.userEmail});

  final String userEmail;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String _selectedView = 'grid'; 
  String _searchQuery = '';
  String _filterStatus = 'all'; // 'all', 'active', 'inactive', 'alert'
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Données de démonstration des bateaux
  final List<Boat> _boats = [
    Boat(
      id: '1',
      name: 'Prima Star',
      captain: 'Mohammed Ben Ali',
      status: 'active',
      speed: 12.5,
      latitude: 35.8256,
      longitude: 10.6361,
      temperature: 18.5,
      fuel: 75,
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    Boat(
      id: '2',
      name: 'Ocean Navigator',
      captain: 'Ahmed Trabelsi',
      status: 'active',
      speed: 8.3,
      latitude: 36.8065,
      longitude: 10.1815,
      temperature: 19.2,
      fuel: 45,
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    Boat(
      id: '3',
      name: 'Sea Hunter',
      captain: 'Ali Makni',
      status: 'inactive',
      speed: 0.0,
      latitude: 35.5175,
      longitude: 11.0583,
      temperature: 17.8,
      fuel: 90,
      lastUpdate: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Boat(
      id: '4',
      name: 'Blue Horizon',
      captain: 'Karim Jebali',
      status: 'alert',
      speed: 15.8,
      latitude: 36.4500,
      longitude: 10.7500,
      temperature: 20.1,
      fuel: 25,
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
    Boat(
      id: '5',
      name: 'Mediterranean Prince',
      captain: 'Youssef Ben Salah',
      status: 'active',
      speed: 10.2,
      latitude: 35.9500,
      longitude: 10.9000,
      temperature: 18.9,
      fuel: 60,
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
    Boat(
      id: '6',
      name: 'Neptune Force',
      captain: 'Sofiane Touati',
      status: 'active',
      speed: 11.7,
      latitude: 36.2000,
      longitude: 10.5000,
      temperature: 19.5,
      fuel: 55,
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Boat> get _filteredBoats {
    return _boats.where((boat) {
      final matchesSearch = boat.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          boat.captain.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _filterStatus == 'all' || boat.status == _filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildBody(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF1565C0),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PrimaFish',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            'Suivi en temps réel',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: Colors.white),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            // Afficher les notifications
          },
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: const Color(0xFF1565C0),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Rechercher un bateau...',
              hintStyle: const TextStyle(color: Colors.white60),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white70),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white.withOpacity(0.15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D47A1),
              Color(0xFF1565C0),
              Color(0xFF1E88E5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // User Profile Section
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      widget.userEmail,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Administrateur',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white30, thickness: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  children: [
                    _buildDrawerItem(
                      icon: Icons.dashboard_rounded,
                      title: 'Tableau de bord',
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedIndex = 0;
                        });
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.directions_boat_rounded,
                      title: 'Flotte',
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.map_rounded,
                      title: 'Carte',
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedView = 'map';
                        });
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.analytics_rounded,
                      title: 'Statistiques',
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedIndex = 2;
                        });
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.history_rounded,
                      title: 'Historique',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(color: Colors.white30, thickness: 1, height: 30),
                    _buildDrawerItem(
                      icon: Icons.settings_rounded,
                      title: 'Paramètres',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Aide & Support',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.info_outline_rounded,
                      title: 'À propos',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white30, thickness: 1),
              _buildDrawerItem(
                icon: Icons.logout_rounded,
                title: 'Déconnexion',
                iconColor: Colors.redAccent,
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Colors.white,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Filter and View Options
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Tous', 'all'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Actifs', 'active'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Inactifs', 'inactive'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Alertes', 'alert'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildViewButton(Icons.grid_view_rounded, 'grid'),
                        _buildViewButton(Icons.list_rounded, 'list'),
                        _buildViewButton(Icons.map_rounded, 'map'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Boats List/Grid
        Expanded(
          child: _selectedView == 'grid'
              ? _buildGridView()
              : _selectedView == 'list'
                  ? _buildListView()
                  : _buildMapView(),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    int count = 0;
    
    if (value == 'all') {
      count = _boats.length;
    } else {
      count = _boats.where((boat) => boat.status == value).length;
    }

    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
      },
      backgroundColor: Colors.grey[100],
      selectedColor: const Color(0xFF1565C0),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildViewButton(IconData icon, String view) {
    final isSelected = _selectedView == view;
    return IconButton(
      icon: Icon(icon),
      color: isSelected ? const Color(0xFF1565C0) : Colors.grey[600],
      onPressed: () {
        setState(() {
          _selectedView = view;
        });
      },
    );
  }

  Widget _buildGridView() {
    final boats = _filteredBoats;
    
    if (boats.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: boats.length,
        itemBuilder: (context, index) {
          return _buildBoatCard(boats[index]);
        },
      ),
    );
  }

  Widget _buildListView() {
    final boats = _filteredBoats;
    
    if (boats.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: boats.length,
        itemBuilder: (context, index) {
          return _buildBoatListTile(boats[index]);
        },
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue[100]!,
            Colors.blue[50]!,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Placeholder for map (you would integrate Google Maps or similar here)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_rounded,
                  size: 100,
                  color: Colors.blue[300],
                ),
                const SizedBox(height: 20),
                Text(
                  'Vue Carte',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Intégration Google Maps à venir',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
          // Boat markers overlay
          ..._filteredBoats.map((boat) => _buildBoatMarker(boat)),
        ],
      ),
    );
  }

  Widget _buildBoatMarker(Boat boat) {
    // Simple representation - in real app, position based on lat/long
    final random = math.Random(boat.id.hashCode);
    final left = random.nextDouble() * 300;
    final top = random.nextDouble() * 400 + 50;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () => _showBoatDetails(boat),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(boat.status),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.directions_boat,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildBoatCard(Boat boat) {
    return GestureDetector(
      onTap: () => _showBoatDetails(boat),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getStatusColor(boat.status),
                    _getStatusColor(boat.status).withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_boat,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          boat.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _getStatusText(boat.status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            boat.captain,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.speed,
                      '${boat.speed.toStringAsFixed(1)} kn',
                    ),
                    const SizedBox(height: 6),
                    _buildInfoRow(
                      Icons.location_on_outlined,
                      '${boat.latitude.toStringAsFixed(4)}°',
                    ),
                    const Spacer(),
                    // Fuel indicator
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.local_gas_station,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${boat.fuel}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: boat.fuel / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              boat.fuel > 50
                                  ? Colors.green
                                  : boat.fuel > 25
                                      ? Colors.orange
                                      : Colors.red,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
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

  Widget _buildBoatListTile(Boat boat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getStatusColor(boat.status),
                _getStatusColor(boat.status).withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.directions_boat,
            color: Colors.white,
            size: 28,
          ),
        ),
        title: Text(
          boat.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              boat.captain,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildSmallInfoChip(
                  Icons.speed,
                  '${boat.speed.toStringAsFixed(1)} kn',
                ),
                const SizedBox(width: 8),
                _buildSmallInfoChip(
                  Icons.local_gas_station,
                  '${boat.fuel}%',
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(boat.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusText(boat.status),
                    style: TextStyle(
                      color: _getStatusColor(boat.status),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          iconSize: 16,
          onPressed: () => _showBoatDetails(boat),
        ),
        onTap: () => _showBoatDetails(boat),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun bateau trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1565C0),
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_boat_rounded),
            label: 'Flotte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: 'Statistiques',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        // Action to add new boat
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ajouter un nouveau bateau'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      backgroundColor: const Color(0xFF1565C0),
      icon: const Icon(Icons.add),
      label: const Text('Ajouter'),
      elevation: 4,
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFF4CAF50);
      case 'inactive':
        return const Color(0xFF9E9E9E);
      case 'alert':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF2196F3);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'En mer';
      case 'inactive':
        return 'Au port';
      case 'alert':
        return 'Alerte';
      default:
        return 'Inconnu';
    }
  }

  void _showBoatDetails(Boat boat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getStatusColor(boat.status),
                    _getStatusColor(boat.status).withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_boat,
                      color: Colors.white,
                      size: 32,
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
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStatusText(boat.status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Details
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection(
                      'Informations générales',
                      [
                        _buildDetailRow(Icons.person, 'Capitaine', boat.captain),
                        _buildDetailRow(Icons.tag, 'ID', boat.id),
                        _buildDetailRow(
                          Icons.access_time,
                          'Dernière mise à jour',
                          _formatTimestamp(boat.lastUpdate),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailSection(
                      'Position GPS',
                      [
                        _buildDetailRow(
                          Icons.location_on,
                          'Latitude',
                          '${boat.latitude.toStringAsFixed(6)}°',
                        ),
                        _buildDetailRow(
                          Icons.location_on,
                          'Longitude',
                          '${boat.longitude.toStringAsFixed(6)}°',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailSection(
                      'Données en temps réel',
                      [
                        _buildDetailRow(
                          Icons.speed,
                          'Vitesse',
                          '${boat.speed.toStringAsFixed(1)} kn',
                        ),
                        _buildDetailRow(
                          Icons.thermostat,
                          'Température',
                          '${boat.temperature.toStringAsFixed(1)}°C',
                        ),
                        _buildDetailRow(
                          Icons.local_gas_station,
                          'Carburant',
                          '${boat.fuel}%',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Track boat on map
                          Navigator.pop(context);
                          setState(() {
                            _selectedView = 'map';
                          });
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('Suivre sur la carte'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1565C0),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else {
      return 'Il y a ${difference.inDays} j';
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to login
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}

// Boat Model
class Boat {
  final String id;
  final String name;
  final String captain;
  final String status;
  final double speed;
  final double latitude;
  final double longitude;
  final double temperature;
  final int fuel;
  final DateTime lastUpdate;

  Boat({
    required this.id,
    required this.name,
    required this.captain,
    required this.status,
    required this.speed,
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.fuel,
    required this.lastUpdate,
  });
}