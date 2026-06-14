import 'package:flutter/material.dart';
import '../models/vehicle_data.dart';
import '../services/vin_service.dart';

class VehicleProvider extends ChangeNotifier {
  final VinService _vinService = VinService();
  
  VehicleData? _vehicleData;
  bool _isLoading = false;
  String? _errorMessage;

  VehicleData? get vehicleData => _vehicleData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> processImage(String imagePath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _vehicleData = await _vinService.processImage(imagePath);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
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

  @override
  void dispose() {
    _vinService.dispose();
    super.dispose();
  }
}
