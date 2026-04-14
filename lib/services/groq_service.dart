import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/boat_model.dart'; // Correction du nom du fichier ici

class GroqService {
  // UTILISE TA CLÉ QUI FINIT PAR rKK0 (vue sur ta capture d'écran)
  static const String _apiKey = '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'; 
  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.1-8b-instant';

  Future<String> generateReport(Boat boat) async {
    final prompt = '''
Tu es un officier maritime. Génère un rapport professionnel pour :
- Bateau : ${boat.name}
- Statut : ${boat.status}
- Vitesse : ${boat.speed} nœuds
- Position : ${boat.latitude}, ${boat.longitude}
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