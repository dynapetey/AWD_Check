import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import 'camera_screen.dart';import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
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
    
    if (!mounted) return;

    if (provider.vehicleData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const VehicleInfoScreen()),
      );
    } else if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text("AWD Check")),
      body: Center(
        child: provider.isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Upload or scan a VIN"),
                  // Add your camera/file picking UI here
                ],
              ),
      ),
    );
  }
}

import 'vehicle_info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AWD Check'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to AWD Check',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CameraScreen()),
                );
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Vehicle Photo'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
            Consumer<VehicleProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    if (provider.currentVehicle != null)
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VehicleInfoScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info),
                        label: const Text('View Vehicle Details'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    const SizedBox(height: 20),
                    if (provider.imagePath != null)
                      Image.file(
                        File(provider.imagePath!),
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    else
                      const Text('No vehicle data yet. Take a photo to begin.'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
