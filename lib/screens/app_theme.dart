//  app_theme.dart — Design System Maritime Partagé
//  Importez ce fichier dans TOUS vos écrans.
//  Ne définissez plus jamais AppColors, AppTextStyles, etc. ailleurs.
// ════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  COULEURS CENTRALES
// ─────────────────────────────────────────────
class AppColors {
  // Bleus — palette maritime premium
  static const Color primary = Color(0xFF0A3D6B);
  static const Color primaryLight = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF062B4A);
  static const Color accent = Color(0xFF1E88E5);
  static const Color accentLight = Color(0xFF64B5F6);
  static const Color surface = Color(0xFFE3F2FD);
  static const Color surfaceLight = Color(0xFFF0F7FF);

  // Neutres
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F8FC);
  static const Color lightGrey = Color(0xFFECF1F7);
  static const Color border = Color(0xFFDDE4EE);
  static const Color borderLight = Color(0xFFE8EDF4);
  static const Color textSecondary = Color(0xFF90A4AE);
  static const Color textPrimary = Color(0xFF37474F);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Sémantiques
  static const Color success = Color(0xFF26A69A);
  static const Color successLight = Color(0xFF4DB6AC);
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFCC02);
  static const Color error = Color(0xFFEF5350);
  static const Color errorLight = Color(0xFFEF9A9A);
  static const Color info = Color(0xFF00ACC1);

  // Caméra
  static const Color cameraActive = Color(0xFF26A69A);
  static const Color cameraInactive = Color(0xFF90A4AE);

  // Status bateaux
  static const Color statusAtSea = Color(0xFF26A69A);
  static const Color statusAtPort = Color(0xFFFFA726);
  static const Color statusMaintenance = Color(0xFFEF5350);
  static const Color statusInactive = Color(0xFF90A4AE);
}

// ─────────────────────────────────────────────
//  ESPACEMENT
// ─────────────────────────────────────────────
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;
}

// ─────────────────────────────────────────────
//  BORDER RADIUS
// ─────────────────────────────────────────────
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double round = 100.0;
}

// ─────────────────────────────────────────────
//  GRADIENTS
// ─────────────────────────────────────────────
class AppGradients {
  static const LinearGradient primaryBar = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryLight],
  );

  static const LinearGradient cardHeader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.accent],
  );

  static const LinearGradient bodyBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.primary, AppColors.primaryLight, AppColors.background],
    stops: [0.0, 0.25, 1.0],
  );

  static const LinearGradient accentBar = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.primaryLight, AppColors.accent],
  );

  static const LinearGradient successBar = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.success, AppColors.successLight],
  );

  static const LinearGradient darkOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Colors.black54],
  );

  static const LinearGradient shimmer = LinearGradient(
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    colors: [
      Color(0xFFEBEBF4),
      Color(0xFFF4F4F4),
      Color(0xFFEBEBF4),
    ],
  );
}

// ─────────────────────────────────────────────
//  SHADOWS
// ─────────────────────────────────────────────
class AppShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevated = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> subtle = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// Deep shadow with layered effect for premium cards
  static List<BoxShadow> premium = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: AppColors.primaryLight.withOpacity(0.06),
      blurRadius: 40,
      offset: const Offset(0, 16),
    ),
  ];

  /// Colored glow shadow
  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.25),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: color.withOpacity(0.08),
      blurRadius: 40,
      offset: const Offset(0, 12),
    ),
  ];
}

// ─────────────────────────────────────────────
//  ANIMATION DURATIONS
// ─────────────────────────────────────────────
class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration stagger = Duration(milliseconds: 100);
}

// ════════════════════════════════════════════════════════════════
//  WIDGETS PARTAGÉS
// ════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────
//  MaritimeAppBar
//  Remplace les 8 AppBar gradient identiques.
//  Usage : appBar: MaritimeAppBar(title: 'Mon écran', actions: [...])
// ─────────────────────────────────────────────
class MaritimeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final double toolbarHeight;

  const MaritimeAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.toolbarHeight = 60,
  });

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: toolbarHeight,
      leading: leading,
      iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppGradients.primaryBar),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textOnPrimary,
          letterSpacing: 0.2,
        ),
      ),
      actions: actions,
    );
  }
}

// ─────────────────────────────────────────────
//  MaritimeScaffold
//  Scaffold avec fond dégradé + content card arrondie en bas.
//  Usage : return MaritimeScaffold(appBar: ..., child: ...)
// ─────────────────────────────────────────────
class MaritimeScaffold extends StatelessWidget {
  final PreferredSizeWidget appBar;
  final Widget child;
  final Widget? headerContent; // widgets entre l'AppBar et la card blanche
  final FloatingActionButton? floatingActionButton;

  const MaritimeScaffold({
    super.key,
    required this.appBar,
    required this.child,
    this.headerContent,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.bodyBackground),
        child: Column(
          children: [
            if (headerContent != null) headerContent!,
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: headerContent != null ? 12 : 20),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.xxl),
                    topRight: Radius.circular(AppRadius.xxl),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.xxl),
                    topRight: Radius.circular(AppRadius.xxl),
                  ),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MaritimeSectionTitle
//  Titre de section avec badge optionnel.
//  Usage : MaritimeSectionTitle(title: 'Caméras Actives', badge: '3 actives', badgeColor: AppColors.success)
// ─────────────────────────────────────────────
class MaritimeSectionTitle extends StatelessWidget {
  final String title;
  final String? badge;
  final Color? badgeColor;
  final EdgeInsets padding;

  const MaritimeSectionTitle({
    super.key,
    required this.title,
    this.badge,
    this.badgeColor,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.xl,
      vertical: AppSpacing.lg,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (badge != null)
            MaritimeBadge(
              label: badge!,
              color: badgeColor ?? AppColors.primaryLight,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MaritimeBadge
//  Pastille colorée réutilisable.
//  Usage : MaritimeBadge(label: 'EN DIRECT', color: AppColors.success)
// ─────────────────────────────────────────────
class MaritimeBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool
  filled; // true = fond coloré, false = fond transparent avec texte coloré

  const MaritimeBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm - 2,
      ),
      decoration: BoxDecoration(
        color: filled ? color : color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.round),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: filled ? AppColors.white : color),
            SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: filled ? AppColors.white : color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MaritimeStatCard
//  Carte de stat avec icône + valeur + label.
//  Usage : MaritimeStatCard(icon: Icons.videocam, value: '4', label: 'Actives', color: AppColors.success)
// ─────────────────────────────────────────────
class MaritimeStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final String? subtitle;

  const MaritimeStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm + 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 2),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MaritimeInfoRow
//  Ligne icône + label + valeur (settings, stats, map info card).
//  Usage : MaritimeInfoRow(icon: Icons.radar, label: 'Rayon', value: '500 m')
// ─────────────────────────────────────────────
class MaritimeInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final bool showDivider;

  const MaritimeInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: AppSpacing.sm),
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppShadows.subtle,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primaryLight).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.primaryLight,
                  size: 20,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  MaritimeAlertRow
//  Ligne d'alerte avec compteur coloré.
//  Usage : MaritimeAlertRow(title: 'Intrusions', count: 2, icon: Icons.warning, color: AppColors.error)
// ─────────────────────────────────────────────
class MaritimeAlertRow extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const MaritimeAlertRow({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm + 2),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm - 2,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.round),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MaritimeGradientHeader
//  Bannière gradient en haut de page (dashboard, stats…)
//  Usage : MaritimeGradientHeader(title: 'Tableau de bord', subtitle: 'Vue d\'ensemble')
// ─────────────────────────────────────────────
class MaritimeGradientHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const MaritimeGradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppGradients.cardHeader,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.elevated,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MaritimeStatusColor — helper statique
//  Usage : MaritimeStatusColor.fromStatus('En mer') → Color
// ─────────────────────────────────────────────
class MaritimeStatusColor {
  static Color fromStatus(String status) {
    switch (status) {
      case 'En mer':
        return AppColors.statusAtSea;
      case 'Au port':
        return AppColors.statusAtPort;
      case 'En maintenance':
        return AppColors.statusMaintenance;
      default:
        return AppColors.statusInactive;
    }
  }
}

// ─────────────────────────────────────────────
//  MaritimeLoadingState — état de chargement uniforme
// ─────────────────────────────────────────────
class MaritimeLoadingState extends StatelessWidget {
  final String? message;
  const MaritimeLoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primaryLight,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            SizedBox(height: AppSpacing.lg),
            Text(
              message!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MaritimeEmptyState — état vide uniforme
// ─────────────────────────────────────────────
class MaritimeEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const MaritimeEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primaryLight),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[SizedBox(height: AppSpacing.xl), action!],
          ],
        ),
      ),
    );
  }
}
