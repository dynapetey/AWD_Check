import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle_data.dart';

class VinService {
  // Use the flat format API for robust and easy parsing
  static const String _baseUrl = 'https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValues';

  Future<VehicleData?> lookupVehicle(String vin) async {
    try {
      // Correct URL construction for flat format API
      final url = Uri.parse('$_baseUrl/$vin?format=json');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final results = json['Results'] as List;

        // Map the results for easy O(1) lookup
        final Map<String, String> data = {};
        for (var item in results) {
          final variable = item['Variable'] as String;
          final value = item['Value']?.toString() ?? '';
          data[variable] = value;
        }

        // Check for specific error indicator returned by NHTSA
        if (data['Error Text']?.contains('Incomplete') ?? false) {
          throw Exception('VIN search results are incomplete');
        }

        // Map API response to your VehicleData model
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
