import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehicle_data.dart';
import '../providers/vehicle_provider.dart';

class VehicleInfoScreen extends StatelessWidget {
  final VehicleData vehicleData;

  const VehicleInfoScreen({
    Key? key,
    required this.vehicleData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasAWD = vehicleData.hasAWD;
    final bgColor = hasAWD ? Colors.green.shade900 : Colors.orange.shade900;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bgColor, bgColor.withOpacity(0.7)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'AWD Status',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          vehicleData.awdStatus,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: hasAWD ? Colors.greenAccent : Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Vehicle Information
                  const Text(
                    'Vehicle Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info Cards
                  _buildInfoCard(
                    'Year',
                    vehicleData.year ?? 'N/A',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    'Make',
                    vehicleData.make ?? 'N/A',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    'Model',
                    vehicleData.model ?? 'N/A',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    'Driveline',
                    vehicleData.driveline ?? 'N/A',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    'VIN',
                    vehicleData.vin,
                    isVin: true,
                  ),

                  const SizedBox(height: 40),

                  // Buttons
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<VehicleProvider>().reset();
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Scan Another Vehicle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, {bool isVin = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isVin ? 12 : 18,
              fontWeight: FontWeight.bold,
              fontFamily: isVin ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }
}
