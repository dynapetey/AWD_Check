import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import 'camera_screen.dart';
import 'vehicle_info_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
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

  void _processImage(BuildContext context, String imagePath) {
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Drivetrain: ${provider.vehicleData!['driveType']}"),
              Icon(
                isAwd ? Icons.check_circle : Icons.cancel,
                color: isAwd ? Colors.green : Colors.red,
                size: 50,
              ),
              Text(isAwd ? "AWD/4WD Detected" : "Standard Drivetrain"),
            ],
          );
        }

        return Center(
          child: ElevatedButton(
            onPressed: () {
              // Replace 'YOUR_EXTRACTED_VIN' with your ML Kit result
              Provider.of<VehicleProvider>(context, listen: false)
                  .fetchVehicleDetails('YOUR_EXTRACTED_VIN');
            }, 
            child: const Text("Scan VIN")
          ),
        );
      },
    ),
  );
}