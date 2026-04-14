import 'package:flutter/material.dart';
import '../../models/boat_model.dart'; // Correction de l'import
import '../../services/groq_service.dart';

class RapportScreen extends StatefulWidget {
  final Boat? selectedBoat; // Utilisation de Boat
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
    // Utilisation de la méthode statique correcte de ton fichier boat_model.dart
    _selectedBoat = widget.selectedBoat ?? Boat.getDemoBoats().first;
  }

  Future<void> _generate() async {
    if (_selectedBoat == null) return;
    setState(() { _loading = true; _error = null; _report = null; });
    try {
      final result = await _groq.generateReport(_selectedBoat!);
      setState(() { _report = result; });
    } catch (e) {
      setState(() { _error = e.toString().replaceAll('Exception: ', ''); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rapport IA")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_selectedBoat != null) Text("Bateau : ${_selectedBoat!.name}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _generate,
              child: Text(_loading ? "Chargement..." : "Générer Rapport"),
            ),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_report != null) Text(_report!),
          ],
        ),
      ),
    );
  }
}