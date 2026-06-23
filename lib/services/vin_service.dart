import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle_data.dart';

class VinService {
  static const String _baseUrl = 'https://vpic.nhtsa.dot.gov/api/vehicles';

  Future<VehicleData?> lookupVehicle(String vin, {int? modelYear}) async {
    final normalizedVin = vin.replaceAll(RegExp(r'[\s-]+'), '').toUpperCase();

    // Keep validation strict while allowing user input formatting variations.
    if (normalizedVin.length != 17) {
      throw Exception('Invalid VIN: Must be 17 characters long.');
    }

    try {
      final queryParameters = <String, String>{'format': 'json'};
      if (modelYear != null) {
        queryParameters['modelyear'] = modelYear.toString();
      }

      final url = Uri.parse('$_baseUrl/decodevin/$normalizedVin').replace(
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

        final errorCode = data['Error Code'] ?? '';
        final errorText = data['Error Text'] ?? '';
        final hasCoreVehicleData =
            (data['Make'] ?? '').isNotEmpty ||
            (data['Model'] ?? '').isNotEmpty ||
            (data['Model Year'] ?? '').isNotEmpty ||
            (data['Drive Type'] ?? '').isNotEmpty;

        // NHTSA may return warning text even when decode fields are usable.
        if (!hasCoreVehicleData && errorCode != '0' && errorText.isNotEmpty) {
          throw Exception(errorText);
        }

        final parkingBrakeValue = data['Parking Brake Type'] ?? data['Parking Brake'] ?? '';
        final brakeSystemDescription = data['Brake System Description'] ?? '';
        String? electricParkingBrake;
        if (parkingBrakeValue.isNotEmpty) {
          electricParkingBrake = parkingBrakeValue;
        } else if (brakeSystemDescription.toLowerCase().contains('electric parking brake')) {
          electricParkingBrake = 'Electric';
        }

        final driveType = data['Drive Type'] ?? '';
        final driveTypeLower = driveType.toLowerCase();
        final isAwdOr4wd =
            driveTypeLower.contains('all-wheel') ||
            driveTypeLower.contains('awd') ||
            driveTypeLower.contains('4wd') ||
            driveTypeLower.contains('4x4') ||
            driveTypeLower.contains('four-wheel');

        return VehicleData(
          vin: normalizedVin,
          make: data['Make'] ?? '',
          model: data['Model'] ?? '',
          year: int.tryParse(data['Model Year'] ?? '') ?? 0,
          driveType: driveType,
          electricParkingBrake: electricParkingBrake,
          isAwd: isAwdOr4wd,
        );
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }
}