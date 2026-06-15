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
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          vehicleData.isAwd ? 'AWD' : 'Non-AWD',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
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
                      const Text(
                        'Vehicle Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        'Make',
                        vehicleData.make ?? 'N/A',
                      ),
                      _buildInfoCard(
                        'Model',
                        vehicleData.model ?? 'N/A',
                      ),
                      _buildInfoCard(
                        'Year',
                        vehicleData.year?.toString() ?? 'N/A',
                      ),
                      _buildInfoCard(
                        'Trim',
                        vehicleData.trimLevel ?? 'N/A',
                      ),
                      _buildInfoCard(
                        'Drive Type',
                        vehicleData.driveType ?? 'Unknown',
                      ),
                      _buildInfoCard(
                        'VIN',
                        vehicleData.vin ?? 'N/A',
                        isVin: true,
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: bgColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('SEARCH ANOTHER'),
                        ),
                      ),
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

  Widget _buildInfoCard(String label, String value, {bool isVin = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white,
                fontSize: isVin ? 14 : 16,
                fontWeight: FontWeight.w600,
                fontFamily: isVin ? 'Monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
