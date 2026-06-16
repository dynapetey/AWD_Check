import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';


class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isInitialized = false;
  final TextEditingController _vinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _cameraController = CameraController(cameras.first, ResolutionPreset.high);
      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      final XFile image = await _cameraController!.takePicture();
      debugPrint('Picture taken: ${image.path}');
      // Add your OCR/VIN processing logic here
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      debugPrint('Image picked: ${image.path}');
      // Add your OCR/VIN processing logic here
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _vinController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('CAPTURE VIN', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFE50914)),
      ),
      body: _isInitialized && _cameraController!.value.isInitialized
          ? Stack(
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: _cameraController!.value.aspectRatio,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
                Positioned(
                  bottom: 120,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: TextField(
                      controller: _vinController,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      decoration: InputDecoration(
                        hintText: 'Scan or type VIN',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        icon: const Icon(Icons.edit, color: Color(0xFFE50914)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            if (_vinController.text.length == 17) {
                              Navigator.pop(context, _vinController.text);
                            }
                          },
                        ),
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator(color: Color(0xFFE50914))),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'gallery_button',
            onPressed: _pickImageFromGallery,
            backgroundColor: const Color(0xFF1A1A1A),
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'camera_capture_button',
            onPressed: _takePicture,
            backgroundColor: const Color(0xFFE50914),
            child: const Icon(Icons.camera_alt_rounded, size: 28),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}