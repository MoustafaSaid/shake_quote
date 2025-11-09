# Shake Quote - Shake for Motivation

A beautiful Flutter mobile application that displays inspirational quotes. Simply shake your device to get a new motivational quote with smooth animations and haptic feedback.

## 📱 Features

- **Shake Detection**: Shake your device to get a new random quote
- **Beautiful UI**: Gradient background with smooth animations
- **Haptic Feedback**: Tactile response when shaking
- **Smooth Animations**: Scale and opacity transitions when quotes change
- **Curated Quotes**: Collection of inspirational quotes from famous personalities
- **Cross-Platform**: Works on both iOS and Android

## 🎨 Screenshots

The app features:
- Gradient background (blue to purple)
- Centered quote display with elegant card design
- Animated transitions when quotes change
- Clean, modern interface

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Physical device or emulator with shake detection support

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd shake_quote
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## 📖 How to Use

1. Launch the app
2. A motivational quote will be displayed automatically
3. Shake your device to get a new random quote
4. Enjoy the smooth animations and haptic feedback

## 🛠️ Technical Details

### Architecture

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: StatefulWidget with setState
- **Platform Channels**: Native shake detection via MethodChannel and EventChannel

### Key Components

- `ShakeQuoteApp`: Main application widget
- `_ShakeQuoteAppState`: State management with animation controllers
- Native shake detection implementation for iOS and Android

### Native Integration

The app uses platform channels to communicate with native code:
- **EventChannel**: `com.example.shakequote/shake` - Receives shake events
- **MethodChannel**: `com.example.shakequote/control` - Controls shake detection

### Animations

- **Scale Animation**: Quote card scales down and back up during transitions
- **Opacity Animation**: Smooth fade out/in effect when changing quotes
- **Duration**: 400ms with easeOut/easeInOut curves

## 📝 Quotes Collection

The app includes quotes from:
- Theodore Roosevelt
- Steve Jobs
- Winston Churchill
- Nelson Mandela
- Mark Twain
- And many more inspirational figures

## 🔧 Platform-Specific Setup

### Android

The app requires shake detection permissions and sensor access. The native implementation is in:
- `android/app/src/main/kotlin/com/example/shake_quote/MainActivity.kt`

### iOS

Shake detection is implemented in:
- `ios/Runner/AppDelegate.swift`

## 📦 Dependencies

- `flutter`: SDK
- `cupertino_icons: ^1.0.8`: iOS-style icons

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 📄 License

This project is a Flutter application template.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Contact

For questions or suggestions, please open an issue on the repository.

---

**Note**: This app requires a physical device or emulator with accelerometer support to detect shake gestures. The shake detection may not work in all emulators.
