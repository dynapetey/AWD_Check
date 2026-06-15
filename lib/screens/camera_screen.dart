class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isFrontCamera = false;
  bool _isInitialized = false;

  // 1. Controller for manual entry and editing
  final TextEditingController _vinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 2. Populate if an initial VIN is passed (for error corrections)
    // Note: Ensure CameraScreen widget accepts a String? initialVin parameter
    // _vinController.text = widget.initialVin ?? ''; 
    
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _vinController.dispose(); // Always dispose controllers
    _cameraController?.dispose();
    super.dispose();
  }

  // ... (keep your existing _initializeCamera, _takePicture, _pickImageFromGallery methods)

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
                CameraPreview(_cameraController!),
                // ... (your existing instruction and focus box overlays)
                
                // 3. Persistent Manual/Edit Entry Field
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