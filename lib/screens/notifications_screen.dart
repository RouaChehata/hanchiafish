import 'package:flutter/material.dart';
import 'package:primaa/api_service.dart';
import 'app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _alertes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlertes();
  }

  Future<void> _loadAlertes() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getAlertes();
    setState(() {
      _alertes = data;
      _isLoading = false;
    });
  }

  /// Choisit icône + couleur selon le type d'alerte
  _AlertStyle _styleFor(String type) {
    switch (type) {
      case 'Intrusion détectée':
        return _AlertStyle(Icons.warning_amber_rounded, AppColors.error);
      case 'Entrée au port':
        return _AlertStyle(Icons.anchor, AppColors.warning);
      case 'Sortie du port':
        return _AlertStyle(Icons.sailing, AppColors.primaryLight);
      case 'Mode Sécurité':
        return _AlertStyle(Icons.security, AppColors.primary);
      default:
        return _AlertStyle(Icons.notifications, AppColors.info);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MaritimeAppBar(
        title: 'Notifications',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            onPressed: _loadAlertes,
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const MaritimeLoadingState(message: 'Chargement des alertes…')
          : _alertes.isEmpty
          ? MaritimeEmptyState(
              icon: Icons.notifications_outlined,
              title: 'Aucune notification',
              subtitle: 'Vous n\'avez pas de nouvelles alertes',
            )
          : RefreshIndicator(
              onRefresh: _loadAlertes,
              color: AppColors.primaryLight,
              child: ListView.builder(
                padding: EdgeInsets.all(AppSpacing.lg),
                itemCount: _alertes.length,
                itemBuilder: (_, i) {
                  final a = _alertes[i];
                  final style = _styleFor(a['type'] ?? '');
                  return _buildCard(
                    title: a['type'] ?? 'Alerte',
                    message: a['message'] ?? '',
                    time: a['timestamp'] ?? '',
                    style: style,
                  );
                },
              ),
            ),
    );
  }

  Widget _buildCard({
    required String title,
    required String message,
    required String time,
    required _AlertStyle style,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: style.color.withOpacity(0.25), width: 1.5),
        boxShadow: AppShadows.subtle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: style.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: style.color.withOpacity(0.3)),
                  ),
                  child: Icon(style.icon, color: style.color, size: 22),
                ),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          MaritimeBadge(
                            label: 'Nouveau',
                            color: style.color,
                            filled: false,
                          ),
                        ],
                      ),
                      if (message.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          message,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                      SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            time,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                          ),
                        ],
                      ),
                    ],
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

class _AlertStyle {
  final IconData icon;
  final Color color;
  const _AlertStyle(this.icon, this.color);
}
