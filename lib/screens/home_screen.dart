import 'dart:io';
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
    return Scaffold(
      appBar: AppBar(title: const Text("AWD Check")),
      body: Consumer<VehicleProvider>(
        builder: (context, provider, child) {
          return Center(
            child: provider.isLoading
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Upload or scan a VIN"),
                      // Place your image picker integration here
                    ],
                  ),
          );
        },
      ),
    );
  }
}
