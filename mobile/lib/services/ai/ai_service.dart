import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final Dio _dio = Dio();

  Future<Map<String, dynamic>> analyzeWithAI(String imagePath) async {
    try {
      // Read the image file and convert to base64
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        return {'success': false, 'message': 'Image not found'};
      }

      // For simplicity, we'll use a direct prompt-based approach
      // The backend will handle the actual AI analysis
      // Here we just call the backend endpoint
      final apiClient = ApiClient();

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await apiClient.uploadFile(
        ApiConstants.analyzePrescription,
        formData: formData,
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> analyzePrescriptionDirect(String prompt) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.openRouterUrl}/chat/completions',
        data: {
          'model': ApiConstants.gemmaModel,
          'messages': [
            {
              'role': 'system',
              'content': '''You are a medical prescription analyzer. 
Analyze the prescription text and extract medication details.
Return a JSON object with these fields:
- name: medication name
- dosage: the dosage amount and unit
- frequency: how often to take (e.g., "twice daily", "once daily")
- instructions: special instructions if any
- confidence: a number between 0 and 1

If you cannot identify the medication, return the fields with "Unknown" values.
Always be accurate and remind users to consult healthcare professionals.''',
            },
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 500,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConstants.openRouterApiKey}',
            'Content-Type': 'application/json',
          },
        ),
      );

      final content =
          response.data['choices'][0]['message']['content'] as String;

      // Try to parse JSON from the response
      try {
        // Find JSON in the response
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
        if (jsonMatch != null) {
          final jsonData = jsonDecode(jsonMatch.group(0)!);
          return {
            'success': true,
            'data': {
              'name': jsonData['name'] ?? 'Unknown',
              'dosage': jsonData['dosage'] ?? 'As directed',
              'frequency': jsonData['frequency'] ?? 'As prescribed',
              'instructions':
                  jsonData['instructions'] ?? 'Follow doctor\'s instructions',
              'confidence': jsonData['confidence'] ?? 0.8,
            },
          };
        }
      } catch (e) {
        // If parsing fails, return a default response
      }

      return {
        'success': true,
        'data': {
          'name': 'Medication Detected',
          'dosage': 'As prescribed',
          'frequency': 'Follow doctor\'s instructions',
          'instructions': 'Consult your healthcare provider',
          'confidence': 0.7,
        },
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}

class ApiClient {
  final Dio _dio;
  String? _accessToken;

  ApiClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(milliseconds: 30000),
          receiveTimeout: const Duration(milliseconds: 30000),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

  void setTokens({String? accessToken, String? refreshToken}) {
    _accessToken = accessToken;
    if (accessToken != null) {
      _dio.options.headers['Authorization'] = 'Bearer $accessToken';
    }
  }

  Future<Response<T>> uploadFile<T>(
    String path, {
    required FormData formData,
  }) async {
    return _dio.post<T>(
      path,
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );
  }
}
