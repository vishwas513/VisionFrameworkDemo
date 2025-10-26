# VisionForFun2 🎯

A modern iOS app demonstrating Apple's Vision framework capabilities with on-device computer vision features. Built with SwiftUI and optimized for both light and dark modes.

## ✨ Features

### 1. Text Recognition (OCR)
- Extract and recognize text from images using `VNRecognizeTextRequest`
- Support for both camera capture and photo library selection
- Real-time image preview
- Selectable and copyable recognized text
- Accurate text recognition with language correction
- Confidence-based filtering for better results

### 2. Body Pose Detection
- Multi-person body pose detection using `VNDetectHumanBodyPoseRequest`
- Track up to multiple people simultaneously
- 17 joint points per person (shoulders, elbows, wrists, hips, knees, ankles, neck, etc.)
- Visual skeleton overlay with color-coded tracking
- Different colors for each detected person (green, blue, purple, orange, pink, yellow)
- Confidence threshold filtering (>30% confidence)
- Before/after comparison view

## 🎨 Design

- **Clean, modern UI** with card-based navigation
- **Full dark mode support** with adaptive colors and shadows
- **Gradient icons** and smooth animations
- **Organized code structure** with separate view files
- **Accessibility labels** for better VoiceOver support
- **iOS-native design patterns** using SwiftUI

## 📱 Screenshots

### Main Menu
![Main Menu](Screenshot%202025-10-26%20at%205.18.33%20PM.png)

### Body Pose Detection in Action
![Body Pose Detection](Screenshot%202025-10-26%20at%205.19.51%20PM.png)

## 🏗️ Architecture

```
VisionForFun2/
├── ContentView.swift              # Main menu/navigation hub
├── TextRecognitionView.swift      # OCR feature view
├── BodyPoseDetectionView.swift    # Body pose detection view
├── ImagePicker.swift              # Shared image picker component
└── VisionForFun2App.swift         # App entry point
```

### Code Organization

- **Modular Views**: Each feature is in its own dedicated view file
- **Shared Components**: Reusable `ImagePicker` wrapper for UIImagePickerController
- **MARK Comments**: Clear section organization within files
- **Computed Properties**: View components broken down for readability
- **Dark Mode Support**: Environment color scheme detection throughout

## 🔧 Technologies Used

- **SwiftUI** - Modern declarative UI framework
- **Vision Framework** - Apple's computer vision framework
  - `VNRecognizeTextRequest` - Text recognition
  - `VNDetectHumanBodyPoseRequest` - Body pose detection
- **Core Graphics** - Drawing skeleton overlays
- **PhotosUI** - Photo library access
- **UIKit Integration** - Camera and image picker via UIViewControllerRepresentable

## 🚀 Key Features Implementation

### Text Recognition
- Uses accurate recognition level with language correction
- Minimum text height threshold of 0.02 for small text detection
- Asynchronous processing on background queue
- Top candidate selection for each observation

### Body Pose Detection
- All 17 body joints tracked per person
- Custom skeleton drawing algorithm
- Coordinate transformation from Vision's normalized space to UIKit's coordinate system
- Line and joint rendering with Core Graphics
- Multi-person support with color differentiation

## 📋 Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+
- Camera and Photo Library permissions

## 🔒 Privacy

- **Camera Usage**: Required for capturing photos for analysis
- **Photo Library Access**: Required for selecting images from library
- **On-Device Processing**: All Vision framework operations run locally on device
- **No External Servers**: No data is sent to external servers

## 🎯 Use Cases

- Document scanning and text extraction
- Fitness and sports pose analysis
- Accessibility features for vision-impaired users
- Educational demonstrations of computer vision
- Prototyping and testing Vision framework capabilities

## 🛠️ Setup

1. Clone the repository
2. Open `VisionForFun2.xcodeproj` in Xcode
3. Build and run on a physical device or simulator
4. Grant camera and photo library permissions when prompted

## 📝 Notes

- Text recognition works best with clear, well-lit images
- Body pose detection requires clear view of human subjects
- Physical device recommended for camera testing
- Works in both portrait and landscape orientations

## 👨‍💻 Development

Built with modern iOS development best practices:
- Clean architecture with separation of concerns
- Reusable components
- Environment-aware styling
- Proper error handling
- Accessibility support

## 📄 License

This project is for educational and demonstration purposes.

---

Made with ❤️ using Apple's Vision Framework
