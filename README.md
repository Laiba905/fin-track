# 🚀 FinTrack - Your Ultimate Personal Finance Manager

FinTrack is a premium, modern personal finance tracking application built with Flutter. It helps users manage their income and expenses with a sleek, intuitive UI, powerful analytics, and 100% offline data security.

## ✨ Features

-   **📊 Dynamic Dashboard:** Get a real-time summary of your total balance, monthly income, and expenses with a quick-glance spending indicator.
-   **📈 Advanced Analytics:** Visualize your spending patterns with interactive bar charts and category-wise breakdowns using `fl_chart`.
-   **📑 Transaction History:** Search and filter your transactions by category or date.
-   **➕ Easy Management:** Add, edit, and delete transactions with notes and custom categories.
-   **🌓 Theme Switching:** Smooth transition between Premium Dark and Light modes.
-   **🛡️ Privacy First:** All data is stored locally on your device using `Hive`, ensuring 100% privacy and offline access.
-   **✨ Fluid Animations:** Built with `flutter_animate` for a smooth and premium user experience.
-   **📱 Fully Responsive:** Optimized for both Mobile and Web/Desktop views.

## 🛠️ Tech Stack

-   **Framework:** [Flutter](https://flutter.dev)
-   **State Management:** [Provider](https://pub.dev/packages/provider)
-   **Local Database:** [Hive](https://pub.dev/packages/hive)
-   **Charts:** [FL Chart](https://pub.dev/packages/fl_chart)
-   **Animations:** [Flutter Animate](https://pub.dev/packages/flutter_animate)
-   **Date & Time:** [Intl](https://pub.dev/packages/intl)

## 📸 Screenshots

*(Add your screenshots here later)*

## 🚀 Getting Started

### Prerequisites

-   Flutter SDK installed (v3.0.0 or higher)
-   Dart SDK installed

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/FinTrack.git
    cd FinTrack
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run build runner (to generate Hive adapters):**
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **Launch the app:**
    ```bash
    flutter run
    ```

## 📂 Project Structure

```text
lib/
├── core/
│   ├── themes/      # App color schemes and styles
│   └── utils/       # Responsive helper and constants
├── data/
│   ├── local/       # Hive initialization and helpers
│   └── models/      # Transaction data models
├── presentation/
│   ├── screens/     # All UI screens (Dashboard, Analytics, etc.)
│   └── widgets/     # Reusable UI components
└── providers/       # State management logic (Finance & Theme)
```

## 🤝 Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request if you have ideas to improve FinTrack.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
Built with ❤️ by [Your Name]
