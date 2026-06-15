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
    final bgColor = hasAWD ? Colors.green.shade900 : Colors.orange.shade900;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bgColor, bgColor.withValues(alpha: 0.7)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          hasAWD ? Icons.check_circle_outline : Icons.error_outline,
                          size: 80,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'AWD Status',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          hasAWD ? 'Equipped' : 'Not Equipped',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, 'Vehicle Details'),
                      const SizedBox(height: 16),
                      _buildInfoCard([
                        _buildInfoRow(Icons.fingerprint, 'VIN', vehicleData.vin),
                        _buildInfoRow(Icons.directions_car, 'Make', vehicleData.make ?? 'N/A'),
                        _buildInfoRow(Icons.model_training, 'Model', vehicleData.model ?? 'N/A'),
                        _buildInfoRow(Icons.layers, 'Trim', vehicleData.trimLevel ?? 'N/A'),
                        _buildInfoRow(Icons.calendar_today, 'Year', vehicleData.year?.toString() ?? 'N/A'),
                      ]),
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'Drivetrain Specifications'),
                      const SizedBox(height: 16),
                      _buildInfoCard([
                        _buildInfoRow(Icons.settings_input_component, 'Drive Type', vehicleData.driveType ?? 'N/A'),
                        _buildInfoRow(Icons.all_inclusive, 'AWD System', vehicleData.isAwd ? 'Detected' : 'Not Detected'),
                      ]),
                      const SizedBox(height: 32),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back to Scanner'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
    );
  }

  Widget _buildInfoCard(List<Widget> rows) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: rows.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            return Column(
              children: [
                row,
                if (index < rows.length - 1)
                  const Divider(color: Colors.white24, height: 24),
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
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
