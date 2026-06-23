# AWD or Not - VIN Scanner App

A cross-platform Flutter app that scans Vehicle Identification Numbers (VINs) from photos and checks if a vehicle has All-Wheel Drive (AWD) or 4-Wheel Drive (4WD).

## Features

✅ **Photo Capture** - Take photos or select from gallery
✅ **VIN Extraction** - Automatically extract 17-digit VIN using Gemini vision OCR
✅ **Vehicle Lookup** - Query NHTSA database for vehicle details
✅ **AWD Detection** - Displays whether the vehicle has AWD/4WD
✅ **Vehicle Information** - Shows year, make, model, and driveline type
✅ **Cross-Platform** - Runs on both iOS and Android

## How It Works

1. **Home Screen** - Press "Take Photo" to start
2. **Camera Capture** - Point camera at VIN (usually on dashboard or door jamb) and capture image
3. **VIN Extraction** - Gemini extracts the 17-digit VIN from the image
4. **API Lookup** - NHTSA API is queried with the VIN
5. **Results Display** - Vehicle details and AWD status are displayed

## Prerequisites

- Flutter SDK (3.0.0+)
- Dart SDK (included with Flutter)
- Android Studio (for Android development) or Xcode (for iOS)
- Physical device or emulator with camera

## Installation & Setup

### 1. Get Dependencies

```bash
cd AWD_Check
flutter pub get
```

### 2. Configure Platform-Specific Settings

### 2a. Configure Gemini OCR

Gemini OCR requires an API key passed at runtime.

For VS Code:

1. Copy [.vscode/dart_defines.example.json](.vscode/dart_defines.example.json) to `.vscode/dart_defines.local.json`
2. Put your real Gemini key in that local file
3. Use the included launch configuration named `AWD_Check (Gemini OCR)`

The local `.vscode/dart_defines.local.json` file is gitignored, so the key stays out of the repo.

For CLI runs, pass the key with:

```bash
flutter run --dart-define=GEMINI_API_KEY=your_api_key_here
```

For release builds, pass the same define:

```bash
flutter build appbundle --dart-define=GEMINI_API_KEY=your_api_key_here
```

#### Android Setup

The AndroidManifest.xml is already configured with required permissions:
- `CAMERA` - For camera access
- `INTERNET` - For API calls
- `READ/WRITE_EXTERNAL_STORAGE` - For image handling

No additional configuration needed!

#### iOS Setup

The Info.plist is pre-configured with required permissions:
- `NSCameraUsageDescription` - Camera access message
- `NSPhotoLibraryUsageDescription` - Photo library access message

Run iOS setup:
```bash
cd ios
pod install
cd ..
```

### 3. Run the App

#### On Android
```bash
flutter run -d android
```

#### On iOS
```bash
flutter run -d ios
```

#### On iOS Simulator
```bash
flutter run -d "iPhone 15 Pro"
```

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── models/
│   └── vehicle_data.dart         # Vehicle data model
├── services/
│   └── vin_service.dart          # VIN extraction & API integration
├── providers/
│   └── vehicle_provider.dart     # State management
└── screens/
    ├── home_screen.dart          # Main screen
    ├── camera_screen.dart        # Camera capture
    └── vehicle_info_screen.dart  # Results display

android/                           # Android configuration
ios/                              # iOS configuration
pubspec.yaml                      # Dependencies
```

## Dependencies

- **camera** (0.10.5+) - Camera functionality
- Gemini API via **http** - OCR for VIN extraction
- **image_picker** (1.0.4) - Photo gallery access
- **http** (1.1.0) - HTTP requests to NHTSA API
- **provider** (6.0.0) - State management
- **image** (4.0.0) - Image processing
- **lottie** (2.4.0) - Animation support

## API Integration

### NHTSA VIN Decoder API

The app uses the free National Highway Traffic Safety Administration VIN Decoder:
- **Endpoint**: `https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVin/{vin}`
- **Format**: JSON
- **Rate Limit**: No official limit (but be reasonable)
- **Response Time**: Usually < 1 second

Example Response:
```json
{
  "Results": [
    {
      "Variable": "ModelYear",
      "Value": "2023"
    },
    {
      "Variable": "Make",
      "Value": "Toyota"
    },
    {
      "Variable": "Model",
      "Value": "RAV4"
    },
    {
      "Variable": "DriveType",
      "Value": "All-Wheel Drive"
    }
  ]
}
```

## Gemini OCR

The app uses Gemini vision OCR for VIN extraction:
- Internet connection required for OCR
- No native ML Kit packaging in Android release builds
- Prompt-constrained to return a single 17-character VIN when detected

## Testing

### Test VINs

You can use these real VINs to test:
- `5TDJKRFH7LS123456` - Toyota Sienna (has AWD)
- `1HGCV1F32LA123456` - Honda Civic (FWD)
- `JTDKN3AU5D0123456` - Toyota Corolla

### Manual Testing Steps

1. Open app → "Take Photo" button
2. Either:
   - Take a new photo with camera
   - Select an image with a VIN from gallery
3. Image processes automatically
4. Results display with vehicle info and AWD status

## Troubleshooting

### Camera Permission Denied
- **Android**: Go to Settings → Apps → AWD or Not → Permissions → Grant Camera
- **iOS**: Go to Settings → Privacy → Camera → Enable AWD or Not

### "VIN not found" Error
- Make sure the VIN is clearly visible in the photo
- VIN must be readable (not blurred)
- Only 17-digit VINs are supported

### Gemini OCR Not Working
- Ensure `GEMINI_API_KEY` is provided with `--dart-define`
- Ensure internet connection is available
- Check that the selected image clearly shows the VIN

### App Crashes on Image Selection
- Ensure image is < 20MB
- Try a different image
- Restart the app

## Build for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (for Google Play)
```bash
flutter build appbundle --release
```

### iOS Build
```bash
flutter build ios --release
```

## Future Enhancements

- 🔋 Caching of VIN lookups
- 🌙 Dark mode support
- 📊 History of scanned vehicles
- 🔐 Offline VIN validation
- 🎯 Barcode/QR code scanning
- 🗺️ Location tracking
- 📱 Widget for quick scanning

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is open source and available under the MIT License.

## Support

For issues or questions, please open an issue on the repository.

---

**Made with ❤️ using Flutter**
