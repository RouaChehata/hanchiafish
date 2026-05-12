import 'package:flutter/material.dart';
import 'package:primaa/api_service.dart';
import 'app theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isLoading = true;
  int _totalPositions   = 0;
  int _totalAlertes     = 0;
  int _alertesPort      = 0;
  int _alertesSortie    = 0;
  int _alertesSecurite  = 0;
  int _alertesIntrusion = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final history = await ApiService.getGpsHistory();
    final alertes = await ApiService.getAlertes();
    setState(() {
      _totalPositions   = history.length;
      _totalAlertes     = alertes.length;
      _alertesPort      = alertes.where((a) => a['type'] == 'Entrée au port').length;
      _alertesSortie    = alertes.where((a) => a['type'] == 'Sortie du port').length;
      _alertesSecurite  = alertes.where((a) => a['type'] == 'Mode Sécurité').length;
      _alertesIntrusion = alertes.where((a) => a['type'] == 'Intrusion détectée').length;
      _isLoading        = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MaritimeAppBar(
        title: 'Statistiques',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            onPressed: _loadStats,
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const MaritimeLoadingState(message: 'Chargement des statistiques…')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Bannière ─────────────────────────
                  MaritimeGradientHeader(
                    title: 'Tableau de bord',
                    subtitle: 'Vue d\'ensemble du système',
                    trailing: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(Icons.bar_chart_rounded,
                          color: AppColors.white, size: 28),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Données GPS ───────────────────────
                  Text('Données GPS',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: MaritimeStatCard(
                          icon: Icons.location_on,
                          value: '$_totalPositions',
                          label: 'Positions enregistrées',
                          color: AppColors.primaryLight,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: MaritimeStatCard(
                          icon: Icons.notifications,
                          value: '$_totalAlertes',
                          label: 'Total alertes',
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Détail des alertes ────────────────
                  Text('Détail des alertes',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.md),
                  MaritimeAlertRow(
                      title: 'Entrées au port',
                      count: _alertesPort,
                      icon: Icons.anchor,
                      color: AppColors.warning),
                  MaritimeAlertRow(
                      title: 'Sorties du port',
                      count: _alertesSortie,
                      icon: Icons.sailing,
                      color: AppColors.primaryLight),
                  MaritimeAlertRow(
                      title: 'Mode sécurité activé',
                      count: _alertesSecurite,
                      icon: Icons.security,
                      color: AppColors.primary),
                  MaritimeAlertRow(
                      title: 'Intrusions détectées',
                      count: _alertesIntrusion,
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.error),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Système ───────────────────────────
                  Text('Système',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.md),
                  MaritimeInfoRow(
                      icon: Icons.location_city,
                      label: 'Port surveillé',
                      value: 'Port de Teboulba'),
                  MaritimeInfoRow(
                      icon: Icons.access_time,
                      label: 'Mode sécurité',
                      value: 'Activé après 18h00'),
                  MaritimeInfoRow(
                      icon: Icons.radar,
                      label: 'Rayon geofencing',
                      value: '500 mètres'),
                  MaritimeInfoRow(
                      icon: Icons.gps_fixed,
                      label: 'Mise à jour GPS',
                      value: 'Toutes les 5 sec',
                      showDivider: false),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
    );
  }
}