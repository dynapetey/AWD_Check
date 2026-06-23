import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/gemini_ocr_service.dart';
import '../services/vin_service.dart';
import '../models/vehicle_data.dart';

class VehicleProvider extends ChangeNotifier {
  final GeminiOcrService _geminiOcrService = GeminiOcrService();
  final VinService _vinService = VinService();
  
  VehicleData? _vehicleData;
  bool _isLoading = false;
  String? _errorMessage;

  VehicleData? get vehicleData => _vehicleData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchVehicleDetails(String vin, {int? modelYear}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _vehicleData = await _vinService.lookupVehicle(vin, modelYear: modelYear);
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _vehicleData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> processImage(File imageFile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final vin = await _geminiOcrService.extractVin(imageFile);

      if (vin != null) {
        // Let's print it to the debug console so you can see what it found
        if (kDebugMode) {
          debugPrint('OCR Extracted VIN: $vin'); 
        }

        try {
          _vehicleData = await _vinService.lookupVehicle(vin);
        } catch (apiError) {
          // If the API fails, show the user exactly what VIN it tried to look up!
          _errorMessage = "Could not find vehicle for VIN: $vin\nReason: ${apiError.toString().replaceAll('Exception: ', '')}";
          _vehicleData = null;
        }

      } else {
        _errorMessage = "Could not detect a valid 17-character VIN in the image.";
        _vehicleData = null;
      }
    } catch (e) {
      _errorMessage = "Failed to process image: $e";
      _vehicleData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _vehicleData = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
