import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle_data.dart';

class VinService {
  static const String _baseUrl = 'https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValues';

  Future<VehicleData?> lookupVehicle(String vin) async {
    // 1. Validate VIN length
    if (vin.length != 17) {
      throw Exception('Invalid VIN: Must be 17 characters long.');
    }

    try {
      final url = Uri.parse('$_baseUrl/$vin?format=json');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final results = json['Results'] as List;

        // 2. Handle empty results (VIN not found or invalid)
        if (results.isEmpty) {
          throw Exception('Vehicle not found for this VIN.');
        }

        final Map<String, String> data = {};
        for (var item in results) {
          final variable = item['Variable'] as String;
          final value = item['Value']?.toString() ?? '';
          data[variable] = value;
        }

        // 3. Handle API-reported errors
        if (data['Error Text'] != null && data['Error Text']!.isNotEmpty) {
          throw Exception(data['Error Text']);
        }

        return VehicleData(
          vin: vin,
          make: data['Make'] ?? '',
          model: data['Model'] ?? '',
          year: int.tryParse(data['Model Year'] ?? '') ?? 0,
          driveType: data['Drive Type'] ?? '',
          isAwd: data['Drive Type']?.toLowerCase().contains('all-wheel') ?? false,
        );
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }
}
