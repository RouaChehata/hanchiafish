import 'package:flutter/material.dart';
import 'package:primaa/models/boat_model.dart';
import 'package:primaa/screens/app_theme.dart';

class AddBoatDialog extends StatefulWidget {
  final Function(Boat) onAddBoat;
  const AddBoatDialog({super.key, required this.onAddBoat});

  @override
  State<AddBoatDialog> createState() => _AddBoatDialogState();
}

class _AddBoatDialogState extends State<AddBoatDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _speedCtrl = TextEditingController();
  final _crewCtrl = TextEditingController();

  String _selectedStatus = 'Au port';
  bool _cameraActive = false;
  int _step = 0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _speedCtrl.dispose();
    _crewCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(String s) => MaritimeStatusColor.fromStatus(s);
  IconData _statusIcon(String s) {
    switch (s) {
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          boxShadow: AppShadows.elevated,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildStepper(),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: Form(key: _formKey, child: _buildCurrentStep()),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titles = ['Informations navire', 'Géolocalisation', 'Équipage & Vision IA'];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryBar,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xxl),
          topRight: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(Icons.add_to_photos_rounded, color: AppColors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nouveau Navire',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  titles[_step],
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: AppColors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white10,
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.03),
        border: Border(bottom: BorderSide(color: AppColors.borderLight.withOpacity(0.5))),
      ),
      child: Row(
        children: List.generate(5, (i) {
          if (i.isOdd) {
            final idx = i ~/ 2;
            return Expanded(
              child: AnimatedContainer(
                duration: AppDurations.normal,
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: idx < _step ? AppColors.primary : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }
          final idx = i ~/ 2;
          final isDone = idx < _step;
          final isCurrent = idx == _step;
          return AnimatedContainer(
            duration: AppDurations.normal,
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDone || isCurrent ? AppColors.primary : AppColors.white,
              shape: BoxShape.circle,
              boxShadow: isCurrent ? AppShadows.subtle : null,
              border: Border.all(
                color: isDone || isCurrent ? AppColors.primary : AppColors.border,
                width: 2,
              ),
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check_rounded, color: AppColors.white, size: 18)
                  : Text(
                      '${idx + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isCurrent ? AppColors.white : AppColors.textSecondary,
                      ),
                    ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _stepInfo();
      case 1:
        return _stepGps();
      default:
        return _stepCrew();
    }
  }

  Widget _stepInfo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _premiumLabel('Désignation du navire'),
      _premiumField(
        ctrl: _nameCtrl,
        hint: 'Ex: Hanchia 002',
        icon: Icons.sailing_rounded,
        validator: (v) => (v == null || v.isEmpty) ? 'Le nom est obligatoire' : null,
      ),
      const SizedBox(height: 24),
      _premiumLabel('Statut opérationnel'),
      Row(
        children: ['En mer', 'Au port', 'En maintenance'].map((s) {
          final isSel = _selectedStatus == s;
          final color = _statusColor(s);
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedStatus = s),
              child: AnimatedContainer(
                duration: AppDurations.normal,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSel ? color : AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: isSel ? AppShadows.subtle : null,
                  border: Border.all(
                    color: isSel ? color : AppColors.borderLight,
                    width: isSel ? 2 : 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(_statusIcon(s), size: 22, color: isSel ? AppColors.white : color),
                    const SizedBox(height: 8),
                    Text(
                      s,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isSel ? AppColors.white : AppColors.textPrimary,
                        letterSpacing: 0.5,
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
  );

  Widget _stepGps() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _premiumLabel('Coordonnées Latitude'),
      _premiumField(
        ctrl: _latCtrl,
        hint: '35.6620',
        icon: Icons.north_rounded,
        isNum: true,
      ),
      const SizedBox(height: 20),
      _premiumLabel('Coordonnées Longitude'),
      _premiumField(
        ctrl: _lngCtrl,
        hint: '10.9581',
        icon: Icons.east_rounded,
        isNum: true,
      ),
      const SizedBox(height: 20),
      _premiumLabel('Vitesse cible (kn)'),
      _premiumField(
        ctrl: _speedCtrl,
        hint: '12.5',
        icon: Icons.speed_rounded,
        isNum: true,
      ),
    ],
  );

  Widget _stepCrew() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _premiumLabel('Membres d\'équipage à bord'),
      _premiumField(
        ctrl: _crewCtrl,
        hint: 'Nombre',
        icon: Icons.group_rounded,
        isNum: true,
      ),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.04),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cameraActive ? AppColors.success : AppColors.textSecondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _cameraActive ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                color: _cameraActive ? AppColors.white : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vision IA & Surveillance',
                    style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 15),
                  ),
                  Text(
                    _cameraActive ? 'Détection active' : 'Système hors-ligne',
                    style: TextStyle(fontSize: 12, color: _cameraActive ? AppColors.success : AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: _cameraActive,
              activeColor: AppColors.success,
              onChanged: (v) => setState(() => _cameraActive = v),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.borderLight.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step--),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  side: const BorderSide(color: AppColors.border, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                ),
                child: const Text('PRÉCÉDENT', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _step < 2 ? _next : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _step == 2 ? AppColors.success : AppColors.primary,
                minimumSize: const Size(0, 56),
                elevation: 4,
                shadowColor: (_step == 2 ? AppColors.success : AppColors.primary).withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
              ),
              child: Text(
                _step == 2 ? 'FINALISER L\'AJOUT' : 'ÉTAPE SUIVANTE',
                style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _premiumLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10, left: 4),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _premiumField({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    bool isNum = false,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: ctrl,
    keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
    validator: validator ?? (v) => (v == null || v.isEmpty) ? 'Requis' : null,
    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primaryLight, size: 22),
      filled: true,
      fillColor: AppColors.primary.withOpacity(0.02),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.borderLight, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.borderLight, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    ),
  );

  void _next() {
    if (_formKey.currentState!.validate()) setState(() => _step++);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final boat = Boat(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameCtrl.text.trim(),
        status: _selectedStatus,
        latitude: double.parse(_latCtrl.text),
        longitude: double.parse(_lngCtrl.text),
        speed: double.parse(_speedCtrl.text),
        lastUpdate: "À l'instant",
        imageUrl: 'images/cage.png',
        cameraActive: _cameraActive,
        crewMembers: int.parse(_crewCtrl.text),
      );
      widget.onAddBoat(boat);
      Navigator.of(context).pop();
    }
  }
}
