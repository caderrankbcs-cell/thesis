import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prediction_model.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, or local machine IP for physical device
  static const String baseUrl = "http://10.0.2.2:8000";

  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'healthy';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<PredictionResponse> predictStudent(Map<String, dynamic> studentData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(studentData),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PredictionResponse.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to get prediction from server.');
      }
    } catch (e) {
      throw Exception('Network or Server Error: ${e.toString()}');
    }
  }
}
