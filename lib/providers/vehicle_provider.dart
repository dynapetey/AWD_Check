import 'dart:io';
import 'package:flutter/material.dart';
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
      // Placeholder for OCR logic: Ensure VinService has a method to extract VIN if needed, 
      // or implement your OCR logic here.
      // For now, this will trigger the fetch with a placeholder logic.
      _errorMessage = "OCR extraction not yet implemented.";
      _vehicleData = null;
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
