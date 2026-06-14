class VehicleData {
  final String vin;
  final String? year;
  final String? make;
  final String? model;
  final String? driveline;

  Vehicle_Data({
    required this.vin,
    this.year,
    this.make,
    this.model,
    this.driveline,
  });

  factory VehicleData.fromJson(Map<String, dynamic> json) {
    return VehicleData(
      vin: json['VIN'] ?? '',
      year: json['ModelYear']?.toString(),
      make: json['Make'],
      model: json['Model'],
      driveline: json['DriveType'] ?? json['Driveline'],
    );
  }

  bool get hasAWD {
    final dl = driveline?.toUpperCase() ?? '';
    return dl.contains('AWD') || dl.contains('4WD') || dl.contains('ALL-WHEEL');
  }

  String get awdStatus {
    if (driveline == null) return 'Unknown';
    return hasAWD ? 'AWD/4WD' : 'Not AWD/4WD';
  }
}
