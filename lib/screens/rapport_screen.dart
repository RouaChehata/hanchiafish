import 'package:flutter/material.dart';
import '../../models/boat_model.dart';
import '../../services/groq_service.dart';
import '../screens/app_theme.dart';

class RapportScreen extends StatefulWidget {
  final Boat? selectedBoat;
  const RapportScreen({super.key, this.selectedBoat});

  @override
  State<RapportScreen> createState() => _RapportScreenState();
}

class _RapportScreenState extends State<RapportScreen> {
  final _groq = GroqService();
  Boat? _selectedBoat;
  String? _report;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedBoat = widget.selectedBoat ?? Boat.getDemoBoats().first;
  }

  Future<void> _generate() async {
    if (_selectedBoat == null) return;
    setState(() {
      _loading = true;
      _error = null;
      _report = null;
    });
    try {
      final result = await _groq.generateReport(_selectedBoat!);
      setState(() => _report = result);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MaritimeAppBar(title: 'Rapport IA'),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Bannière ─────────────────────────
            MaritimeGradientHeader(
              title: 'Rapport IA',
              subtitle: 'Génération automatique via IA',
              trailing: Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.white,
                  size: 26,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xl),

            // ── Info bateau ───────────────────────
            if (_selectedBoat != null) ...[
              MaritimeInfoRow(
                icon: Icons.directions_boat,
                label: 'Bateau sélectionné',
                value: _selectedBoat!.name,
                iconColor: AppColors.primaryLight,
              ),
              SizedBox(height: AppSpacing.xl),
            ],

            // ── Bouton génération ─────────────────
            ElevatedButton.icon(
              onPressed: _loading ? null : _generate,
              icon: _loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                _loading ? 'Génération en cours…' : 'Générer le Rapport',
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              ),
            ),
            SizedBox(height: AppSpacing.xl),

            // ── Erreur ────────────────────────────
            if (_error != null)
              Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Rapport généré ────────────────────
            if (_report != null) ...[
              Container(
                padding: EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          color: AppColors.primaryLight,
                          size: 20,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Rapport généré',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                    const Divider(height: AppSpacing.xl),
                    Text(
                      _report!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
