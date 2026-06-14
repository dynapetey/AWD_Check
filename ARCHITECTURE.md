# 🏗️ AWD or Not - Architecture & Data Flow

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         FLUTTER APPLICATION                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │                    PRESENTATION LAYER                           │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │  │
│  │  │   Home       │  │   Camera     │  │  Vehicle     │          │  │
│  │  │   Screen     │→→│   Screen     │→→│  Info Screen │          │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘          │  │
│  └──────────────────────────┬───────────────────────────────────────┘  │
│                             │                                          │
│  ┌──────────────────────────▼───────────────────────────────────────┐  │
│  │                    STATE MANAGEMENT LAYER                       │  │
│  │         ┌─────────────────────────────────────┐                │  │
│  │         │     VehicleProvider                 │                │  │
│  │         │  (Provider Pattern)                 │                │  │
│  │         │  • vehicleData                      │                │  │
│  │         │  • isLoading                        │                │  │
│  │         │  • errorMessage                     │                │  │
│  │         └─────────────────────────────────────┘                │  │
│  └──────────────────────────┬───────────────────────────────────────┘  │
│                             │                                          │
│  ┌──────────────────────────▼───────────────────────────────────────┐  │
│  │                    SERVICE LAYER                                │  │
│  │  ┌──────────────────────────────────────────┐                  │  │
│  │  │           VinService                      │                  │  │
│  │  │  • extractVinFromImage()                  │                  │  │
│  │  │  • lookupVehicle()                        │                  │  │
│  │  │  • processImage()                         │                  │  │
│  │  └──────────────────────────────────────────┘                  │  │
│  └──────────────┬─────────────────────────┬──────────────────────────┘  │
│                 │                         │                            │
│  ┌──────────────▼──┐        ┌─────────────▼──┐                        │
│  │  ML Kit         │        │  HTTP Client    │                        │
│  │  Text           │        │  (http package) │                        │
│  │  Recognition    │        │                 │                        │
│  └──────────────┬──┘        └─────────────┬──┘                        │
│                 │                         │                            │
└─────────────────┼─────────────────────────┼───────────────────────────┘
                  │                         │
                  ▼                         ▼
         ┌──────────────────┐     ┌───────────────────┐
         │  Device Camera   │     │  NHTSA VIP API    │
         │  & Photo Library │     │  (Vehicle Data)   │
         └──────────────────┘     └───────────────────┘
```

## Component Interaction Diagram

```
USER INTERACTION
       │
       ▼
┌──────────────────┐
│ HomeScreen       │  ← User taps "Take Photo"
└─────────┬────────┘
          │
          ▼
┌──────────────────┐
│ CameraScreen     │  ← User captures/selects image
└─────────┬────────┘
          │ imagePath
          ▼
┌──────────────────────────────────────┐
│ VehicleProvider.processImage()        │
│ - Starts loading                      │
│ - Calls VinService.processImage()    │
└──────────┬──────────────────────────┘
           │
           ▼
┌──────────────────────────────────────┐
│ VinService.extractVinFromImage()      │
│ - Loads image                         │
│ - Uses ML Kit TextRecognizer          │
│ - Extracts VIN with regex             │
│ - Returns 17-digit VIN                │
└──────────┬──────────────────────────┘
           │ vin
           ▼
┌──────────────────────────────────────┐
│ VinService.lookupVehicle()            │
│ - Calls NHTSA API with VIN            │
│ - Parses response                     │
│ - Creates VehicleData object          │
└──────────┬──────────────────────────┘
           │ VehicleData
           ▼
┌──────────────────────────────────────┐
│ VehicleProvider                       │
│ - Updates _vehicleData                │
│ - Stops loading                       │
│ - Calls notifyListeners()             │
└──────────┬──────────────────────────┘
           │
           ▼
┌──────────────────────────────────────┐
│ VehicleInfoScreen (Consumer)          │
│ - Rebuilds with new data              │
│ - Displays vehicle info               │
│ - Shows AWD status badge              │
└──────────────────────────────────────┘
```

## Data Structure Diagram

```
┌─────────────────────────────────────────┐
│          VehicleData (Model)             │
├─────────────────────────────────────────┤
│ - vin: String (17 digits)               │
│ - year: String?                         │
│ - make: String?                         │
│ - model: String?                        │
│ - driveline: String?                    │
│                                          │
│ Methods:                                 │
│ + hasAWD: bool                           │
│ + awdStatus: String                      │
│ + fromJson(): VehicleData (factory)     │
└─────────────────────────────────────────┘
         │
         │ Used by
         ▼
┌─────────────────────────────────────────┐
│      VehicleProvider (State)             │
├─────────────────────────────────────────┤
│ - _vehicleData: VehicleData?             │
│ - _isLoading: bool                       │
│ - _errorMessage: String?                 │
│ - _vinService: VinService                │
│                                          │
│ Public Getters:                          │
│ + vehicleData                            │
│ + isLoading                              │
│ + errorMessage                           │
│                                          │
│ Public Methods:                          │
│ + processImage(String): Future<void>     │
│ + reset(): void                          │
└─────────────────────────────────────────┘
```

## VIN Extraction Process

```
                    IMAGE INPUT
                        │
                        ▼
            ┌────────────────────────┐
            │  Load image from disk  │
            │  using InputImage API  │
            └────────────┬───────────┘
                         │
                         ▼
            ┌────────────────────────┐
            │  ML Kit TextRecognizer │
            │  .processImage()       │
            └────────────┬───────────┘
                         │
         ┌───────────────┼───────────────┐
         ▼               ▼               ▼
    Blocks          Lines             Text
                        │
                        ▼
        ┌───────────────────────────────┐
        │ Regex: [A-HJ-NPR-Z0-9]{17}   │
        │ (Valid VIN characters)        │
        │ (Exactly 17 digits/letters)   │
        └───────────────┬───────────────┘
                        │
                ┌───────┴────────┐
                │                │
            Match?          No Match?
                │                │
                ▼                ▼
            Extract          Try full
            VIN              text search
                │                │
                └────────┬───────┘
                         │
                         ▼
                    VIN FOUND
                    (or null)
```

## API Lookup Process

```
        VIN: "5TDJKRFH7LS123456"
                  │
                  ▼
    ┌─────────────────────────────────────┐
    │ HTTP GET Request to NHTSA API       │
    │ URL: https://vpic.nhtsa.dot.gov/   │
    │      api/vehicles/DecodeVin/VIN    │
    └──────────────┬──────────────────────┘
                   │
                   ▼
        NHTSA API Response (JSON)
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
            ...
          ]
        }
                   │
                   ▼
    ┌─────────────────────────────────────┐
    │ Parse JSON Response                 │
    │ Convert to Dictionary               │
    │ Match Variables to Data             │
    └──────────────┬──────────────────────┘
                   │
                   ▼
    ┌─────────────────────────────────────┐
    │ VehicleData.fromJson()              │
    │ Create VehicleData object           │
    └──────────────┬──────────────────────┘
                   │
                   ▼
        VehicleData Object Created
        {
          vin: "5TDJKRFH7LS123456",
          year: "2023",
          make: "Toyota",
          model: "Sienna",
          driveline: "All-Wheel Drive"
        }
                   │
                   ▼
        hasAWD = true ✓
        awdStatus = "AWD/4WD" ✓
```

## UI State Flow

```
┌──────────────────────┐
│   Initial State      │
│  - vehicleData: null │
│  - isLoading: false  │
│  - error: null       │
│  SHOWS: Home Screen  │
└──────────┬───────────┘
           │ User: Take Photo
           ▼
┌──────────────────────┐
│   Processing State   │
│  - vehicleData: null │
│  - isLoading: true   │
│  - error: null       │
│  SHOWS: Loading      │
│         Dialog       │
└──────────┬───────────┘
           │
      ┌────┴────┬──────────┐
      │          │          │
   Success    Error      Timeout
      │          │          │
      ▼          ▼          ▼
┌─────────┐ ┌──────────┐ ┌──────────┐
│Success  │ │Error     │ │Timeout   │
│State    │ │State     │ │State     │
│SHOWS:   │ │SHOWS:    │ │SHOWS:    │
│Vehicle  │ │Error     │ │Error     │
│Info     │ │Message   │ │Message   │
└────┬────┘ └──────┬───┘ └────┬─────┘
     │ Reset    │ Retry   │ Retry
     └──────────┼─────────┘
                ▼
         ┌──────────────────────┐
         │  Back to Home Screen │
         │  - vehicleData: null │
         │  - isLoading: false  │
         │  - error: null       │
         └──────────────────────┘
```

## File Dependency Graph

```
main.dart
    ├── providers/vehicle_provider.dart
    │   └── services/vin_service.dart
    │       ├── models/vehicle_data.dart
    │       ├── google_mlkit_text_recognition (package)
    │       └── http (package)
    ├── screens/home_screen.dart
    │   ├── providers/vehicle_provider.dart
    │   └── screens/camera_screen.dart
    │       └── camera (package)
    │       └── image_picker (package)
    └── screens/vehicle_info_screen.dart
        ├── models/vehicle_data.dart
        └── providers/vehicle_provider.dart
```

## Permission Flow (Android)

```
User Grants Permissions
        │
        ├─→ CAMERA
        │   └─→ Can use device camera
        │
        ├─→ READ_EXTERNAL_STORAGE
        │   └─→ Can select photos from gallery
        │
        ├─→ WRITE_EXTERNAL_STORAGE
        │   └─→ Can save captured photos
        │
        └─→ INTERNET
            └─→ Can call NHTSA API
```

## Permission Flow (iOS)

```
User Grants Permissions
        │
        ├─→ Camera
        │   (NSCameraUsageDescription)
        │   └─→ Can use device camera
        │
        └─→ Photo Library
            (NSPhotoLibraryUsageDescription)
            └─→ Can select photos from gallery
```

## Release Build Process

```
Source Code (Dart)
        │
        ▼
┌───────────────────┐
│ Flutter Build     │
│ - Compile Dart    │
│ - Link native     │
│ - Optimize code   │
└────────┬──────────┘
         │
    ┌────┴────┐
    │          │
    ▼          ▼
Android      iOS
  │            │
  ├─→ APK    ├─→ App
  │   or      │   Binary
  ├─→ AAB    │
  │ (Bundle) │
  │          └─→ Archive
  ▼             │
Play Store    ▼
              App Store
```

## Error Handling Flow

```
         Error Occurs
              │
        ┌─────┴──────┐
        │             │
      Try      Catch Block
      Block        │
                   ▼
            Error Classified
            │
    ┌───────┼───────┬─────────┐
    │       │       │         │
Camera   Permission VIN    Network
Error     Error    Error    Error
    │       │       │         │
    ▼       ▼       ▼         ▼
  Show    Request  Suggest  Retry
  Error   Again    Better   Option
  Dialog  Dialog   Photo
```

---

## Summary

The app uses a clean, layered architecture with:

1. **Presentation Layer** - Flutter widgets (screens)
2. **State Layer** - Provider for state management
3. **Service Layer** - Business logic (VinService)
4. **Model Layer** - Data structures (VehicleData)
5. **External Services** - ML Kit (device) + NHTSA API (online)

This separation of concerns makes the code:
- Easy to test
- Easy to maintain
- Easy to extend
- Easy to debug

All components are loosely coupled and follow SOLID principles.
