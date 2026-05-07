# Smart AI Voice Car Controller 🚗🤖

> **Flutter iOS App** — Control a smart car with Arabic & English voice commands via AI + MQTT

---

## 📱 App Overview

| Feature | Detail |
|---|---|
| **Platform** | iOS (iPhone) |
| **Framework** | Flutter 3.x |
| **State Management** | Provider |
| **Voice** | Arabic (ar-EG) + English (en-US) |
| **AI Backend** | Flask + Scikit-learn NLP |
| **Car Protocol** | MQTT → ESP8266 → Arduino |
| **Theme** | Cyberpunk Dark / Neon Cyan |

---

## 🗂️ Project Structure

```
smart_car_controller/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── screens/
│   │   ├── splash_screen.dart       # Animated splash
│   │   ├── home_screen.dart         # Main dashboard
│   │   └── settings_screen.dart     # Configuration
│   ├── services/
│   │   ├── api_service.dart         # Flask REST client
│   │   └── voice_service.dart       # Speech recognition
│   ├── models/
│   │   └── prediction_model.dart    # API data models
│   ├── providers/
│   │   └── app_provider.dart        # Global state
│   ├── widgets/
│   │   ├── mic_button.dart          # Animated mic
│   │   ├── command_card.dart        # AI result card
│   │   ├── status_indicator.dart    # Connection badges
│   │   └── manual_controls.dart     # D-pad controls
│   └── utils/
│       ├── constants.dart           # App constants
│       └── app_theme.dart           # Cyberpunk theme
├── ios/
│   └── Runner/
│       └── Info.plist               # iOS permissions
├── assets/
│   ├── images/                      # App images
│   └── animations/                  # Lottie files
└── pubspec.yaml
```

---

## ⚙️ Setup Instructions

### Step 1 — Prerequisites

Make sure you have installed:
- Flutter SDK ≥ 3.0 → https://flutter.dev/docs/get-started/install
- Xcode (for iOS builds)
- CocoaPods: `sudo gem install cocoapods`

### Step 2 — Install Dependencies

```bash
cd smart_car_controller
flutter pub get
cd ios && pod install && cd ..
```

### Step 3 — Configure Backend URL

1. Start your Flask backend and expose it with **ngrok**:
   ```bash
   ngrok http 5000
   ```
2. Copy the ngrok URL (e.g. `https://abc123.ngrok-free.app`)
3. Open the app → **Settings** → paste the URL → **SAVE URL** → **TEST CONNECTION**

### Step 4 — Run on iOS

```bash
flutter run --release
```
Or open in Xcode:
```bash
open ios/Runner.xcworkspace
```

---

## 🎤 Voice Commands

### Arabic (ar-EG)
| Say | Command Sent |
|---|---|
| امشي قدام / روح قدام | `FORWARD` |
| ارجع ورا / روح ورا | `BACKWARD` |
| لف يمين / دور يمين | `RIGHT` |
| لف شمال / دور شمال | `LEFT` |
| قف / وقف / اوقف | `STOP` |

### English (en-US)
| Say | Command Sent |
|---|---|
| go forward / move forward | `FORWARD` |
| go backward / move back | `BACKWARD` |
| turn right | `RIGHT` |
| turn left | `LEFT` |
| stop / halt | `STOP` |

---

## 🔌 API Reference

### POST `/predict`
```json
// Request
{ "text": "امشي قدام" }

// Response
{
  "input": "امشي قدام",
  "clean_text": "امشي قدام",
  "intent": "forward",
  "command": "FORWARD",
  "confidence": 98.5,
  "low_confidence": false,
  "mqtt_sent": true
}
```

### GET `/status`
```json
{
  "model_loaded": true,
  "mqtt_connected": true,
  "threshold": 60.0,
  "mqtt_stats": { "sent": 12, "failed": 0, "last": "FORWARD", "last_time": "14:22:03" }
}
```

### POST `/test`
```json
// Request
{ "command": "STOP" }

// Response
{ "command": "STOP", "sent": true }
```

---

## 📦 Packages Used

| Package | Purpose |
|---|---|
| `provider` | State management |
| `speech_to_text` | Voice recognition |
| `http` | REST API calls |
| `shared_preferences` | Persistent settings |
| `flutter_animate` | Smooth animations |
| `lottie` | Lottie animations |
| `permission_handler` | iOS permissions |
| `google_fonts` | Orbitron + Exo2 fonts |

---

## 🔑 iOS Permissions (Info.plist)

Already configured in `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Smart Car AI needs microphone access to listen to voice commands...</string>

<key>NSSpeechRecognitionUsageDescription</key>
<string>Smart Car AI uses speech recognition to convert voice commands...</string>
```

---

## 🏗️ System Architecture

```
iPhone (Flutter App)
        │
        │  POST /predict  {"text": "امشي قدام"}
        ▼
Flask AI Backend (Python)
        │
        │  NLP Model → Intent: forward → Command: FORWARD
        │
        │  MQTT Publish (HiveMQ Cloud, TLS 8883)
        ▼
ESP8266 (Arduino)
        │
        │  Serial Commands
        ▼
Smart Car Motors (L298N Driver)
```

---

## 🎨 UI Screens

| Screen | Description |
|---|---|
| **Splash** | Animated car logo + system init |
| **Voice Tab** | Mic button, waveform, live text, AI result |
| **Manual Tab** | D-pad for direct MQTT commands |
| **History Tab** | Command log with timestamps |
| **Settings** | URL config, connection test, theme, language |

---

## 🐛 Troubleshooting

| Problem | Solution |
|---|---|
| `No speech detected` | Speak clearly, check mic permission in iOS Settings |
| `Cannot reach backend` | Check ngrok URL in Settings, ensure Flask is running |
| `MQTT not connected` | Verify HiveMQ credentials in `app.py`, check broker status |
| `Model not loaded` | Run `python app.py` and check `models/nlp_intent_model.joblib` exists |
| `Low confidence` | STOP command is sent automatically as safety measure |

---

## 👨‍💻 Team

**Menoufia National University — Faculty of Computers & Artificial Intelligence**  
Level 3 · Semester 2 · IoT Protocols  
Supervisor: Dr. Ahmed Ali Rassas

---

*Smart Car AI — v1.0.0*
