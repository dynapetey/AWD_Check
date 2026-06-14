import 'package:flutter/material.dart';
import '../services/vin_service.dart';

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