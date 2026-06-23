import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class GeminiOcrService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _model = 'gemini-2.0-flash';
  static final RegExp _vinRegex = RegExp(r'[A-HJ-NPR-Z0-9]{17}');

  Future<String?> extractVin(File imageFile) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'Gemini OCR is not configured. Provide GEMINI_API_KEY with --dart-define.',
      );
    }

    final imageBytes = await imageFile.readAsBytes();
    final mimeType = _detectMimeType(imageFile.path);
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey',
    );

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {
                    'text': 'Extract the vehicle VIN from this image. Return only one 17-character VIN in uppercase with no spaces or punctuation. If no VIN is visible, return NONE.'
                  },
                  {
                    'inlineData': {
                      'mimeType': mimeType,
                      'data': base64Encode(imageBytes),
                    },
                  },
                ],
              },
            ],
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Gemini OCR request failed (${response.statusCode}).');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = json['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      return null;
    }

    for (final candidate in candidates) {
      final content = candidate['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      if (parts == null) {
        continue;
      }

      for (final part in parts) {
        final text = part['text']?.toString();
        if (text == null || text.isEmpty) {
          continue;
        }

        final normalizedText = text.replaceAll(RegExp(r'[\s\-]+'), '').toUpperCase();
        final match = _vinRegex.firstMatch(normalizedText);
        if (match != null) {
          return match.group(0);
        }
      }
    }

    return null;
  }

  String _detectMimeType(String path) {
    final lowerPath = path.toLowerCase();
    if (lowerPath.endsWith('.png')) {
      return 'image/png';
    }
    if (lowerPath.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }
}