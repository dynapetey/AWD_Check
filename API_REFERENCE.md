# 📖 API Reference - AWD or Not

Complete API documentation for all classes and methods in the app.

## Models

### VehicleData

Data class representing vehicle information extracted from VIN lookup.

```dart
class VehicleData {
  final String vin;           // 17-digit VIN
  final String? year;         // Model year (nullable)
  final String? make;         // Manufacturer (nullable)
  final String? model;        // Model name (nullable)
  final String? driveline;    // AWD/FWD/RWD etc (nullable)
```

#### Constructor

```dart
VehicleData({
  required String vin,
  String? year,
  String? make,
  String? model,
  String? driveline,
})
```

#### Factory Constructor

```dart
/// Creates VehicleData from JSON response
/// Typically used for NHTSA API responses
factory VehicleData.fromJson(Map<String, dynamic> json)
```

#### Computed Properties

```dart
/// Returns true if vehicle has AWD/4WD capability
/// Checks for "AWD", "4WD", "ALL-WHEEL" in driveline
bool get hasAWD

/// Returns human-readable AWD status
/// Returns "AWD/4WD" or "Not AWD/4WD" or "Unknown"
String get awdStatus
```

#### Example Usage

```dart
// Create from API response
final vehicleData = VehicleData.fromJson({
  'VIN': '5TDJKRFH7LS123456',
  'ModelYear': '2023',
  'Make': 'Toyota',
  'Model': 'Sienna',
  'DriveType': 'All-Wheel Drive',
});

print(vehicleData.hasAWD);      // true
print(vehicleData.awdStatus);   // "AWD/4WD"
```

---

## Services

### VinService

Main service handling VIN extraction and vehicle lookup.

```dart
class VinService {
  final TextRecognizer _textRecognizer;
  
  VinService()           // Constructor
  
  // Public Methods
  Future<String?> extractVinFromImage(String imagePath)
  Future<VehicleData?> lookupVehicle(String vin)
  Future<VehicleData?> processImage(String imagePath)
  
  // Lifecycle
  void dispose()         // Cleanup resources
}
```

#### extractVinFromImage

Extracts VIN from image using ML Kit text recognition.

```dart
Future<String?> extractVinFromImage(String imagePath)
```

**Parameters:**
- `imagePath` - File path to image containing VIN

**Returns:**
- `String?` - 17-digit VIN if found, null otherwise

**Throws:**
- Exception if image cannot be processed

**Example:**

```dart
try {
  final vin = await vinService.extractVinFromImage('/path/to/image.jpg');
  if (vin != null) {
    print('Found VIN: $vin');
  } else {
    print('No VIN found in image');
  }
} catch (e) {
  print('Error: $e');
}
```

#### lookupVehicle

Queries NHTSA API for vehicle data using VIN.

```dart
Future<VehicleData?> lookupVehicle(String vin)
```

**Parameters:**
- `vin` - 17-digit Vehicle Identification Number

**Returns:**
- `VehicleData?` - Vehicle data if found, null otherwise

**Throws:**
- Exception if VIN format is invalid
- Exception if API call fails
- Exception if VIN not found in NHTSA database

**Example:**

```dart
try {
  final vehicle = await vinService.lookupVehicle('5TDJKRFH7LS123456');
  if (vehicle != null) {
    print('${vehicle.year} ${vehicle.make} ${vehicle.model}');
    print('Has AWD: ${vehicle.hasAWD}');
  }
} catch (e) {
  print('Lookup failed: $e');
}
```

#### processImage

Complete pipeline: extract VIN from image and lookup vehicle.

```dart
Future<VehicleData?> processImage(String imagePath)
```

**Parameters:**
- `imagePath` - File path to image containing VIN

**Returns:**
- `VehicleData?` - Complete vehicle data if successful

**Throws:**
- Exception if VIN extraction fails
- Exception if vehicle lookup fails
- Exception if image cannot be processed

**Example:**

```dart
try {
  final vehicle = await vinService.processImage('/path/to/vin_photo.jpg');
  if (vehicle != null) {
    print('Found: ${vehicle.awdStatus}');
  }
} catch (e) {
  print('Processing failed: $e');
}
```

#### dispose

Cleans up ML Kit resources (must call before app closes).

```dart
void dispose()
```

**Example:**

```dart
@override
void dispose() {
  vinService.dispose();
  super.dispose();
}
```

---

## State Management

### VehicleProvider

Manages application state using Provider pattern.

```dart
class VehicleProvider extends ChangeNotifier {
  VehicleData? _vehicleData;
  bool _isLoading;
  String? _errorMessage;
  
  // Getters
  VehicleData? get vehicleData
  bool get isLoading
  String? get errorMessage
  
  // Methods
  Future<void> processImage(String imagePath)
  void reset()
  void dispose()
}
```

#### Getters

```dart
/// Current vehicle data (null if none loaded)
VehicleData? get vehicleData

/// True while image is being processed
bool get isLoading

/// Error message if last operation failed
String? get errorMessage
```

#### Methods

##### processImage

Process image and update state.

```dart
Future<void> processImage(String imagePath)
```

**Parameters:**
- `imagePath` - File path to image containing VIN

**Side Effects:**
- Sets `_isLoading = true`
- Clears previous `_errorMessage`
- Calls `notifyListeners()` to trigger UI update
- Updates `_vehicleData` on success
- Updates `_errorMessage` on failure
- Sets `_isLoading = false` when complete

**Example:**

```dart
// In UI
Consumer<VehicleProvider>(
  builder: (context, provider, _) {
    if (provider.isLoading) {
      return CircularProgressIndicator();
    }
    if (provider.errorMessage != null) {
      return Text('Error: ${provider.errorMessage}');
    }
    if (provider.vehicleData != null) {
      return VehicleInfoScreen(vehicleData: provider.vehicleData!);
    }
  },
)

// Trigger processing
context.read<VehicleProvider>().processImage(imagePath);
```

##### reset

Reset to initial state.

```dart
void reset()
```

**Side Effects:**
- Clears `_vehicleData`
- Clears `_errorMessage`
- Sets `_isLoading = false`
- Calls `notifyListeners()`

**Example:**

```dart
// Go back to home screen
context.read<VehicleProvider>().reset();
```

---

## Screens

### HomeScreen

Main application screen.

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) { }
}
```

**Features:**
- Displays "AWD or Not" title
- Shows "Take Photo" button
- Routes to VehicleInfoScreen when vehicle data available
- Uses Consumer widget to listen to provider changes

**Navigation:**
- On button tap → CameraScreen
- On image capture → Processing → VehicleInfoScreen (or error)

### CameraScreen

Camera capture and gallery selection.

```dart
class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);
  
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}
```

**Features:**
- Live camera preview
- Take photo button
- Gallery selection button
- Focus area guide
- Instruction overlay

**Returns:**
- Image file path as String when image selected
- null if user cancels

**Methods:**

```dart
/// Take photo with camera
Future<void> _takePicture()

/// Select photo from gallery
Future<void> _pickImageFromGallery()

/// Initialize camera controller
Future<void> _initializeCamera()
```

### VehicleInfoScreen

Displays vehicle information and AWD status.

```dart
class VehicleInfoScreen extends StatelessWidget {
  final VehicleData vehicleData;
  
  const VehicleInfoScreen({
    Key? key,
    required this.vehicleData,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) { }
}
```

**Parameters:**
- `vehicleData` - Vehicle data to display

**Features:**
- Color-coded AWD status badge
- Vehicle information cards
- Large, readable typography
- Scan another vehicle button

**Styling:**
- Green gradient for AWD vehicles
- Orange gradient for non-AWD vehicles

---

## Key Constants & Regex Patterns

```dart
// VIN Validation Regex
// Matches 17-digit VIN with valid characters
final vinRegex = RegExp(r'\b[A-HJ-NPR-Z0-9]{17}\b');

// NHTSA API Endpoint
const String nhtsaApiUrl = 'https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVin';

// Timeout for API calls
const Duration apiTimeout = Duration(seconds: 15);

// ML Kit Model size
const int mlKitModelSize = 150; // MB

// Image size limits
const int maxImageSize = 20; // MB
```

---

## Usage Examples

### Basic Example: Process Single Image

```dart
import 'package:awd_check/services/vin_service.dart';

Future<void> main() async {
  final vinService = VinService();
  
  try {
    // Process image
    final vehicle = await vinService.processImage('path/to/vin.jpg');
    
    if (vehicle != null) {
      print('${vehicle.year} ${vehicle.make} ${vehicle.model}');
      print('AWD: ${vehicle.hasAWD}');
    } else {
      print('VIN not found in image');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    vinService.dispose();
  }
}
```

### Advanced Example: Batch Processing

```dart
Future<void> processBatch(List<String> imagePaths) async {
  final vinService = VinService();
  final results = <VehicleData>[];
  
  try {
    for (final imagePath in imagePaths) {
      try {
        final vehicle = await vinService.processImage(imagePath);
        if (vehicle != null) {
          results.add(vehicle);
          print('Processed: ${vehicle.vin}');
        }
      } catch (e) {
        print('Failed to process $imagePath: $e');
      }
      // Add delay between requests
      await Future.delayed(Duration(seconds: 1));
    }
    
    print('Total processed: ${results.length}/${imagePaths.length}');
  } finally {
    vinService.dispose();
  }
}
```

### Widget Integration Example

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleProvider>(
      builder: (context, provider, child) {
        // Error state
        if (provider.errorMessage != null) {
          return ErrorWidget(message: provider.errorMessage!);
        }
        
        // Loading state
        if (provider.isLoading) {
          return LoadingWidget();
        }
        
        // Success state
        if (provider.vehicleData != null) {
          return SuccessWidget(vehicle: provider.vehicleData!);
        }
        
        // Empty state
        return EmptyWidget();
      },
    );
  }
}
```

---

## Error Codes & Messages

| Error | Cause | Solution |
|-------|-------|----------|
| "Camera permission denied" | User didn't grant camera permission | Request permission again |
| "Could not extract VIN from image" | ML Kit couldn't find text | Take clearer photo |
| "VIN must be 17 digits long" | Extracted VIN invalid format | Ensure VIN is fully visible |
| "VIN not found in database" | NHTSA doesn't have this VIN | Check VIN accuracy |
| "Failed to lookup VIN: 404" | API request failed | Check internet connection |
| "Failed to lookup VIN: 500" | Server error | Retry after delay |
| "Connection timeout" | API didn't respond in time | Check internet connection |

---

## Performance Notes

- **ML Kit Processing**: ~300-500ms per image
- **API Lookup**: ~1-2 seconds per request
- **Total Time**: ~2-3 seconds end-to-end
- **Memory**: ~150MB for ML Kit models on first use
- **Storage**: ~30MB for app + models
- **Network**: ~50KB per API request

---

## Dependencies Version Info

```
flutter: 3.0.0+
dart: 3.0.0+
camera: 0.10.5+
google_mlkit_text_recognition: 0.7.0
image_picker: 1.0.4
http: 1.1.0
provider: 6.0.0
image: 4.0.0
lottie: 2.4.0
```

---

## License & Attribution

- **ML Kit**: Google ML Kit Text Recognition
- **VIN Data**: NHTSA Public API
- **Flutter**: Google Flutter Framework

---

For more information, see:
- [README.md](README.md) - Project overview
- [DEVELOPMENT.md](DEVELOPMENT.md) - Development guide
- [ARCHITECTURE.md](ARCHITECTURE.md) - Architecture details
