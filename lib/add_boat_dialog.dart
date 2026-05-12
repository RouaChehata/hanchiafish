import 'package:flutter/material.dart';
import 'package:primaa/models/boat_model.dart';
import 'package:primaa/screens/app theme.dart';

class AddBoatDialog extends StatefulWidget {
  final Function(Boat) onAddBoat;
  const AddBoatDialog({super.key, required this.onAddBoat});

  @override
  State<AddBoatDialog> createState() => _AddBoatDialogState();
}

class _AddBoatDialogState extends State<AddBoatDialog> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _latCtrl   = TextEditingController();
  final _lngCtrl   = TextEditingController();
  final _speedCtrl = TextEditingController();
  final _crewCtrl  = TextEditingController();

  String _selectedStatus = 'Au port';
  bool   _cameraActive   = false;
  int    _step           = 0;

  @override
  void dispose() {
    _nameCtrl.dispose(); _latCtrl.dispose(); _lngCtrl.dispose();
    _speedCtrl.dispose(); _crewCtrl.dispose();
    super.dispose();
  }

  Color    _statusColor(String s) => MaritimeStatusColor.fromStatus(s);
  IconData _statusIcon(String s) {
    switch (s) {
      case 'En mer':         return Icons.water;
      case 'Au port':        return Icons.anchor;
      case 'En maintenance': return Icons.build;
      default:               return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
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
    final titles = ['Informations', 'Position GPS', 'Équipage & Caméra'];
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryBar,
        borderRadius: BorderRadius.only(
          topLeft:  Radius.circular(AppRadius.xxl),
          topRight: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.directions_boat_filled,
                color: AppColors.white, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ajouter un bateau',
                    style: TextStyle(color: AppColors.white,
                        fontSize: 17, fontWeight: FontWeight.w700)),
                Text(titles[_step],
                    style: TextStyle(
                        color: AppColors.white.withOpacity(0.75),
                        fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppRadius.round),
            ),
            child: Text('${_step + 1} / 3',
                style: const TextStyle(color: AppColors.white,
                    fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(5, (i) {
          if (i.isOdd) {
            final idx = i ~/ 2;
            return Expanded(
              child: Container(height: 2,
                  color: idx < _step ? AppColors.primary : AppColors.border),
            );
          }
          final idx    = i ~/ 2;
          final done   = idx < _step;
          final active = idx == _step;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 32, height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done
                  ? AppColors.success
                  : active ? AppColors.primary : AppColors.lightGrey,
            ),
            child: Center(
              child: done
                  ? const Icon(Icons.check, color: AppColors.white, size: 16)
                  : Text('${idx + 1}',
                      style: TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: active
                              ? AppColors.white : AppColors.textSecondary)),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:  return _step0();
      case 1:  return _step1();
      default: return _step2();
    }
  }

  Widget _step0() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('Nom du bateau', required: true),
      _field(ctrl: _nameCtrl, hint: 'Ex: Hanchia 2',
          icon: Icons.directions_boat,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Champ requis' : null),
      const SizedBox(height: AppSpacing.xl),
      _label('Statut initial'),
      const SizedBox(height: AppSpacing.sm),
      Row(
        children: ['En mer', 'Au port', 'En maintenance'].map((s) {
          final sel = _selectedStatus == s;
          final c   = _statusColor(s);
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedStatus = s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                decoration: BoxDecoration(
                  color: sel ? c.withOpacity(0.1) : AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                      color: sel ? c : AppColors.border,
                      width: sel ? 2 : 1),
                ),
                child: Column(
                  children: [
                    Icon(_statusIcon(s), size: 20,
                        color: sel ? c : AppColors.textSecondary),
                    const SizedBox(height: 4),
                    Text(s, textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10,
                            fontWeight:
                                sel ? FontWeight.w700 : FontWeight.w400,
                            color: sel ? c : AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: AppSpacing.sm),
    ],
  );

  Widget _step1() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
              color: AppColors.primaryLight.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline,
                color: AppColors.primaryLight, size: 15),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text('Port de Teboulba : 35.6620, 10.9581',
                  style: TextStyle(color: AppColors.primaryLight,
                      fontSize: 11, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      _label('Latitude', required: true),
      _field(ctrl: _latCtrl, hint: '35.6620', icon: Icons.explore,
          keyboard: TextInputType.number,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Requis';
            if (double.tryParse(v) == null) return 'Nombre invalide';
            return null;
          }),
      const SizedBox(height: AppSpacing.lg),
      _label('Longitude', required: true),
      _field(ctrl: _lngCtrl, hint: '10.9581',
          icon: Icons.compass_calibration,
          keyboard: TextInputType.number,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Requis';
            if (double.tryParse(v) == null) return 'Nombre invalide';
            return null;
          }),
      const SizedBox(height: AppSpacing.sm),
    ],
  );

  Widget _step2() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('Vitesse initiale (nœuds)', required: true),
      _field(ctrl: _speedCtrl, hint: '0.0', icon: Icons.speed,
          keyboard: TextInputType.number,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Requis';
            if (double.tryParse(v) == null) return 'Nombre invalide';
            return null;
          }),
      const SizedBox(height: AppSpacing.lg),
      _label("Membres d'équipage", required: true),
      _field(ctrl: _crewCtrl, hint: '4', icon: Icons.people,
          keyboard: TextInputType.number,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Requis';
            if (int.tryParse(v) == null) return 'Entier requis';
            return null;
          }),
      const SizedBox(height: AppSpacing.xl),
      GestureDetector(
        onTap: () => setState(() => _cameraActive = !_cameraActive),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: _cameraActive
                ? AppColors.success.withOpacity(0.07)
                : AppColors.lightGrey,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
                color: _cameraActive
                    ? AppColors.success.withOpacity(0.4)
                    : AppColors.border,
                width: _cameraActive ? 2 : 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: _cameraActive
                      ? AppColors.success.withOpacity(0.15)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                ),
                child: Icon(
                  _cameraActive ? Icons.videocam : Icons.videocam_off,
                  color: _cameraActive
                      ? AppColors.success : AppColors.textSecondary,
                  size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Caméra de surveillance',
                        style: TextStyle(fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _cameraActive
                                ? AppColors.success : AppColors.textPrimary)),
                    Text(_cameraActive ? 'Activée' : 'Désactivée',
                        style: TextStyle(fontSize: 12,
                            color: _cameraActive
                                ? AppColors.success : AppColors.textSecondary)),
                  ],
                ),
              ),
              Switch(
                value: _cameraActive,
                onChanged: (v) => setState(() => _cameraActive = v),
                activeColor: AppColors.success,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
    ],
  );

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Row(
        children: [
          Expanded(
            child: _step == 0
                ? OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annuler'))
                : OutlinedButton.icon(
                    onPressed: () => setState(() => _step--),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 13),
                    label: const Text('Précédent')),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _step < 2 ? _next : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _step == 2 ? AppColors.success : AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_step == 2 ? 'Ajouter le bateau' : 'Suivant',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  Icon(_step == 2
                      ? Icons.check_circle_outline
                      : Icons.arrow_forward_ios, size: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, {bool required = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Text(text, style: const TextStyle(fontSize: 13,
          fontWeight: FontWeight.w600, color: AppColors.primary)),
      if (required)
        const Text(' *', style: TextStyle(color: AppColors.error)),
    ]),
  );

  Widget _field({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primaryLight, size: 20),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide:
                  const BorderSide(color: AppColors.border, width: 1.5)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                  color: AppColors.primaryLight, width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide:
                  const BorderSide(color: AppColors.error, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );

  void _next() {
    if (_formKey.currentState!.validate()) setState(() => _step++);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final boat = Boat(
        id:           DateTime.now().millisecondsSinceEpoch.toString(),
        name:         _nameCtrl.text.trim(),
        status:       _selectedStatus,
        latitude:     double.parse(_latCtrl.text),
        longitude:    double.parse(_lngCtrl.text),
        speed:        double.parse(_speedCtrl.text),
        lastUpdate:   "Ajouté à l'instant",
        imageUrl:     'images/téléchargement.png',
        cameraActive: _cameraActive,
        crewMembers:  int.parse(_crewCtrl.text),
      );
      widget.onAddBoat(boat);
      Navigator.of(context).pop();
    }
  }
}