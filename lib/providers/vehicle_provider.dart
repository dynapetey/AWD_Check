import 'package:flutter/material.dart';
import 'dart:io';
import '../models/vehicle_data.dart';
import '../services/vin_service.dart';

class VehicleProvider extends ChangeNotifier {
  VehicleData? _vehicleData;
  String? _errorMessage;
  bool _isLoading = false;

  VehicleData? get vehicleData => _vehicleData;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> processImage(File imageFile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String vin = await VinService.extractVinFromImage(imageFile);
      _vehicleData = await VinService.getVehicleData(vin);
    } catch (e) {
      _errorMessage = e.toString();
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
