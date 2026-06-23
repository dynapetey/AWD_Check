import 'dart:io';
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
        backgroundColor: Colors.black,
        body: Consumer<VehicleProvider>(
          builder: (context, provider, _) {
            // 1. Show loading spinner if OCR or API is working
            if (provider.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFE50914)),
                    SizedBox(height: 16),
                    Text(
                      'SCANNING VIN...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              );
            }

            // 2. Show vehicle info if available
            if (provider.vehicleData != null) {
              return VehicleInfoScreen(vehicleData: provider.vehicleData!);
            }
            
            // 3. Show main screen (passing any error messages down)
            return _buildMainScreen(context, provider.errorMessage);
          },
        ),
      ),
    );
  }

  Widget _buildMainScreen(BuildContext context, String? errorMessage) {
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
            // Display errors (like "Could not detect VIN") if they exist
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Color(0xFFE50914),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
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
      onTap: () async {
        final String? scanResult = await Navigator.of(context).push<String>(
          MaterialPageRoute(builder: (context) => const CameraScreen()),
        );

        if (scanResult != null && context.mounted) {
          final provider = Provider.of<VehicleProvider>(context, listen: false);
          if (scanResult.startsWith('vin:')) {
            await provider.fetchVehicleDetails(scanResult.substring(4));
          } else {
            await provider.processImage(File(scanResult));
          }
        }
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
