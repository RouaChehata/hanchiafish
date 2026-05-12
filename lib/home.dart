import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:primaa/loginScreen.dart';
import 'package:video_player/video_player.dart';
import 'package:primaa/boat_detail_screen.dart';
import 'package:primaa/models/boat_model.dart';
import 'package:primaa/screens/map_screen.dart';
import 'package:primaa/screens/cameras_screen.dart';
import 'package:primaa/screens/history_screen.dart';
import 'package:primaa/screens/settings_screen.dart';
import 'package:primaa/screens/notifications_screen.dart';
import 'package:primaa/add_boat_dialog.dart';
import 'package:primaa/screens/statistics_screen.dart';
import 'package:primaa/screens/captures_screen.dart';
import 'package:primaa/screens/app theme.dart'; // ← Design System partagé
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Persistance
import 'package:primaa/api_service.dart'; // ✅ GPS Hanchia1
import 'dart:convert';
import 'dart:async';

// ════════════════════════════════════════════════════════════════
//  NOTE : AppColors, AppSpacing, AppRadius, AppGradients, AppShadows
//  sont désormais centralisés dans screens/app_theme.dart.
//  Les anciennes classes locales AppColors/AppTextStyles/AppSpacing/
//  AppBorderRadius ont été SUPPRIMÉES de ce fichier.
// ════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────
//  VideoBackground
//  ✅ BUG FIX : _loadBoats() utilisait "_boats" qui n'existait pas
//  dans VideoBackgroundState. Corrigé en passant Boat.getDemoBoats()
//  directement dans updateRealBoat().
// ─────────────────────────────────────────────
class VideoBackground extends StatefulWidget {
  const VideoBackground({super.key});

  @override
  State<VideoBackground> createState() => VideoBackgroundState();
}

class VideoBackgroundState extends State<VideoBackground> {
  static VideoPlayerController? _staticController;
  static bool _isInitialized = false;
  static int _playCount = 0;

  @override
  void initState() {
    super.initState();
    _initVideo(); // ✅ Nahina _loadBoats mel hna khatr mch blastou
  }

  Future<void> _initVideo() async {
    if (_isInitialized &&
        _staticController != null &&
        _staticController!.value.isInitialized) {
      if (mounted) setState(() {});
      return;
    }
    _staticController = VideoPlayerController.asset('assets/videos/home.mp4');
    await _staticController!.initialize();
    _staticController!.addListener(_videoListener);
    _staticController!.play();
    _isInitialized = true;
    if (mounted) setState(() {});
  }

  void _videoListener() {
    if (_staticController == null || !_staticController!.value.isInitialized)
      return;
    if (_staticController!.value.position >=
            _staticController!.value.duration &&
        _playCount < 1) {
      _playCount++;
      _staticController!.seekTo(Duration.zero);
      _staticController!.play();
    } else if (_playCount >= 1 &&
        _staticController!.value.position >=
            _staticController!.value.duration) {
      _staticController!.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized ||
        _staticController == null ||
        !_staticController!.value.isInitialized) {
      return Container(
        decoration: const BoxDecoration(gradient: AppGradients.bodyBackground),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _staticController!.value.size.width,
            height: _staticController!.value.size.height,
            child: VideoPlayer(_staticController!),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Home
// ─────────────────────────────────────────────
class Home extends StatefulWidget {
  final String userEmail;
  const Home({super.key, required this.userEmail});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Boat> boats = []; // ✅ Chargé depuis SharedPreferences
  String _selectedFilter = 'Tous';
  Timer? _boatTimer;
  bool _isLoading = true;

  static const String _boatsKey = 'saved_boats';

  @override
  void initState() {
    super.initState();
    _loadBoatsFromStorage();
  }

  @override
  void dispose() {
    _boatTimer?.cancel();
    super.dispose();
  }

  // ── Charger depuis SharedPreferences ──────────────────────
  Future<void> _loadBoatsFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_boatsKey);
    List<Boat> loaded;
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        loaded = list
            .map((j) => Boat.fromJson(j as Map<String, dynamic>))
            .toList();
      } catch (_) {
        loaded = Boat.getDemoBoats();
      }
    } else {
      loaded = Boat.getDemoBoats();
      await _saveBoatsToStorage(loaded);
    }
    if (mounted)
      setState(() {
        boats = loaded;
        _isLoading = false;
      });
    _startLiveTracking();
  }

  // ── Sauvegarder dans SharedPreferences ────────────────────
  Future<void> _saveBoatsToStorage(List<Boat> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(list.map((b) => b.toJson()).toList());
    await prefs.setString(_boatsKey, jsonStr);
  }

  // ── GPS live pour HanchiaFish-001 ─────────────────────────
  void _startLiveTracking() {
    _refreshData();
    _boatTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _refreshData(),
    );
  }

  Future<void> _refreshData() async {
    await Boat.updateRealBoat(boats);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filteredBoats = _getFilteredBoats();
    final stats = _calculateStats();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        heroTag: 'addBoatFab',
        onPressed: _addBoat,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: VideoBackground()),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.28)),
          ),
          RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
              setState(() {});
            },
            color: AppColors.primaryLight,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDashboard(stats),
                  _buildSectionHeader(filteredBoats.length),
                  _buildBoatsList(filteredBoats),
                  SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: 60,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppGradients.primaryBar),
      ),
      iconTheme: const IconThemeData(color: AppColors.white),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Icon(
              Icons.directions_boat_filled,
              color: AppColors.white,
              size: 20,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HanchiaFish',
                style: GoogleFonts.bebasNeue(
                  color: AppColors.white,
                  fontSize: 22,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Bienvenue, ${widget.userEmail.split('@')[0]}',
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.75),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            Container(
              margin: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.white,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: AppSpacing.xs),
      ],
    );
  }

  // ── Dashboard ───────────────────────────────────────────────
  Widget _buildDashboard(Map<String, dynamic> stats) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vue d\'ensemble',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  title: 'Flotte active',
                  value: stats['active'].toString(),
                  subtitle: '${stats['total']} bateaux',
                  icon: Icons.directions_boat,
                  color: AppColors.primaryLight,
                  gradientColors: [
                    AppColors.primaryLight.withOpacity(0.18),
                    AppColors.primary.withOpacity(0.10),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _metricCard(
                  title: 'Caméras actives',
                  value: stats['cameras'].toString(),
                  subtitle: '${stats['total']} total',
                  icon: Icons.videocam,
                  color: AppColors.success,
                  gradientColors: [
                    AppColors.success.withOpacity(0.18),
                    AppColors.success.withOpacity(0.08),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: AppShadows.elevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header ──────────────────────────────────────────
  Widget _buildSectionHeader(int count) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Text(
            'Flotte',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppRadius.round),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const Spacer(),
          _filterChip('Tous', _selectedFilter == 'Tous'),
          SizedBox(width: AppSpacing.sm),
          _filterChip('En mer', _selectedFilter == 'En mer'),
          SizedBox(width: AppSpacing.sm),
          _filterChip('Au port', _selectedFilter == 'Au port'),
          SizedBox(width: AppSpacing.sm),
          _filterChip('En maintenance', _selectedFilter == 'En maintenance'),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(AppRadius.round),
          border: isSelected
              ? null
              : Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primary : AppColors.white,
          ),
        ),
      ),
    );
  }

  // ── Liste bateaux ───────────────────────────────────────────
  Widget _buildBoatsList(List<Boat> boatsList) {
    if (boatsList.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(AppSpacing.huge),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.directions_boat_outlined,
                size: 64,
                color: AppColors.white.withOpacity(0.5),
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Aucun bateau trouvé',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      itemCount: boatsList.length,
      itemBuilder: (_, i) => _buildBoatCard(boatsList[i]),
    );
  }

  Widget _buildBoatCard(Boat boat) {
    final statusColor = MaritimeStatusColor.fromStatus(boat.status);
    final statusIcon = _statusIcon(boat.status);

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.93),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
        border: Border.all(color: statusColor.withOpacity(0.2), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => BoatDetailScreen(boat: boat)),
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Image.asset(
                          boat.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.directions_boat,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            boat.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'ID: ${boat.id}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    // Badge statut
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.round),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          SizedBox(width: 4),
                          Text(
                            boat.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                // Métriques
                Row(
                  children: [
                    Expanded(
                      child: _boatMetric(
                        Icons.speed,
                        '${boat.speed.toStringAsFixed(1)} nœuds',
                        'Vitesse',
                        AppColors.primaryLight,
                      ),
                    ),
                    Container(width: 1, height: 36, color: AppColors.border),
                    Expanded(
                      child: _boatMetric(
                        Icons.people,
                        '${boat.crewMembers}',
                        'Équipage',
                        AppColors.primary,
                      ),
                    ),
                    Container(width: 1, height: 36, color: AppColors.border),
                    Expanded(
                      child: _boatMetric(
                        boat.cameraActive ? Icons.videocam : Icons.videocam_off,
                        boat.cameraActive ? 'Active' : 'Inactive',
                        'Caméra',
                        boat.cameraActive
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                // Footer
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Mis à jour : ${boat.lastUpdate}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _deleteBoat(boat),
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.textSecondary,
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

  Widget _boatMetric(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  IconData _statusIcon(String status) {
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

  Map<String, dynamic> _calculateStats() {
    return {
      'total': boats.length,
      'active': boats.where((b) => b.status == 'En mer').length,
      'cameras': boats.where((b) => b.cameraActive).length,
      'avgSpeed':
          boats.map((b) => b.speed).reduce((a, b) => a + b) / boats.length,
    };
  }

  List<Boat> _getFilteredBoats() {
    if (_selectedFilter == 'Tous') return boats;
    return boats.where((b) => b.status == _selectedFilter).toList();
  }

  // ── Dialogs ─────────────────────────────────────────────────
  void _addBoat() {
    showDialog(
      context: context,
      builder: (_) => AddBoatDialog(
        onAddBoat: (boat) async {
          // ✅ FIX : pas de Navigator.pop() ici
          // Le dialog se ferme lui-même dans _submit()
          // Double pop() = écran blanc
          setState(() => boats.add(boat));
          await _saveBoatsToStorage(boats);
        },
      ),
    );
  }

  void _deleteBoat(Boat boat) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(
          'Supprimer le bateau',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text('Êtes-vous sûr de vouloir supprimer ${boat.name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() => boats.removeWhere((b) => b.id == boat.id));
              await _saveBoatsToStorage(boats); // ✅ Persistance
              if (context.mounted) Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  // ── Drawer ───────────────────────────────────────────────────
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.primary,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.85),
              const Color(0xFF0A2E5C),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header profil
            Container(
              margin: EdgeInsets.all(AppSpacing.lg),
              padding: EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: AppSpacing.lg),
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
                        SizedBox(height: 4),
                        Text(
                          widget.userEmail.split('@')[0],
                          style: const TextStyle(
                            color: AppColors.white,
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
            ),
            SizedBox(height: AppSpacing.sm),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  _drawerItem(
                    icon: Icons.home_rounded,
                    title: 'Accueil',
                    isActive: true,
                    onTap: () => Navigator.pop(context),
                  ),
                  SizedBox(height: 4),
                  _drawerItem(
                    icon: Icons.map_rounded,
                    title: 'Carte',
                    onTap: () => _navTo(context, const MapScreen()),
                  ),
                  SizedBox(height: 4),
                  _drawerItem(
                    icon: Icons.videocam_rounded,
                    title: 'Caméras',
                    onTap: () => _navTo(context, const CamerasScreen()),
                  ),
                  SizedBox(height: 4),
                  _drawerItem(
                    icon: Icons.history_rounded,
                    title: 'Historique',
                    onTap: () => _navTo(context, const HistoryScreen()),
                  ),
                  SizedBox(height: 4),
                  _drawerItem(
                    icon: Icons.bar_chart_rounded,
                    title: 'Statistiques',
                    onTap: () => _navTo(context, const StatisticsScreen()),
                  ),
                  SizedBox(height: 4),
                  _drawerItem(
                    icon: Icons.photo_camera,
                    title: "Captures d'intrusion",
                    onTap: () => _navTo(context, const CapturesScreen()),
                  ),
                  SizedBox(height: 4),
                  _drawerItem(
                    icon: Icons.settings_rounded,
                    title: 'Paramètres',
                    onTap: () => _navTo(context, const SettingsScreen()),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  // ✅ Logout mwassal b Firebase + redirect lel Login
                  _drawerItem(
                    icon: Icons.logout_rounded,
                    title: 'Déconnexion',
                    isDestructive: true,
                    onTap: () async {
                      Navigator.pop(context); // sakker el drawer awel
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                          title: const Text(
                            'Déconnexion',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          content: const Text(
                            'Êtes-vous sûr de vouloir vous déconnecter ?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Annuler'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await FirebaseAuth.instance.signOut();
                                if (context.mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const Login(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: AppColors.white,
                              ),
                              child: const Text('Déconnexion'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navTo(BuildContext ctx, Widget screen) {
    Navigator.pop(ctx);
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isActive = false,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white.withOpacity(0.2)
            : isDestructive
            ? AppColors.error.withOpacity(0.15)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isActive
              ? Colors.white.withOpacity(0.4)
              : isDestructive
              ? AppColors.error.withOpacity(0.3)
              : Colors.white.withOpacity(0.12),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? AppColors.error.withOpacity(0.2)
                        : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive ? AppColors.error : AppColors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isDestructive ? AppColors.error : AppColors.white,
                      fontSize: 15,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
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
