# AWD or Not - Quick Start Guide

## 📱 What This App Does

This Flutter app lets you take a photo of a vehicle's VIN (Vehicle Identification Number) and instantly discover:
- ✅ Vehicle Year, Make, and Model
- ✅ Whether the vehicle has AWD (All-Wheel Drive) or 4WD
- ✅ Driveline type (Rear-Wheel Drive, Front-Wheel Drive, etc.)

## 🚀 Getting Started

### Step 1: Install Flutter

If you don't have Flutter installed:

**macOS/Linux:**
```bash
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor
```

**Windows:**
Download from: https://flutter.dev/docs/get-started/install/windows

### Step 2: Clone & Setup Project

```bash
cd AWD_Check
flutter pub get
```

### Step 3: Connect Device or Start Emulator

**Android Emulator:**
```bash
flutter emulators --launch Pixel_4_API_30
```

**iOS Simulator:**
```bash
open -a Simulator
```

**Physical Device:**
- Connect via USB cable
- Enable developer mode
- Allow USB debugging

### Step 4: Run the App

```bash
flutter run
```

Or for specific device:
```bash
flutter run -d <device_id>
flutter run -d "iPhone 15 Pro"  # iOS
flutter run -d "emulator-5554"  # Android
```

## 📸 Using the App

1. **Home Screen**: Tap the blue **"Take Photo"** button
2. **Camera Screen**: 
   - Point at vehicle's VIN (usually on dashboard or door jamb)
   - Tap the **camera icon** to capture
   - Or tap **gallery icon** to select from photos
3. **Processing**: App extracts VIN using AI and looks it up
4. **Results**: See vehicle info and AWD status

## 🎯 VIN Location on Vehicle

The VIN plate is usually located at:
- Dashboard (driver side, visible through windshield)
- Driver door jamb (inside edge when door is open)
- Engine block
- Title/Registration documents

## 🔍 How It Works Under the Hood

```
Take Photo → ML Kit Extracts VIN → NHTSA API Lookup → Display Results
```

1. **ML Kit Text Recognition** - On-device image processing extracts 17-digit VIN
2. **NHTSA VIN Decoder** - Free government API provides vehicle data
3. **Smart Analysis** - App determines AWD/4WD status from driveline data

## 📋 Project Files Explained

| File | Purpose |
|------|---------|
| `main.dart` | App entry point and setup |
| `screens/home_screen.dart` | Main screen with "Take Photo" button |
| `screens/camera_screen.dart` | Camera & gallery interface |
| `screens/vehicle_info_screen.dart` | Results display |
| `services/vin_service.dart` | VIN extraction & API integration |
| `models/vehicle_data.dart` | Data structures |
| `providers/vehicle_provider.dart` | State management |

## 🛠️ Development Commands

**Check for issues:**
```bash
flutter analyze
```

**Format code:**
```bash
dart format lib/
```

**Run tests:**
```bash
flutter test
```

**Build for release:**

Android:
```bash
flutter build apk --release
flutter build appbundle --release  # For Google Play
```

iOS:
```bash
flutter build ios --release
```

## 🧪 Test with Sample VINs

Try these real vehicle VINs:
- `5TDJKRFH7LS123456` - Toyota Sienna AWD
- `WBADT43422G808595` - BMW 328i RWD
- `JTDKN3AU5D0123456` - Toyota Corolla FWD

## 🐛 Troubleshooting

### "flutter: command not found"
Add Flutter to your PATH:
```bash
export PATH="$PATH:~/flutter/bin"
```

### Camera permission issues
- Ensure you granted camera permissions in app settings
- On iOS: Settings → Privacy → Camera → Enable app
- On Android: Settings → Apps → AWD or Not → Permissions

### "VIN not found" error
- Ensure VIN is clearly visible and readable
- Try adjusting lighting or angle
- Only 17-digit VINs work (not partial VINs)

### ML Kit not extracting text
- Ensure image is clear and in focus
- VIN plate should fill 30-50% of image
- Avoid shadows or reflections

### Build errors
```bash
flutter clean
flutter pub get
flutter run
```

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [ML Kit Documentation](https://developers.google.com/ml-kit)
- [NHTSA VIN Decoder API](https://vpic.nhtsa.dot.gov/api/)
- [VIN Format Explanation](https://en.wikipedia.org/wiki/Vehicle_identification_number)

## 🚀 Next Steps

Once the app runs:
1. Test with provided sample VINs
2. Try scanning your own vehicle's VIN
3. Explore code to understand Flutter structure
4. Customize UI colors and fonts
5. Add features like caching or history tracking

## 💡 Tips

- Use good lighting when taking VIN photos
- Keep VIN plate perpendicular to camera
- Take multiple photos if first one fails
- Gallery selection works great for existing VIN photos

## 🤝 Need Help?

Common issues are usually:
1. Flutter/dependencies not installed correctly → Run `flutter pub get`
2. Camera permissions not granted → Check app settings
3. VIN not extracting well → Adjust photo angle/lighting
4. API not responding → Check internet connection

---

**Happy scanning! 📸🚗**
