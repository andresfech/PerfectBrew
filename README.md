# PerfectBrew ☕

A beautiful iOS app for coffee enthusiasts who want to perfect their V60 brewing technique.

## Features

### 🏠 Home Screen
- Clean, intuitive interface
- Quick access to start new brews or view history

### ⚙️ Brew Setup
- **Coffee Dose**: Adjustable from 10-40g with 0.5g precision
- **Water Amount**: 100-600ml with 10ml steps
- **Water Temperature**: 80-100°C with 1°C precision
- **Grind Size**: 1-10 scale for grind consistency
- **Brew Time**: Automatic calculation based on parameters

### ⏱️ Brewing Guide
- **Real-time Timer**: Countdown for total brew time and bloom phase
- **Step-by-step Instructions**: Clear V60 brewing steps
- **Haptic Feedback**: Notifications for each brewing phase
- **Pause/Reset Controls**: Full timer control

### ⭐ Feedback System
- **Taste Rating**: 1-5 star rating
- **Strength Rating**: 1-5 star rating  
- **Acidity Rating**: 1-5 star rating
- **Notes**: Free text field for detailed observations

### 📚 Brew History
- **Complete Brew Records**: All parameters and feedback saved
- **Detailed View**: Full breakdown of each brew session
- **Date Tracking**: Timestamp for each brew

## Technical Details

- **Platform**: iOS 16.0+
- **Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Storage**: AppStorage for local data persistence
- **Design**: Dark Mode support, modern UI

## Getting Started

1. Clone the repository
2. Open `PerfectBrew.xcodeproj` in Xcode
3. Select an iOS Simulator (iPhone 16 Pro recommended)
4. Build and run the project

## Project Structure

```
PerfectBrew/
├── PerfectBrewApp.swift          # Main app entry point
├── HomeScreen.swift              # Main navigation hub
├── BrewSetupScreen.swift         # Parameter configuration
├── BrewingGuideScreen.swift      # Timer and instructions
├── FeedbackScreen.swift          # Rating and notes
├── BrewHistoryScreen.swift       # Brew history list
├── BrewDetailScreen.swift        # Individual brew details
├── Brew.swift                    # Data model
├── StorageService.swift          # Data persistence
├── BrewSetupViewModel.swift      # Setup logic
└── BrewingGuideViewModel.swift   # Timer logic
```

## Brewing Method

This app is specifically designed for the V60 pour-over method, providing:
- Optimal water-to-coffee ratios
- Proper bloom timing (45 seconds)
- Multiple pour phases for even extraction
- Total brew time guidance (typically 3 minutes)

Perfect your coffee brewing technique with PerfectBrew! ☕✨
