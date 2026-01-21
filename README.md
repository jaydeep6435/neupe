# NeuPe (PhonePe-style Payments Clone) — Flutter + Supabase

A Flutter payments app prototype inspired by PhonePe, focused on a fast **Send Money** flow that supports **arithmetic amount entry** (e.g., `200+50-10`) and evaluates it into a final payable amount before confirmation.

## Highlights

- **Arithmetic Send Money**: enter expressions like `250+75-20`, `100*2`, `500/2` and auto-calculate the final amount.
- **UPI-style payment flow**: amount entry → confirm → UPI PIN sheet → success.
- **Contacts-based transfers**: discover/select contacts (with Android native fallback via MethodChannel).
- **QR Scan to Pay**: scan QR codes with camera controls.
- **Transaction UI**: chat-style transaction timeline and history screens.
- **Profile + UPI PIN setup**.

## Tech Stack

Flutter, Dart, Provider, Supabase (PostgreSQL + Auth), Android (Kotlin), Flutter MethodChannel, Camera/QR scanning, Contacts + Permissions

## Project Structure (key files)

- `lib/main.dart` — app entry, bootstrapping, routing
- `lib/screens/home_screen.dart` — home/dashboard UI
- `lib/screens/transfer/amount_input_page.dart` — arithmetic amount entry + evaluation
- `lib/widgets/custom_numeric_keyboard.dart` — custom keypad for amount/operator input
- `lib/screens/transfer/amount_confirm_page.dart` — confirmation screen
- `lib/screens/transfer/upi_pin_sheet.dart` — UPI PIN bottom sheet
- `lib/services/supabase_service.dart` — Supabase data access
- `lib/services/auth_service.dart` — authentication layer
- `lib/providers/*` — Provider-based state management
- `android/app/src/main/kotlin/**/MainActivity.kt` — native Android integration (contacts fallback)

## Getting Started

### Prerequisites

- Flutter SDK (stable)
- Android Studio (Android SDK + emulator) or a physical Android device
- A Supabase project (URL + Anon Key)

### Install dependencies

```bash
flutter pub get
```

### Configure Supabase

This project expects Supabase to be initialized in the app (commonly in `main.dart` or a service/config). Provide your **Supabase URL** and **Anon Key** where the project initializes Supabase.

If you prefer environment-style config, you can run with `--dart-define`:

```bash
flutter run --dart-define=SUPABASE_URL=YOUR_URL --dart-define=SUPABASE_ANON_KEY=YOUR_KEY
```

### Run

```bash
flutter run
```

## Core Feature: Arithmetic Amount Entry

The send-money amount field supports arithmetic operators (`+`, `-`, `*`, `/`) and evaluates with correct precedence (e.g., `10+2*3 = 16`).

Implementation lives in:

- `lib/screens/transfer/amount_input_page.dart`
	- tokenization + expression evaluation (operator precedence)
	- validation + trimming trailing operators
	- formatted display for evaluated amount

## Build

### Android APK (debug)

```bash
flutter build apk --debug
```

### Android APK (release)

```bash
flutter build apk --release
```

## Notes / Limitations

- This is a learning/demo prototype and is **not** a production-grade payments app.
- Ensure your Supabase tables and Row Level Security (RLS) policies match your app logic.

## License

Add your preferred license here (MIT/Apache-2.0/etc.).
