import 'package:flutter/material.dart';
import 'package:primaa/models/boat_model.dart';

class AddBoatDialog extends StatefulWidget {
  final Function(Boat) onAddBoat;

  const AddBoatDialog({super.key, required this.onAddBoat});

  @override
  State<AddBoatDialog> createState() => _AddBoatDialogState();
}

class _AddBoatDialogState extends State<AddBoatDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _speedController = TextEditingController();
  final _crewController = TextEditingController();
  
  String _selectedStatus = 'Au port';
  bool _cameraActive = false;

  @override
  void dispose() {
    _nameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _speedController.dispose();
    _crewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ajouter un nouveau bateau',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du bateau',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.directions_boat),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un nom';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Statut',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.info),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'En mer', child: Text('En mer')),
                      DropdownMenuItem(value: 'Au port', child: Text('Au port')),
                      DropdownMenuItem(value: 'En maintenance', child: Text('En maintenance')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latitudeController,
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Requis';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Nombre invalide';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _longitudeController,
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Requis';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Nombre invalide';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _speedController,
                          decoration: const InputDecoration(
                            labelText: 'Vitesse (nœuds)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.speed),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Requis';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Nombre invalide';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _crewController,
                          decoration: const InputDecoration(
                            labelText: 'Équipage',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.people),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Requis';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Nombre invalide';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Caméra active'),
                    subtitle: const Text('Activer la caméra du bateau'),
                    value: _cameraActive,
                    onChanged: (value) {
                      setState(() {
                        _cameraActive = value;
                      });
                    },
                    activeColor: const Color(0xFF1E3A8A),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Ajouter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newId = (DateTime.now().millisecondsSinceEpoch % 10000).toString();
      final boat = Boat(
        id: newId,
        name: _nameController.text,
        status: _selectedStatus,
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
        speed: double.parse(_speedController.text),
        lastUpdate: 'Ajouté à l\'instant',
        imageUrl: 'images/téléchargement.png',
        cameraActive: _cameraActive,
        crewMembers: int.parse(_crewController.text),
      );
      widget.onAddBoat(boat);
    }
  }
}
