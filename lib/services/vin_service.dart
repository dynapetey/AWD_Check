import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../models/vehicle_data.dart';

class VinService {
  static const String _nhtsaApiUrl =
      'https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVin';

  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Extract VIN from image using ML Kit
  Future<String?> extractVinFromImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Extract 17-digit VIN
      final vinRegex = RegExp(r'\b[A-HJ-NPR-Z0-9]{17}\b');
      for (var block in recognizedText.blocks) {
        for (var line in block.lines) {
          final match = vinRegex.firstMatch(line.text);
          if (match != null) {
            return match.group(0);
          }
        }
      }

      // If no exact 17-digit match, try to find VIN-like patterns
      final allText = recognizedText.text.toUpperCase().replaceAll(' ', '');
      final cleanMatch = vinRegex.firstMatch(allText);
      if (cleanMatch != null) {
        return cleanMatch.group(0);
      }

      return null;
    } catch (e) {
      print('Error extracting VIN: $e');
      return null;
    }
  }

  /// Lookup vehicle data using NHTSA API
  Future<VehicleData?> lookupVehicle(String vin) async {
    if (vin.length != 17) {
      throw Exception('VIN must be 17 digits long');
    }

    try {
      final response = await http.get(
        Uri.parse('$_nhtsaApiUrl/$vin?format=json'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final results = json['Results'] as List;

        if (results.isEmpty) {
          throw Exception('VIN not found in database');
        }

        // Convert results array to a single map
        final vehicleData = <String, dynamic>{};
        for (var result in results) {
          if (result['Value'] != null && result['Value'].toString().isNotEmpty) {
            vehicleData[result['Variable']] = result['Value'];
          }
        }

        vehicleData['VIN'] = vin;
        return VehicleData.fromJson(vehicleData);
      } else {
        throw Exception('Failed to lookup VIN: ${response.statusCode}');
      }
    } catch (e) {
      print('Error looking up vehicle: $e');
      rethrow;
    }
  }

  /// Process image: extract VIN and lookup vehicle data
  Future<VehicleData?> processImage(String imagePath) async {
    try {
      // First, rotate image if needed
      final rotatedImagePath = await _rotateImageIfNeeded(imagePath);

      // Extract VIN from image
      final vin = await extractVinFromImage(rotatedImagePath);

      if (vin == null) {
        throw Exception('Could not extract VIN from image');
      }

      // Lookup vehicle data
      final vehicleData = await lookupVehicle(vin);
      return vehicleData;
    } catch (e) {
      print('Error processing image: $e');
      rethrow;
    }
  }

  /// Rotate image if needed (fixes orientation issues)
  Future<String> _rotateImageIfNeeded(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return imagePath;

      // For now, just return the original path
      // In production, you might want to handle EXIF data
      return imagePath;
    } catch (e) {
      return imagePath;
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
