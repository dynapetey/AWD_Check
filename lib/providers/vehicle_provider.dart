import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../services/vin_service.dart';
import '../models/vehicle_data.dart';

class VehicleProvider extends ChangeNotifier {
  final VinService _vinService = VinService();
  
  VehicleData? _vehicleData;
  bool _isLoading = false;
  String? _errorMessage;

  VehicleData? get vehicleData => _vehicleData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchVehicleDetails(String vin) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _vehicleData = await _vinService.lookupVehicle(vin);
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
      // 1. Initialize the ML Kit Text Recognizer
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      
      // 2. Process the image and extract text
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      // 3. Clean the text (remove spaces/dashes that OCR might have inserted)
      String extractedText = recognizedText.text.replaceAll(RegExp(r'[\s\-]+'), '').toUpperCase();

      // 4. Use Regex to find a standard 17-character VIN 
      // (Valid VINs are 17 chars long and exclude the letters I, O, and Q)
      final vinRegex = RegExp(r'[A-HJ-NPR-Z0-9]{17}');
      final match = vinRegex.firstMatch(extractedText);

      if (match != null) {
        final String vin = match.group(0)!;
        
        // 5. Look up the vehicle details using the extracted VIN
        _vehicleData = await _vinService.lookupVehicle(vin);
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
