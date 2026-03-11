# Smart Notes App 📝✨

A premium, high-performance iOS-style Notes application built with Flutter. This app features offline-first local storage, smooth pagination, real-time search, and AI-powered note summarization using the Llama 3 model via OpenRouter.

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