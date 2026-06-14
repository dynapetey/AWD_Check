import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle_data.dart';

const String nhtsaApiUrl = 'https://vpic.nhtsa.dot.gov/api/vehicles';

class VinService {
  Future<VehicleData?> lookupVehicle(String vin) async { ... }
    try {
      final response = await http.get(
        Uri.parse('$nhtsaApiUrl/decodevin/$vin?format=json')
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final results = json['Results'] as List;

        String? driveType;
        String? make;
        String? model;
        String? yearStr;

        for (var result in results) {
          final variable = result['Variable'];
          final value = result['Value']?.toString();

          if (variable == 'Error Text' && value != null && value.contains('Incomplete')) {
            throw Exception('VIN search results are incomplete');
          }

          if (variable == 'Drive Type') {
            driveType = value;
          } else if (variable == 'Make') {
            make = value;
          } else if (variable == 'Model') {
            model = value;
          } else if (variable == 'Model Year') {
            yearStr = value;
          }
        }

        final isAwd = driveType != null &&
            (driveType.toLowerCase().contains('all-wheel') ||
                driveType.toLowerCase().contains('4-wheel'));

        return VehicleData(
          vin: vin,
          make: make ?? '',
          model: model ?? '',
          year: int.tryParse(yearStr ?? '') ?? 0,
          driveType: driveType,
          isAwd: isAwd,
        );
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }
}
