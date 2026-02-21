# Waky

A one-feature iOS app that **calculates the best time for you to wake up** using 90-minute sleep cycles. Wake at the end of a cycle to feel less groggy.

## UI inspiration

The app uses a warm, minimal style inspired by your references:

- **Background:** Cream/off-white
- **Accents:** Orange for primary actions and highlights
- **Cards:** Rounded rectangles, subtle borders when selected
- **Mascot:** Candle character (avatar) — add your asset to use it in-app

## Run in Simulator

- **From Xcode:** Open `Waky.xcodeproj`, choose an iPhone simulator (e.g. iPhone 16), press **⌘R**.
- **Hot reload:** The project uses [Inject](https://github.com/krzysztofzablocki/Inject) for live code injection. To use it:
  1. Install **InjectionIII** from the [Mac App Store](https://apps.apple.com/app/injectioniii/id1380446739) or [GitHub releases](https://github.com/johnno1962/InjectionIII/releases) and place it in `/Applications`.
  2. Run your app in the **iOS Simulator** (⌘R in Xcode).
  3. Open the **InjectionIII** app → **Open Project** → select `Waky.xcodeproj`.
  4. Edit any SwiftUI view, save the file; InjectionIII will inject the change into the running app so you see updates without a full rebuild.

## Setup in Xcode

1. Open **Waky.xcodeproj** in Xcode (the project is already set up).

2. **Assets**
   - **App icon:** In `Assets.xcassets` → **AppIcon**, add your 1024×1024 app icon (e.g. the candle character).
   - **Candle avatar:** In `Assets.xcassets` → **CandleAvatar**, add your candle mascot image (1x, 2x, 3x). If this asset is missing, the app shows a simple placeholder candle.

## Session tracker

The main screen shows a **Session tracker** card with your last session (e.g. "9:00 PM → 6:00 AM") and total session count.

## Project structure

```
Waky/
├── WakyApp.swift          # App entry
├── ContentView.swift       # Root view (hosts WakeTimeView)
├── Theme/
│   └── Theme.swift        # Colors and layout constants
├── Models/
│   ├── WakeTimeCalculator.swift
│   └── SleepSession.swift  # Session model + SessionStore
├── Views/
│   ├── WakeTimeView.swift
│   ├── SessionTrackerCard.swift  # Last session + count on main screen
│   ├── SleepSessionView.swift
│   ├── CandleMascotView.swift
│   └── CommitContractView.swift
└── Assets.xcassets
```

## Requirements

- iOS 15+
- Xcode 13+
- Swift 5.5+
