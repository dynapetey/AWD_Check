import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import 'camera_screen.dart';
import 'vehicle_info_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Consumer<VehicleProvider>(
          builder: (context, provider, _) {
            // Show vehicle info if available
            if (provider.vehicleData != null) {
              return VehicleInfoScreen(vehicleData: provider.vehicleData!);
            }
            // Show main screen
            return _buildMainScreen(context);
          },
        ),
      ),
    );
  }

  Widget _buildMainScreen(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Center(
                child: _buildScanButton(context),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Icon(
            Icons.directions_car_rounded,
            color: Color(0xFFE50914),
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'AWD CHECK',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
          Container(
            height: 2,
            width: 40,
            color: const Color(0xFFE50914),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const CameraScreen()),
        );
      },
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFE50914).withValues(alpha: 0.5),
            width: 2
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE50914).withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'SCAN VIN',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.all(32.0),
      child: Text(
        'Scan vehicle VIN to check AWD status',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 14,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
