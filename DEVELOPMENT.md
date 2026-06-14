# AWD or Not - Development Guide

## Architecture Overview

The app follows a clean, maintainable architecture:

```
┌─────────────────────────────────────────────┐
│           User Interface Layer               │
│  (Screens: Home, Camera, Vehicle Info)       │
└────────────────┬────────────────────────────┘
                 │
┌────────────────▼────────────────────────────┐
│        State Management Layer                │
│     (Provider - VehicleProvider)             │
└────────────────┬────────────────────────────┘
                 │
┌────────────────▼────────────────────────────┐
│         Service Layer                        │
│  (VinService: ML Kit + API Integration)      │
└────────────────┬────────────────────────────┘
                 │
┌────────────────▼────────────────────────────┐
│      Data & Model Layer                      │
│     (VehicleData - Domain Objects)           │
└─────────────────────────────────────────────┘
```

## File Structure

```
lib/
├── main.dart                          # App initialization & routing
├── models/
│   └── vehicle_data.dart             # Vehicle data model & logic
├── services/
│   └── vin_service.dart              # Core business logic (ML Kit + API)
├── providers/
│   └── vehicle_provider.dart         # State management with Provider
└── screens/
    ├── home_screen.dart              # Main screen
    ├── camera_screen.dart            # Camera capture UI
    └── vehicle_info_screen.dart      # Results display
```

## Key Components Explained

### 1. VehicleData Model (`models/vehicle_data.dart`)

Represents a vehicle with VIN and parsed data:

```dart
class VehicleData {
  final String vin;           // 17-digit VIN
  final String? year;         // Model year
  final String? make;         // Manufacturer
  final String? model;        // Model name
  final String? driveline;    // AWD, FWD, RWD, etc.
  
  // Helper methods
  bool get hasAWD { }         // Determines if vehicle has AWD
  String get awdStatus { }    // Returns human-readable status
}
```

### 2. VinService (`services/vin_service.dart`)

Core service handling image processing and API calls:

```dart
class VinService {
  // Extract VIN from image using ML Kit
  Future<String?> extractVinFromImage(String imagePath)
  
  // Lookup vehicle data from NHTSA API
  Future<VehicleData?> lookupVehicle(String vin)
  
  // Complete pipeline: image → VIN → vehicle data
  Future<VehicleData?> processImage(String imagePath)
}
```

**Key Methods:**

- `extractVinFromImage()` - Uses Google ML Kit to recognize text in image, extracts 17-digit VIN using regex
- `lookupVehicle()` - Calls NHTSA API with VIN, parses response into VehicleData
- `processImage()` - Orchestrates the full pipeline

### 3. VehicleProvider (`providers/vehicle_provider.dart`)

State management using Provider pattern:

```dart
class VehicleProvider extends ChangeNotifier {
  VehicleData? _vehicleData;      // Current vehicle
  bool _isLoading = false;         // Loading state
  String? _errorMessage = null;    // Error handling
  
  Future<void> processImage(String imagePath)  // Process image
  void reset()                     // Reset to home
}
```

**State Updates:**
1. `processImage()` sets `_isLoading = true`
2. Processes image asynchronously
3. Updates `_vehicleData` or `_errorMessage`
4. Calls `notifyListeners()` to update UI

### 4. HomeScreen (`screens/home_screen.dart`)

Main UI with conditional rendering:

```dart
Consumer<VehicleProvider>(
  builder: (context, provider, _) {
    if (provider.vehicleData != null) {
      return VehicleInfoScreen(...);  // Show results
    } else {
      return _buildMainScreen(...);    // Show main screen
    }
  }
)
```

### 5. CameraScreen (`screens/camera_screen.dart`)

Camera interface supporting:
- Live camera preview
- Take photo with camera
- Select photo from gallery
- Photo validation

### 6. VehicleInfoScreen (`screens/vehicle_info_screen.dart`)

Results display with:
- AWD/non-AWD status badge
- Vehicle details (year, make, model, driveline)
- VIN display
- "Scan Another" button

## Data Flow

```
[Home Screen] 
    ↓ User taps "Take Photo"
[Camera Screen]
    ↓ User captures/selects image
    ↓ Image path returned
[Home Screen] 
    ↓ Calls provider.processImage(imagePath)
[Vehicle Provider]
    ↓ Calls vinService.processImage(imagePath)
[VIN Service]
    ├→ ML Kit extracts VIN from image
    ├→ Validates 17-digit format
    └→ Calls NHTSA API with VIN
[NHTSA API] → Returns vehicle data
[VIN Service] → Returns VehicleData object
[Vehicle Provider] → Updates state & notifies listeners
[UI] → Renders VehicleInfoScreen with results
```

## Adding New Features

### Example: Add Vehicle Caching

```dart
// In vehicle_provider.dart
final Map<String, VehicleData> _cache = {};

Future<void> processImage(String imagePath) async {
  final vin = await _vinService.extractVinFromImage(imagePath);
  
  if (_cache.containsKey(vin)) {
    _vehicleData = _cache[vin];  // Use cache
    notifyListeners();
    return;
  }
  
  // ... normal flow ...
  _cache[vin] = _vehicleData;  // Store in cache
}
```

### Example: Add Barcode Scanning

```dart
// In vin_service.dart
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

Future<String?> scanBarcodeVin() async {
  try {
    String barcode = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    
    if (barcode.length == 17) {
      return barcode;  // Valid VIN
    }
  } catch (e) {
    print('Error scanning: $e');
  }
  return null;
}
```

### Example: Add Vehicle History

```dart
// In vehicle_provider.dart
List<VehicleData> _scanHistory = [];

Future<void> processImage(String imagePath) async {
  // ... processing ...
  if (_vehicleData != null) {
    _scanHistory.insert(0, _vehicleData!);  // Add to history
    notifyListeners();
  }
}

List<VehicleData> get scanHistory => _scanHistory;
```

## Testing

### Unit Tests

```dart
// test/services/vin_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:awd_check/services/vin_service.dart';

void main() {
  group('VinService', () {
    late VinService vinService;
    
    setUp(() {
      vinService = VinService();
    });
    
    test('extractVinFromImage returns valid VIN', () async {
      final vin = await vinService.extractVinFromImage('test_image.jpg');
      expect(vin, matches(RegExp(r'^[A-HJ-NPR-Z0-9]{17}$')));
    });
    
    test('lookupVehicle returns VehicleData', () async {
      final data = await vinService.lookupVehicle('5TDJKRFH7LS123456');
      expect(data?.make, equals('Toyota'));
    });
  });
}
```

### Widget Tests

```dart
// test/screens/home_screen_test.dart
void main() {
  testWidgets('HomeScreen shows Take Photo button', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
  });
}
```

## Performance Optimization

### Image Processing
```dart
// Compress image before ML Kit processing
final compressedImage = await compressImage(imagePath);
final vin = await _textRecognizer.processImage(
  InputImage.fromFilePath(compressedImage)
);
```

### API Caching
```dart
// Cache NHTSA responses
final Map<String, VehicleData> _apiCache = {};

Future<VehicleData?> lookupVehicle(String vin) async {
  if (_apiCache.containsKey(vin)) {
    return _apiCache[vin];
  }
  // ... fetch from API ...
  _apiCache[vin] = vehicleData;
  return vehicleData;
}
```

### Memory Management
```dart
// Dispose resources properly
@override
void dispose() {
  _textRecognizer.close();
  _cameraController.dispose();
  super.dispose();
}
```

## Debugging

### Enable Debug Logging

```dart
// In vin_service.dart
void _logDebug(String message) {
  if (kDebugMode) {
    print('[VinService] $message');
  }
}
```

### Check ML Kit Models

```dart
// Verify ML Kit is downloaded
adb shell pm dump com.example.awd_check | grep mlkit
```

### Monitor API Calls

```dart
// Add request/response logging
Future<VehicleData?> lookupVehicle(String vin) async {
  print('📡 API Request: VIN = $vin');
  final response = await http.get(...);
  print('📡 API Response: ${response.statusCode}');
  return VehicleData.fromJson(...);
}
```

## Best Practices

1. **Error Handling**: Always wrap API calls in try-catch
2. **Null Safety**: Use non-nullable types by default
3. **Resource Cleanup**: Dispose ML Kit and camera controllers
4. **User Feedback**: Show loading states and error messages
5. **VIN Validation**: Validate format before API lookup
6. **Image Validation**: Check image quality before processing

## Common Pitfalls

❌ **Not disposing resources:**
```dart
// BAD
_textRecognizer = TextRecognizer();

// GOOD
@override
void dispose() {
  _textRecognizer.close();
  super.dispose();
}
```

❌ **Ignoring null values:**
```dart
// BAD
String year = vehicleData.year;

// GOOD
String year = vehicleData.year ?? 'Unknown';
```

❌ **Not handling API errors:**
```dart
// BAD
final response = await http.get(url);
final data = jsonDecode(response.body);

// GOOD
if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
} else {
  throw Exception('API Error: ${response.statusCode}');
}
```

## Production Considerations

- ✅ Implement error analytics (Firebase Crashlytics)
- ✅ Add rate limiting for API calls
- ✅ Implement proper logging system
- ✅ Add user authentication if needed
- ✅ Use secure storage for sensitive data
- ✅ Implement analytics tracking
- ✅ Add offline capability
- ✅ Set up CI/CD pipeline

---

**Happy coding! 🚀**
