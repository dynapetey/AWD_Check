import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:io';
import '../models/vehicle_data.dart';
import '../services/vin_service.dart';
import '../models/vehicle_data.dart';

class VehicleProvider extends ChangeNotifier {
<<<<<<< Updated upstream
  VehicleData? _vehicleData;
  String? _errorMessage;
  bool _isLoading = false;

  VehicleData? get vehicleData => _vehicleData;
=======
  final VinService _vinService = VinService();
  
  VehicleData? _vehicleData;
  bool _isLoading = false;
  String? _errorMessage;

  // Public Getters
  VehicleData? get vehicleData => _vehicleData;
  bool get isLoading => _isLoading;
>>>>>>> Stashed changes
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

<<<<<<< Updated upstream
  Future<void> processImage(File imageFile) async {
=======
  // Main fetch method
  Future<void> fetchVehicleDetails(String vin) async {
>>>>>>> Stashed changes
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
<<<<<<< Updated upstream
      final String vin = await VinService.extractVinFromImage(imageFile);
      _vehicleData = await VinService.getVehicleData(vin);
=======
      // Use your service to get the data
      _vehicleData = await _vinService.lookupVehicle(vin);
>>>>>>> Stashed changes
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

<<<<<<< Updated upstream
=======
  // Reset method
>>>>>>> Stashed changes
  void reset() {
    _vehicleData = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
<<<<<<< Updated upstream
=======

  Future<void> processImage(File imageFile) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    // 1. Perform image-to-text or VIN extraction here
    // String extractedVin = await _imageService.extractVin(imageFile);
    
    // 2. Use your existing lookup method
    // _vehicleData = await _vinService.lookupVehicle(extractedVin);
    
    // TEMPORARY: Placeholder for the logic you are building
    print("Processing image..."); 
    
  } catch (e) {
    _errorMessage = "Failed to process image: $e";
    _vehicleData = null;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
>>>>>>> Stashed changes
}
}