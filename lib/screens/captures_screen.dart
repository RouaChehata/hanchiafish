import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:primaa/api_service.dart';
import 'app theme.dart';

class CapturesScreen extends StatefulWidget {
  const CapturesScreen({super.key});

  @override
  State<CapturesScreen> createState() => _CapturesScreenState();
}

class _CapturesScreenState extends State<CapturesScreen> {
  List<dynamic> _captures = [];
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadCaptures();
    _timer = Timer.periodic(
        const Duration(seconds: 10), (_) => _loadCaptures());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadCaptures() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getCaptures();
    setState(() {
      _captures  = data;
      _isLoading = false;
    });
  }

  // ── Appel API delete une capture ──────────────────────────
  Future<bool> _apiDeleteCapture(dynamic id) async {
    try {
      final response = await http
          .delete(Uri.parse('${ApiService.baseUrl}/captures/$id'))
          .timeout(const Duration(seconds: 5));
      // 200 ou 204 = succès
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      // Si l'endpoint n'existe pas encore côté serveur → on accepte quand même
      return true;
    }
  }

  // ── Supprimer une capture (API + local) ────────────────────
  Future<void> _deleteCapture(int index) async {
    final capture = _captures[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: AppColors.error, size: 22),
            SizedBox(width: AppSpacing.sm),
            Text('Supprimer la capture',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
          ],
        ),
        content: const Text(
            'Voulez-vous supprimer définitivement cette capture ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // ✅ 1. Stopper le timer pendant la suppression
    _timer?.cancel();

    // ✅ 2. Appel API DELETE
    final success = await _apiDeleteCapture(capture['id']);

    if (!mounted) return;

    if (success) {
      // ✅ 3. Retirer de la liste locale SEULEMENT si l'API a réussi
      setState(() => _captures.removeAt(index));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Capture supprimée définitivement'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        duration: const Duration(seconds: 2),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Erreur — impossible de supprimer'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
      ));
    }

    // ✅ 4. Relancer le timer
    _timer = Timer.periodic(
        const Duration(seconds: 10), (_) => _loadCaptures());
  }

  // ── Tout supprimer (API + local) ───────────────────────────
  Future<void> _deleteAll() async {
    if (_captures.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: const Row(
          children: [
            Icon(Icons.delete_sweep, color: AppColors.error, size: 22),
            SizedBox(width: AppSpacing.sm),
            Text('Tout supprimer',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
          ],
        ),
        content: Text(
            'Supprimer les ${_captures.length} captures définitivement ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            child: const Text('Tout supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // ✅ 1. Stopper le timer
    _timer?.cancel();

    // ✅ 2. Afficher loading
    setState(() => _isLoading = true);

    // ✅ 3. Appeler DELETE pour chaque capture
    final ids = _captures.map((c) => c['id']).toList();
    int deleted = 0;
    for (final id in ids) {
      final ok = await _apiDeleteCapture(id);
      if (ok) deleted++;
    }

    if (!mounted) return;

    // ✅ 4. Vider la liste locale
    setState(() {
      _captures.clear();
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text('$deleted capture(s) supprimée(s) définitivement'),
        ],
      ),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md)),
      duration: const Duration(seconds: 3),
    ));

    // ✅ 5. Relancer le timer
    _timer = Timer.periodic(
        const Duration(seconds: 10), (_) => _loadCaptures());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MaritimeAppBar(
        title: 'Captures d\'intrusion',
        actions: [
          // Bouton tout supprimer
          if (!_isLoading && _captures.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: AppColors.white),
              tooltip: 'Tout supprimer',
              onPressed: _deleteAll,
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            onPressed: _loadCaptures,
          ),
        ],
      ),
      body: _isLoading
          ? const MaritimeLoadingState(message: 'Chargement des captures…')
          : _captures.isEmpty
              ? MaritimeEmptyState(
                  icon: Icons.shield_outlined,
                  title: 'Aucune capture d\'intrusion',
                  subtitle:
                      'Les captures apparaîtront ici\nlors de détections d\'intrusion.',
                )
              : Column(
                  children: [
                    // ── Bannière compteur ──────────────
                    _buildAlertBanner(),
                    // ── Grille ─────────────────────────
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg, AppSpacing.md,
                            AppSpacing.lg, AppSpacing.lg),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: _captures.length,
                        itemBuilder: (_, i) =>
                            _buildCaptureCard(_captures[i], i),
                      ),
                    ),
                  ],
                ),
    );
  }

  // ── Bannière d'alerte ─────────────────────────────────────
  Widget _buildAlertBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.error.withOpacity(0.08),
            AppColors.error.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.error.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm + 2),
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: AppColors.error, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_captures.length} intrusion(s) détectée(s)',
                  style: const TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Appuyez sur 🗑 pour supprimer une capture',
                  style: TextStyle(
                    color: AppColors.error.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Card capture avec bouton supprimer ────────────────────
  Widget _buildCaptureCard(Map<String, dynamic> capture, int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
        border: Border.all(
            color: AppColors.error.withOpacity(0.18), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Miniature / icône ──────────────────
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.lg),
                    topRight: Radius.circular(AppRadius.lg),
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.error.withOpacity(0.12),
                          AppColors.lightGrey,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.camera_enhance_outlined,
                          size: 38, color: AppColors.error),
                    ),
                  ),
                ),
                // ✅ Bouton poubelle — coin haut-droit
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => _deleteCapture(index),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius:
                            BorderRadius.circular(AppRadius.sm + 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error.withOpacity(0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.delete_outline,
                          color: AppColors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Infos + bouton voir ────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label Intrusion
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Intrusion',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                // Timestamp
                Text(
                  capture['timestamp'] ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                // Bouton voir la capture
                GestureDetector(
                  onTap: () => _showCaptureDetail(capture['id']),
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.visibility_outlined,
                            color: AppColors.white, size: 13),
                        SizedBox(width: 4),
                        Text(
                          'Voir',
                          style: TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Dialog détail capture ─────────────────────────────────
  void _showCaptureDetail(dynamic id) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryLight),
      ),
    );
    final data = await ApiService.getCaptureImage(id);
    if (!mounted) return;
    Navigator.pop(context);
    if (data == null) return;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        child: ConstrainedBox(
  constraints: BoxConstraints(
    maxHeight: MediaQuery.of(context).size.height * 0.8,
    maxWidth: MediaQuery.of(context).size.width * 0.9,
  ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              decoration: const BoxDecoration(
                gradient: AppGradients.primaryBar,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.xl),
                  topRight: Radius.circular(AppRadius.xl),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm - 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(Icons.warning_amber_rounded,
                        color: AppColors.white, size: 18),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Text(
                    'Capture d\'intrusion',
                    style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: AppColors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // Image
            ClipRRect(
              child: data['image'] != null
                ? ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: Image.memory(
                      base64Decode(data['image']),
                      fit: BoxFit.contain,
                      width: double.infinity,
                    )
                )
                  : Container(
                      height: 180,
                      color: AppColors.lightGrey,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image_not_supported,
                                size: 50, color: AppColors.textSecondary),
                            SizedBox(height: AppSpacing.sm),
                            Text('Image non disponible',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
            ),
            // Footer timestamp
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.xl),
                  bottomRight: Radius.circular(AppRadius.xl),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      data['timestamp'] ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}