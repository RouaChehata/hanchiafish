import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.137.1:5000';

  // Ba3eth GPS position
  static Future<void> sendGps(double latitude, double longitude) async {
    await http.post(
      Uri.parse('$baseUrl/gps'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
    );
  }

  // Jib akher position
  static Future<Map<String, dynamic>?> getGps() async {
    final response = await http.get(Uri.parse('$baseUrl/gps'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // Jib les alertes
  static Future<List<dynamic>> getAlertes() async {
    final response = await http.get(Uri.parse('$baseUrl/alertes'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  // Jib historique GPS
  static Future<List<dynamic>> getGpsHistory() async {
  final response = await http.get(Uri.parse('$baseUrl/gps/history'));
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  return [];
}

// Jib liste captures
static Future<List<dynamic>> getCaptures() async {
  final response = await http.get(Uri.parse('$baseUrl/captures'));
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  return [];
}

  static Future<Map<String, dynamic>?> getCaptureImage(int id) async {
  final response = await http.get(Uri.parse('$baseUrl/capture/$id'));
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  return null;
}

static Future<Map<String, dynamic>?> getBoatsStatus() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/boats/status'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
  } catch (_) {}
  return null;
}
}