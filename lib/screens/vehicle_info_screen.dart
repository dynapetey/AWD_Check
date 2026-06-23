import 'package:flutter/material.dart';
import '../models/vehicle_data.dart';

class VehicleInfoScreen extends StatelessWidget {
  final VehicleData vehicleData;

  const VehicleInfoScreen({
    Key? key,
    required this.vehicleData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasAWD = vehicleData.isAwd;
    // Keep a green accent for equipped, but use our theme red for not equipped
    final statusColor = hasAWD ? Colors.greenAccent : const Color(0xFFE50914);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 240,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                iconTheme: const IconThemeData(color: Color(0xFFE50914)), // Red back arrow
                flexibleSpace: FlexibleSpaceBar(
                  background: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          hasAWD ? Icons.check_circle_outline : Icons.cancel_outlined,
                          size: 80,
                          color: statusColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'AWD STATUS',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            hasAWD ? 'EQUIPPED' : 'NOT EQUIPPED',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, 'VEHICLE DETAILS'),
                      const SizedBox(height: 16),
                      _buildInfoCard([
                        _buildInfoRow(Icons.fingerprint, 'VIN', vehicleData.vin),
                        _buildInfoRow(Icons.directions_car, 'Make', vehicleData.make ?? 'N/A'),
                        _buildInfoRow(Icons.model_training, 'Model', vehicleData.model ?? 'N/A'),
                        _buildInfoRow(Icons.layers, 'Trim', vehicleData.trimLevel ?? 'N/A'),
                        _buildInfoRow(Icons.calendar_today, 'Year', vehicleData.year?.toString() ?? 'N/A'),
                      ]),
                      const SizedBox(height: 32),
                      _buildSectionTitle(context, 'DRIVETRAIN SPECS'),
                      const SizedBox(height: 16),
                      _buildInfoCard([
                        _buildInfoRow(Icons.settings_input_component, 'Drive Type', vehicleData.driveType ?? 'N/A'),
                        _buildInfoRow(Icons.all_inclusive, 'AWD System', vehicleData.isAwd ? 'Detected' : 'Not Detected'),
                        _buildInfoRow(Icons.local_parking, 'Electric Parking Brake', vehicleData.electricParkingBrake ?? 'N/A'),
                      ]),
                      const SizedBox(height: 40),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text(
                            'SCAN ANOTHER VIN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE50914), // Theme Red
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                            shadowColor: const Color(0xFFE50914).withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          color: const Color(0xFFE50914), // Red accent bar
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // Dark Grey Card
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: rows.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            return Column(
              children: [
                row,
                if (index < rows.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFE50914), size: 20), // Red Icon
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
