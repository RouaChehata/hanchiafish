import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/boat_model.dart';
import 'package:primaa/api_service.dart';
import 'app_theme.dart';

class CamerasScreen extends StatefulWidget {
  const CamerasScreen({super.key});

  @override
  State<CamerasScreen> createState() => _CamerasScreenState();
}

class _CamerasScreenState extends State<CamerasScreen> {
  final List<Boat> _boats = Boat.getDemoBoats();
  String? _cameraImageBase64;
  String? _imageTimestamp;
  bool _isLoadingImage = false;
  // ✅ FIX : _intrusion gardé pour les alertes texte UNIQUEMENT
  // — plus aucun overlay rouge / symbole ⚠ sur le flux vidéo
  bool _intrusion = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadCameraImage();
    _loadAlertes();
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _loadCameraImage(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadCameraImage() async {
    setState(() => _isLoadingImage = true);
    try {
      final response = await http
          .get(Uri.parse('${ApiService.baseUrl}/camera'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _cameraImageBase64 = data['image'];
          _imageTimestamp = data['timestamp'];
        });
      }
    } catch (_) {
    } finally {
      setState(() => _isLoadingImage = false);
    }
  }

  Future<void> _loadAlertes() async {
    final alertes = await ApiService.getAlertes();
    setState(
      () => _intrusion = alertes.any((a) => a['type'] == 'Intrusion détectée'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCameras = _boats.where((b) => b.cameraActive).toList();
    final inactiveCameras = _boats.where((b) => !b.cameraActive).toList();

    return MaritimeScaffold(
      appBar: MaritimeAppBar(
        title: 'Caméras',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            onPressed: _loadCameraImage,
          ),
        ],
      ),
      headerContent: _buildStatsHeader(
        activeCameras.length,
        inactiveCameras.length,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Titre + badge intrustion (texte seulement) ──────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                children: [
                  Text(
                    'Caméra RPi — EN DIRECT',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  // ✅ Badge discret (pas d'overlay rouge sur la vidéo)
                  if (_intrusion)
                    MaritimeBadge(
                      label: 'INTRUSION',
                      color: AppColors.error,
                      icon: Icons.warning_rounded,
                    ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // ── Flux vidéo RPi ──────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _buildRealCameraCard(),
            ),

            // ── Caméras Actives ─────────────────────────────────
            SizedBox(height: AppSpacing.xl),
            MaritimeSectionTitle(
              title: 'Caméras Actives',
              badge: '${activeCameras.length} actives',
              badgeColor: AppColors.success,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: activeCameras.length,
              itemBuilder: (_, i) =>
                  _buildCameraCard(activeCameras[i], isActive: true),
            ),

            // ── Caméras Inactives ───────────────────────────────
            if (inactiveCameras.isNotEmpty) ...[
              MaritimeSectionTitle(
                title: 'Caméras Inactives',
                badge: '${inactiveCameras.length} inactives',
                badgeColor: AppColors.cameraInactive,
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  scrollDirection: Axis.horizontal,
                  itemCount: inactiveCameras.length,
                  itemBuilder: (_, i) =>
                      _buildCameraCard(inactiveCameras[i], isActive: false),
                ),
              ),
            ],
            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  // ── Stats header ─────────────────────────────────────────────
  Widget _buildStatsHeader(int active, int inactive) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: _HeaderStatTile(
              icon: Icons.videocam,
              value: '$active',
              label: 'Actives',
              color: AppColors.success,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: _HeaderStatTile(
              icon: Icons.videocam_off,
              value: '$inactive',
              label: 'Inactives',
              color: AppColors.cameraInactive,
            ),
          ),
        ],
      ),
    );
  }

  // ── Flux caméra RPi ──────────────────────────────────────────
  // ✅ FIX : ZÉRO overlay rouge / symbole ⚠ sur la vidéo
  //    Le flux joue normalement. L'intrusion est signalée
  //    uniquement dans la ligne de statut en bas de la card.
  Widget _buildRealCameraCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.elevated,
        border: Border.all(
          // Bordure verte ou rouge légère — pas d'overlay sur la vidéo
          color: _intrusion
              ? AppColors.error.withOpacity(0.4)
              : AppColors.success.withOpacity(0.35),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Column(
          children: [
            // ── Zone vidéo pure ─────────────────────
            Stack(
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  color: const Color(0xFF0A0E1A),
                  child: _cameraImageBase64 != null
                      ? Image.memory(
                          base64Decode(_cameraImageBase64!),
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          // ✅ Pas d'erreur visible — juste le fond noir
                          errorBuilder: (_, __, ___) => SizedBox.shrink(),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _isLoadingImage
                                  ? SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        color: Colors.white54,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.videocam_off,
                                      color: Colors.white24,
                                      size: 42,
                                    ),
                              SizedBox(height: AppSpacing.sm),
                              const Text(
                                'En attente de la caméra…',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                // Badge EN DIRECT (coin haut-droite)
                Positioned(top: 12, right: 12, child: _LiveDot()),
                // Timestamp (coin bas-gauche)
                if (_imageTimestamp != null)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        _imageTimestamp!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                // ✅ PAS D'OVERLAY INTRUSION ICI — flux propre
              ],
            ),

            // ── Ligne de statut ─────────────────────
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: _intrusion
                    ? AppColors.error.withOpacity(0.06)
                    : AppColors.success.withOpacity(0.05),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.videocam,
                    color: _intrusion ? AppColors.error : AppColors.success,
                    size: 18,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Caméra Raspberry Pi',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: AppColors.primary),
                  ),
                  const Spacer(),
                  // Statut textuel uniquement
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (_intrusion ? AppColors.error : AppColors.success)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppRadius.round),
                      border: Border.all(
                        color:
                            (_intrusion ? AppColors.error : AppColors.success)
                                .withOpacity(0.35),
                      ),
                    ),
                    child: Text(
                      _intrusion ? 'Intrusion détectée' : 'Sécurisé',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _intrusion ? AppColors.error : AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Card caméra (active ou inactive) ─────────────────────────
  // ✅ FIX : aucun overlay ⚠ sur les cards non-RPi
  Widget _buildCameraCard(Boat boat, {required bool isActive}) {
    final isRealBoat = boat.id == '1';

    return Container(
      width: isActive ? double.infinity : 280,
      margin: EdgeInsets.only(bottom: AppSpacing.lg, right: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card,
        border: Border.all(
          color: isActive
              ? AppColors.success.withOpacity(0.3)
              : AppColors.border,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Image / flux
                Container(
                  height: isActive ? 200 : 150,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: AppGradients.cardHeader,
                  ),
                  child: isRealBoat && _cameraImageBase64 != null
                      ? Image.memory(
                          base64Decode(_cameraImageBase64!),
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          errorBuilder: (_, __, ___) => SizedBox.shrink(),
                        )
                      : Image.asset(
                          boat.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.videocam,
                                  size: 40,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Caméra ${boat.name}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                // Badge statut
                Positioned(
                  top: 10,
                  right: 10,
                  child: MaritimeBadge(
                    label: isActive ? 'EN DIRECT' : 'HORS LIGNE',
                    color: isActive
                        ? AppColors.success
                        : AppColors.cameraInactive,
                    icon: isActive ? Icons.circle : Icons.circle_outlined,
                  ),
                ),
                // Badge LIVE (coin bas-gauche des actives)
                if (isActive)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_circle_filled,
                            color: Colors.white,
                            size: 13,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // ✅ PAS D'OVERLAY INTRUSION SUR LES CARDS
              ],
            ),
            // Footer
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          boat.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.primary),
                        ),
                        SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 3),
                            Text(
                              '${boat.latitude.toStringAsFixed(4)}, '
                              '${boat.longitude.toStringAsFixed(4)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isActive ? Icons.videocam : Icons.videocam_off,
                    color: isActive
                        ? AppColors.cameraActive
                        : AppColors.cameraInactive,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dot "EN DIRECT" animé ─────────────────────────────────────
// Remplace le badge rouge statique par un point vert qui pulse
class _LiveDot extends StatefulWidget {
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.5, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(AppRadius.round),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withOpacity(_anim.value),
              ),
            ),
            SizedBox(width: 5),
            const Text(
              'EN DIRECT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tuile stat header ────────────────────────────────────────
class _HeaderStatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _HeaderStatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
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
      ),
    );
  }
}
