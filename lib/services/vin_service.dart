import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle_data.dart';

class VinService {
  static const String _baseUrl = 'https://vpic.nhtsa.dot.gov/api/vehicles';

  Future<VehicleData?> lookupVehicle(String vin, {int? modelYear}) async {
    // Validate VIN length to prevent unnecessary API calls
    if (vin.length != 17) {
      throw Exception('Invalid VIN: Must be 17 characters long.');
    }

    try {
      final queryParameters = <String, String>{'format': 'json'};
      if (modelYear != null) {
        queryParameters['modelyear'] = modelYear.toString();
      }

      final url = Uri.parse('$_baseUrl/decodevin/$vin').replace(
        queryParameters: queryParameters,
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final results = json['Results'] as List;

        if (results.isEmpty) {
          throw Exception('Vehicle not found for this VIN.');
        }

        // Corrected: Safely map results without using 'as String' 
        // to avoid the Null subtype error seen in Screenshot_20260615_053604.jpg
        final Map<String, String> data = {};
        for (var item in results) {
          final variable = item['Variable']?.toString() ?? 'Unknown';
          final value = item['Value']?.toString() ?? '';
          data[variable] = value;
        }

        if (data['Error Text'] != null && data['Error Text']!.isNotEmpty) {
          throw Exception(data['Error Text']);
        }

        final parkingBrakeValue = data['Parking Brake Type'] ?? data['Parking Brake'] ?? '';
        final brakeSystemDescription = data['Brake System Description'] ?? '';
        String? electricParkingBrake;
        if (parkingBrakeValue.isNotEmpty) {
          electricParkingBrake = parkingBrakeValue;
        } else if (brakeSystemDescription.toLowerCase().contains('electric parking brake')) {
          electricParkingBrake = 'Electric';
        }

        return VehicleData(
          vin: vin,
          make: data['Make'] ?? '',
          model: data['Model'] ?? '',
          year: int.tryParse(data['Model Year'] ?? '') ?? 0,
          driveType: data['Drive Type'] ?? '',
          electricParkingBrake: electricParkingBrake,
          isAwd: data['Drive Type']?.toLowerCase().contains('all-wheel') ?? false,
        );
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }
}