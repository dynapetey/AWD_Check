class VehicleData {
  final String vin;
  final String? make;
  final String? model;
  final int? year;
  final String? driveType;
  final bool isAwd;

  VehicleData({
    required this.vin,
    this.make,
    this.model,
    this.year,
    this.driveType,
    required this.isAwd,
  });
}