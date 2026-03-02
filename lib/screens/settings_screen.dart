import 'package:flutter/material.dart';

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
  int _refreshInterval = 30; // secondes
  String _selectedLanguage = 'Français';
  String _selectedTheme = 'Clair';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Paramètres',
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
            // En-tête avec avatar
            _buildHeader(),
            // Liste des paramètres
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSectionTitle('Notifications'),
                    _buildSwitchTile(
                      'Activer les notifications',
                      'Recevoir des alertes sur les bateaux',
                      _notificationsEnabled,
                      Icons.notifications,
                      (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                    _buildSwitchTile(
                      'Son',
                      'Activer les sons de notification',
                      _soundEnabled,
                      Icons.volume_up,
                      (value) {
                        setState(() {
                          _soundEnabled = value;
                        });
                      },
                    ),
                    _buildSwitchTile(
                      'Vibration',
                      'Activer les vibrations',
                      _vibrationEnabled,
                      Icons.vibration,
                      (value) {
                        setState(() {
                          _vibrationEnabled = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildSectionTitle('Actualisation'),
                    _buildSwitchTile(
                      'Actualisation automatique',
                      'Mettre à jour les données automatiquement',
                      _autoRefreshEnabled,
                      Icons.refresh,
                      (value) {
                        setState(() {
                          _autoRefreshEnabled = value;
                        });
                      },
                    ),
                    if (_autoRefreshEnabled)
                      _buildSliderTile(
                        'Intervalle d\'actualisation',
                        '${_refreshInterval}s',
                        _refreshInterval.toDouble(),
                        10,
                        60,
                        Icons.timer,
                        (value) {
                          setState(() {
                            _refreshInterval = value.toInt();
                          });
                        },
                      ),
                    const SizedBox(height: 8),
                    _buildSectionTitle('Préférences'),
                    _buildListTile(
                      'Langue',
                      _selectedLanguage,
                      Icons.language,
                      () {
                        _showLanguageDialog();
                      },
                    ),
                    _buildListTile(
                      'Thème',
                      _selectedTheme,
                      Icons.palette,
                      () {
                        _showThemeDialog();
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildSectionTitle('Compte'),
                    _buildListTile(
                      'Profil',
                      'Modifier les informations du profil',
                      Icons.person,
                      () {
                        // Navigation vers le profil
                      },
                    ),
                    _buildListTile(
                      'Sécurité',
                      'Mot de passe et authentification',
                      Icons.lock,
                      () {
                        // Navigation vers la sécurité
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildSectionTitle('À propos'),
                    _buildListTile(
                      'Version',
                      '1.0.0',
                      Icons.info,
                      null,
                    ),
                    _buildListTile(
                      'Conditions d\'utilisation',
                      'Lire les conditions',
                      Icons.description,
                      () {
                        // Afficher les conditions
                      },
                    ),
                    _buildListTile(
                      'Politique de confidentialité',
                      'Lire la politique',
                      Icons.privacy_tip,
                      () {
                        // Afficher la politique
                      },
                    ),
                    _buildListTile(
                      'Support',
                      'Contacter le support',
                      Icons.support_agent,
                      () {
                        // Ouvrir le support
                      },
                    ),
                    const SizedBox(height: 24),
                    // Bouton de déconnexion
                    _buildLogoutButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 60,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Utilisateur',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'user@hanchiafish.com',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E3A8A),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    IconData icon,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1E3A8A),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF1E3A8A),
        ),
      ),
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1E3A8A),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: onTap != null
            ? const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String value,
    double currentValue,
    double min,
    double max,
    IconData icon,
    ValueChanged<double> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF1E3A8A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: currentValue,
            min: min,
            max: max,
            divisions: ((max - min) / 10).toInt(),
            activeColor: const Color(0xFF1E3A8A),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          _showLogoutDialog();
        },
        icon: const Icon(Icons.logout),
        label: const Text(
          'Déconnexion',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('Français', '🇫🇷'),
            _buildLanguageOption('English', '🇬🇧'),
            _buildLanguageOption('العربية', '🇲🇦'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language, String flag) {
    return ListTile(
      leading: Text(
        flag,
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(language),
      trailing: _selectedLanguage == language
          ? const Icon(Icons.check, color: Color(0xFF1E3A8A))
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner le thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('Clair', Icons.light_mode),
            _buildThemeOption('Sombre', Icons.dark_mode),
            _buildThemeOption('Automatique', Icons.brightness_auto),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String theme, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1E3A8A)),
      title: Text(theme),
      trailing: _selectedTheme == theme
          ? const Icon(Icons.check, color: Color(0xFF1E3A8A))
          : null,
      onTap: () {
        setState(() {
          _selectedTheme = theme;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              // Ici vous pouvez ajouter la logique de déconnexion
              // Par exemple : FirebaseAuth.instance.signOut();
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