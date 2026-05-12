import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:primaa/loginScreen.dart';
import 'app theme.dart';

// ════════════════════════════════════════════════════════════════
//  NOTIFIERS GLOBAUX — à importer dans main.dart
//  Ces deux objets contrôlent le thème et la langue de toute l'app.
//  Dans main.dart, enveloppez MaterialApp avec ValueListenableBuilder
//  (voir commentaire en bas de ce fichier).
// ════════════════════════════════════════════════════════════════
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.light);
final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('fr'));

// ════════════════════════════════════════════════════════════════
//  SettingsScreen
// ════════════════════════════════════════════════════════════════
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _autoRefreshEnabled = true;
  int _refreshInterval = 30;
  String _selectedLanguage = 'Français';
  String _selectedTheme = 'Clair';

  // ── Appliquer le thème ─────────────────────────────────────
  void _applyTheme(String theme) {
    setState(() => _selectedTheme = theme);
    switch (theme) {
      case 'Sombre':
        appThemeMode.value = ThemeMode.dark;
        break;
      case 'Automatique':
        appThemeMode.value = ThemeMode.system;
        break;
      default:
        appThemeMode.value = ThemeMode.light;
    }
  }

  // ── Appliquer la langue ────────────────────────────────────
  void _applyLanguage(String lang) {
    setState(() => _selectedLanguage = lang);
    switch (lang) {
      case 'English':
        appLocale.value = const Locale('en');
        break;
      case 'العربية':
        appLocale.value = const Locale('ar');
        break;
      default:
        appLocale.value = const Locale('fr');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return MaritimeScaffold(
      appBar: const MaritimeAppBar(title: 'Paramètres'),
      headerContent: _buildProfileHeader(user),
      child: ListView(
        padding: EdgeInsets.all(AppSpacing.lg),
        children: [
          // ── Apparence ─────────────────────────
          _sectionTitle('Apparence'),
          _buildThemeSelector(),
          SizedBox(height: AppSpacing.sm),
          _buildLanguageSelector(),

          // ── Notifications ─────────────────────
          _sectionTitle('Notifications'),
          _switchTile(
            icon: Icons.notifications,
            title: 'Activer les notifications',
            subtitle: 'Recevoir des alertes sur les bateaux',
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          _switchTile(
            icon: Icons.volume_up,
            title: 'Son',
            subtitle: 'Activer les sons de notification',
            value: _soundEnabled,
            onChanged: (v) => setState(() => _soundEnabled = v),
          ),
          _switchTile(
            icon: Icons.vibration,
            title: 'Vibration',
            subtitle: 'Activer les vibrations',
            value: _vibrationEnabled,
            onChanged: (v) => setState(() => _vibrationEnabled = v),
          ),

          // ── Actualisation ─────────────────────
          _sectionTitle('Actualisation'),
          _switchTile(
            icon: Icons.refresh,
            title: 'Actualisation automatique',
            subtitle: 'Mettre à jour les données automatiquement',
            value: _autoRefreshEnabled,
            onChanged: (v) => setState(() => _autoRefreshEnabled = v),
          ),
          if (_autoRefreshEnabled)
            _sliderTile(
              icon: Icons.timer,
              title: "Intervalle d'actualisation",
              valueLabel: '${_refreshInterval}s',
              current: _refreshInterval.toDouble(),
              min: 10,
              max: 60,
              onChanged: (v) => setState(() => _refreshInterval = v.toInt()),
            ),

          // ── Compte ────────────────────────────
          _sectionTitle('Compte'),
          _navTile(
            icon: Icons.person,
            title: 'Profil',
            subtitle: 'Modifier les informations du profil',
          ),
          _navTile(
            icon: Icons.lock,
            title: 'Sécurité',
            subtitle: 'Mot de passe et authentification',
          ),

          SizedBox(height: AppSpacing.xxl),
          _logoutButton(),
          SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  // ── Profil header (zone bleue) ─────────────────────────────
  Widget _buildProfileHeader(User? user) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: AppShadows.elevated,
            ),
            child: const Icon(Icons.person, size: 36, color: AppColors.primary),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Administrateur',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  user?.email ?? 'admin@hanchiafish.com',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Sélecteur thème visuel ─────────────────────────────────
  Widget _buildThemeSelector() {
    final themes = [
      ('Clair', Icons.light_mode_outlined, AppColors.warning),
      ('Sombre', Icons.dark_mode_outlined, AppColors.primary),
      ('Automatique', Icons.brightness_auto, AppColors.info),
    ];
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.palette),
              SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thème de l\'application',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Actuellement : $_selectedTheme',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: themes.map((t) {
              final isSelected = _selectedTheme == t.$1;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    _applyTheme(t.$1);
                    _showSnack('Thème : ${t.$1}');
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: 3),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? t.$3.withOpacity(0.1)
                          : AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isSelected ? t.$3 : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          t.$2,
                          color: isSelected ? t.$3 : AppColors.textSecondary,
                          size: 22,
                        ),
                        SizedBox(height: 4),
                        Text(
                          t.$1,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected ? t.$3 : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Sélecteur langue ───────────────────────────────────────
  Widget _buildLanguageSelector() {
    final langs = [
      ('Français', '🇫🇷', const Locale('fr')),
      ('English', '🇬🇧', const Locale('en')),
      ('العربية', '🇹🇳', const Locale('ar')),
    ];
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.language),
              SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Langue',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Actuellement : $_selectedLanguage',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          ...langs.map((l) {
            final isSelected = _selectedLanguage == l.$1;
            return GestureDetector(
              onTap: () {
                _applyLanguage(l.$1);
                _showSnack('Langue changée : ${l.$1}');
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(bottom: AppSpacing.sm),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.06)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(l.$2, style: const TextStyle(fontSize: 22)),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        l.$1,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: AppColors.white,
                          size: 13,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Section title ──────────────────────────────────────────
  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppSpacing.lg,
        bottom: AppSpacing.sm,
        left: 4,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ── Switch tile ────────────────────────────────────────────
  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 4,
        ),
        leading: _iconBox(icon),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ),
    );
  }

  // ── Nav tile ───────────────────────────────────────────────
  Widget _navTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 4,
        ),
        leading: _iconBox(icon),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        trailing: onTap != null
            ? const Icon(Icons.chevron_right, color: AppColors.textSecondary)
            : null,
        onTap: onTap,
      ),
    );
  }

  // ── Slider tile ────────────────────────────────────────────
  Widget _sliderTile({
    required IconData icon,
    required String title,
    required String valueLabel,
    required double current,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(icon),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      valueLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Slider(
            value: current,
            min: min,
            max: max,
            activeColor: AppColors.primary,
            divisions: ((max - min) / 10).toInt(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ── Logout button ──────────────────────────────────────────
  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showLogoutDialog,
        icon: const Icon(Icons.logout),
        label: const Text(
          'Déconnexion',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm + 2),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutDialog() {
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
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
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
                  MaterialPageRoute(builder: (_) => const Login()),
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
  }
}
