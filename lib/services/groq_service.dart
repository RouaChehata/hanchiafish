import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/boat_model.dart';
import 'package:primaa/api_service.dart';

class GroqService {
  static const String _apiKey = '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';
  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.1-8b-instant';

  Future<String> generateReport(Boat boat) async {

    // ✅ Jib data réelle mel Flask lel HanchiaFish-001
    double lat = boat.latitude;
    double lon = boat.longitude;
    double speed = boat.speed;
    String status = boat.status;

    if (boat.id == '1') {
      try {
        final gpsData = await ApiService.getGps();
        if (gpsData != null) {
          lat = gpsData['latitude'];
          lon = gpsData['longitude'];
          speed = (gpsData['speed'] ?? 0.0).toDouble();
          status = (gpsData['in_port'] ?? false) ? 'Au port' : 'En mer';
        }
      } catch (_) {}
    }

    final prompt = '''
Tu es un officier maritime. Génère un rapport d'état professionnel en français pour le navire suivant.

DONNÉES RÉELLES DU NAVIRE :
- Nom : ${boat.name}
- Statut : $status
- Position GPS : Lat ${lat.toStringAsFixed(5)}° N, Lon ${lon.toStringAsFixed(5)}° E
- Vitesse : ${speed.toStringAsFixed(1)} km/h
- Membres d'équipage : ${boat.crewMembers}
- Caméra : ${boat.cameraActive ? 'Active' : 'Inactive'}

Le rapport doit contenir :
1. RÉSUMÉ DE L'ÉTAT GÉNÉRAL
2. POSITION ET NAVIGATION
3. ÉTAT DE L'ÉQUIPAGE
4. ÉTAT DE LA SURVEILLANCE
5. RECOMMANDATIONS

Utilise uniquement les données fournies. Sois précis et professionnel.
''';

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [{'role': 'user', 'content': prompt}],
          'max_tokens': 1000,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        final errorMsg = jsonDecode(response.body)['error']['message'];
        throw Exception(errorMsg ?? 'Erreur Groq');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }
}
