import 'package:flutter/material.dart';
import '../services/vin_service.dart';

class VehicleProvider extends ChangeNotifier {
  VehicleData? _vehicleData;
  VehicleData? get vehicleData => _vehicleData;
  String? _errorMessage;
  bool _isLoading = false;

  // ... (keep your existing properties and methods)

  void reset() {
    _vehicleData = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners(); // This is the key part that updates your UI
  }
}

class VehicleProvider with ChangeNotifier {
  final VinService _vinService = VinService();
  
  Map<String, dynamic>? _vehicleData;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get vehicleData => _vehicleData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchVehicleDetails(String vin) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _vehicleData = await _vinService.decodeVin(vin);
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _vehicleData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
