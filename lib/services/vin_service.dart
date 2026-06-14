import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http/http.dart' as http;

class VinService {
  Future<Map<String, dynamic>> decodeVin(String vin) async {
    final url = Uri.parse('https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVin/$vin?format=json');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['Results'];

        // Extract relevant information
        String driveType = "Unknown";
        for (var item in results) {
          if (item['Variable'] == 'Drive Type') {
            driveType = item['Value'] ?? 'N/A';
          }
        }

        // Check for Error Code to ensure valid response
        final errorCheck = results.firstWhere(
          (item) => item['Variable'] == 'Error Text', 
          orElse: () => {'Value': ''}
        );

        if (errorCheck['Value'].toString().contains('Incomplete')) {
          throw Exception("Invalid or Incomplete VIN");
        }

        return {
          'driveType': driveType,
          'isAwd': driveType.toLowerCase().contains('all-wheel') || 
                   driveType.toLowerCase().contains('4-wheel')
        };
      } else {
        throw Exception("Failed to load vehicle data");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}