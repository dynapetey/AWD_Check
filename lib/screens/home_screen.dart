import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import 'camera_screen.dart';
import 'vehicle_info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _processImage(File imageFile) async {
    final provider = Provider.of<VehicleProvider>(context, listen: false);
    await provider.processImage(imageFile);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehicleProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(provider.errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.reset(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.vehicleData != null) {
      return VehicleInfoScreen(vehicleData: provider.vehicleData!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AWD Check')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final File? image = await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CameraScreen()),
            );
            if (image != null) {
              await _processImage(image);
            }
          },
          child: const Text('Scan Vehicle'),
        ),
      ),
    );
  }
}
