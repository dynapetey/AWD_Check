class VehicleData {
  final String vin;
  final String? make;
  final String? model;
  final String? trimLevel;
  final int? year;
  final String? driveType;
  final String? electricParkingBrake;
  final bool isAwd;

  VehicleData({
    required this.vin,
    this.make,
    this.model,
    this.trimLevel,
    this.year,
    this.driveType,
    this.electricParkingBrake,
    required this.isAwd,
  });
}
