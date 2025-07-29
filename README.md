# ScanIt - Sustainability App

A Flutter-based sustainability app that helps users properly sort household items for recycling and reuse using AI-powered image classification.

## 🌱 App Overview

ScanIt is designed to solve the common problem of waste management confusion by providing users with:
- **AI Image Classification**: Uses Google Gemini Vision API to identify items and categorize them
- **Creative Reuse Suggestions**: Provides 3 unique reuse ideas for each item
- **Sustainability Scoring**: Gamifies eco-friendly behavior with a scoring system
- **Educational Content**: Teaches proper disposal methods and environmental impact

## 🎯 Core Problem Solved

- **Waste Management Confusion**: Helps users understand what can be recycled vs. trashed
- **Sustainability Education**: Teaches creative reuse ideas to reduce waste
- **Environmental Impact Tracking**: Gamifies sustainable behavior with scoring system

## 📱 Main Screens

1. **Home Screen** (`home_screen.dart`) - Camera/gallery upload, main entry point
2. **Result Screen** (`result_screen.dart`) - Shows classification results and reuse ideas
3. **Score Screen** (`score_screen.dart`) - Sustainability score tracking and achievements
4. **History Screen** (`history_screen.dart`) - Past sorted items with filtering
5. **Settings Screen** (`settings_screen.dart`) - App information and data management

## 🚀 Core Features

### 1. AI Image Classification
- Uses Google Gemini 1.5 Flash Vision API to identify objects
- Categorizes items into: plastic, glass, compost, landfill, e-waste
- Provides detailed descriptions and disposal instructions

### 2. Creative Reuse Suggestions
- Generates 3 unique reuse ideas for each item
- Encourages users to extend item lifecycle before disposal
- Promotes sustainable consumption habits

### 3. Sustainability Scoring System
- Tracks user's eco-friendly actions with gamification
- Awards points based on item category (compost: 20, e-waste: 25, glass: 15, plastic: 10, landfill: 5)
- Features achievement system and progress levels
- Maintains daily streaks for consistent engagement

## 🛠 Technical Implementation

### Architecture
- **Framework**: Flutter (Dart)
- **State Management**: Built-in Flutter state management
- **Local Storage**: SharedPreferences for data persistence
- **Secure Storage**: Flutter Secure Storage for sensitive data
- **AI Integration**: Google Generative AI (Gemini 1.5 Flash)

### Key Dependencies
```yaml
dependencies:
  flutter: sdk: flutter
  google_generative_ai: ^0.3.0
  camera: ^0.10.5+9
  image_picker: ^1.0.7
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  confetti: ^0.7.0
  path_provider: ^2.1.1
  permission_handler: ^11.3.0
```

### Data Models
- **ScanItem**: Represents a classified item with metadata
- **UserStats**: Tracks user progress, achievements, and statistics

### Services
- **GeminiService**: Handles AI image classification
- **DataStorage**: Manages local data persistence and user statistics

## 🎨 Design Features

- **Modern UI**: Material Design 3 with green sustainability theme
- **Responsive Layout**: Adapts to different screen sizes
- **Accessibility**: Proper semantic labels and screen reader support
- **Visual Feedback**: Confetti animations for achievements
- **Category Color Coding**: Distinct colors for different waste categories

## 📊 Sustainability Impact

The app encourages sustainable behavior through:
- **Education**: Teaching proper waste sorting methods
- **Gamification**: Making sustainability fun and engaging
- **Tracking**: Visualizing environmental impact through scoring
- **Reuse Promotion**: Reducing waste through creative reuse ideas

## 🔧 Setup and Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ScanIt2
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Usage

1. **Take a Photo**: Use the camera to capture an item
2. **Get Classification**: AI analyzes and categorizes the item
3. **View Results**: See disposal instructions and reuse ideas
4. **Track Progress**: Monitor your sustainability score and achievements
5. **Browse History**: Review past sorted items with filtering options

## 🎯 Target Users

- **Environmentally conscious individuals**
- **Families teaching children about sustainability**
- **People new to recycling and waste management**
- **Anyone wanting to reduce their environmental footprint**

## 🔮 Future Enhancements

- **Community Features**: Share reuse ideas and tips
- **Local Recycling Center Integration**: Find nearby disposal locations
- **Carbon Footprint Tracking**: Calculate environmental impact
- **Social Sharing**: Share achievements and progress
- **Offline Mode**: Basic classification without internet

## 📄 License

This project is open-source and available under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

---

**ScanIt** - Making sustainability simple, one item at a time! 🌍♻️