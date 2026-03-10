# Smart Notes App 📝✨

A premium, high-performance android/iOS-style Notes application built with Flutter. This app features offline-first local storage, smooth pagination, real-time search, and AI-powered note summarization using the Llama 3 model via OpenRouter.

## 🌟 Features

* **Offline-First Architecture:** All notes are saved instantly to a local Hive database, ensuring lightning-fast performance and offline access.
* **AI Summarization:** Generate concise, 1-sentence summaries of long notes instantly using Meta's Llama-3-8b-instruct model.
* **Native iOS Feel:** Built entirely with Flutter's `Cupertino` widget library for a seamless, native Apple design language (large collapsing headers, modal popups, swipe-to-delete).
* **High Performance:** Efficient pagination and lazy loading ensure smooth scrolling even with 1000+ notes.
* **Real-Time Search:** Instantly filter your Hive box results as you type.
* **Read-Only Mode:** Dedicated note-viewing screen to prevent accidental edits, complete with inline summarization and deletion tools.

## 🛠 Tech Stack

* **Framework:** [Flutter](https://flutter.dev/) (Latest Stable)
* **State Management:** [Riverpod](https://riverpod.dev/) (`flutter_riverpod`)
* **Local Database:** [Hive](https://docs.hivedb.dev/) (`hive` & `hive_flutter`)
* **Networking:** `http` package
* **AI Engine:** [OpenRouter API](https://openrouter.ai/) (Model: `meta-llama/llama-3-8b-instruct`)

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (v3.0.0 or higher)
* Dart SDK
* An API Key from [OpenRouter](https://openrouter.ai/)

### Installation

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/yourusername/smart_notes_app.git](https://github.com/yourusername/smart_notes_app.git)
   cd smart_notes_app

  2. Install dependencies
flutter pub get
3. Generate Hive adapters

Because the app uses Hive for local storage, run the code generator:

flutter pub run build_runner build --delete-conflicting-outputs
4. Configure your API Key

Open:

lib/core/constants/app_constants.dart

Add your OpenRouter API key:

class AppConstants {
  static const String openRouterApiKey = 'YOUR_OPENROUTER_API_KEY';
}
5. Run the app
flutter run,
📁 Folder Structure

### Folder Overview

- **core/**
  - Contains global utilities used across the application.
  - `constants/` – API keys, base URLs, and global constants.
  - `network/` – AI service integration and HTTP client logic.
  - `theme/` – Global theme configuration including colors and typography.

- **features/notes/**
  - Main feature module for the Notes functionality.
  - `data/` – Note model definitions and Hive adapters for local storage.
  - `presentation/`
    - `providers/` – Riverpod state management logic.
    - `screens/` – Main UI screens such as Home and Note detail.
    - `widgets/` – Reusable UI components like Note cards.

- **main.dart**
  - Entry point of the Flutter application.
  - Responsible for initializing Hive and launching the app.
🤝 Contributing

Contributions, issues, and feature requests are welcome.

Feel free to check the issues page and submit pull requests.

📝 License

This project is licensed under the MIT License.
