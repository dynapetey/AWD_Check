import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import 'camera_screen.dart';
import 'vehicle_info_screen.dart';

<<<<<<< Updated upstream
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
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
=======
// Inside lib/screens/home_screen.dart

Future<void> _processImage(File imageFile) async {
  // 1. Get the provider
  final provider = Provider.of<VehicleProvider>(context, listen: false);
  
  // 2. Call the provider method we just created
  await provider.processImage(imageFile);
  
  // 3. Optional: Navigate to the results screen if needed
  if (provider.vehicleData != null) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VehicleInfoScreen()),
    );
  } else if (provider.errorMessage != null) {
    // Show error dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(provider.errorMessage!)),
    );
  }
}
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
>>>>>>> Stashed changes

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehicleProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

<<<<<<< Updated upstream
    if (provider.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
=======
  Widget _buildMainScreen(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade900, Colors.blue.shade500],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'AWD or Not',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Scan your vehicle\'s VIN to check if it has AWD',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 60),
            // Take Photo Button
            FloatingActionButton.extended(
              onPressed: () async {
                final imagePath = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CameraScreen(),
                  ),
                );

                if (imagePath != null && context.mounted) {
                  _processImage(context, imagePath);
                }
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              heroTag: 'camera_button',
            ),
          ],
        ),
      ),
    );
  }

  class _processImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Processing Image'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Extracting VIN and looking up vehicle...'),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (context.mounted) {
        context.read<VehicleProvider>().processImage(imagePath).then((_) {
          Navigator.pop(context); // Close dialog
        });
      }
    });
  }
}
// Example widget implementation
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Consumer<VehicleProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (provider.errorMessage != null) {
          return Center(child: Text("Error: ${provider.errorMessage}"));
        }

        if (provider.vehicleData != null) {
          bool isAwd = provider.vehicleData!['isAwd'];
          return Column(
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
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
=======
        );
      },
    ),
  );
}
}
>>>>>>> Stashed changes
