import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  bool _isFrontCamera = false;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (camera) =>
            camera.lensDirection ==
            (_isFrontCamera
                ? CameraLensDirection.front
                : CameraLensDirection.back),
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController.initialize();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing camera: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing camera: $e'),
            backgroundColor: const Color(0xFFE50914), // Themed Snackbar
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _cameraController.takePicture();
      if (mounted) {
        Navigator.pop(context, image.path);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error taking picture: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking picture: $e'),
            backgroundColor: const Color(0xFFE50914),
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
      );

      if (image != null && mounted) {
        Navigator.pop(context, image.path);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: const Color(0xFFE50914),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: AppBar(
        title: const Text(
          'CAPTURE VIN',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A1A), // Dark grey like home
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFE50914)), // Red back arrow
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_cameraController),
                // Instruction overlay
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.black.withValues(alpha: 0.6),
                    child: const Text(
                      'Point camera at VIN number\n(usually on dashboard or door jamb)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                // Focus area guide
                Positioned(
                  left: 24,
                  right: 24,
                  top: 150,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFE50914), // Red highlight
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE50914), // Red loader
              ),
            );
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'gallery_button',
            onPressed: _pickImageFromGallery,
            backgroundColor: const Color(0xFF1A1A1A), // Dark Grey
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'camera_capture_button',
            onPressed: _takePicture,
            backgroundColor: const Color(0xFFE50914), // Red
            foregroundColor: Colors.white,
            child: const Icon(Icons.camera_alt_rounded, size: 28),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
