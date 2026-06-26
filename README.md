# TickNotes ⏱️📝

TickNotes is a comprehensive, cross-platform productivity application built with Flutter. It combines the power of task management, note-taking, and time-blocking into a single, unified experience.

### 📱 Available on Google Play
TickNotes is currently published on the Google Play Store and is in the **Closed Testing** phase. 
*(If you are part of the testing track, you can download it directly from the Play Store!)*

---

## Features ✨

* **Notes:** A rich text editor to capture thoughts, ideas, and important information.
* **Todo List:** Track your daily tasks with due dates, priorities, and completion statuses.
* **Pomodoro Timer:** Stay focused using the built-in Pomodoro technique timer with customizable focus and break intervals.
* **Dashboard & Analytics:** View your productivity statistics at a glance, tracking your focus time and completed tasks over days and weeks.
* **Local First:** All data is securely stored locally on your device using an embedded SQLite database.
* **Dark Mode:** Full support for system-wide light and dark themes.

---

## Architecture 🏗️

TickNotes is built with scalability and maintainability in mind, utilizing enterprise-grade patterns:
* **Pattern:** Feature-Driven MVVM (Model-View-ViewModel) + Repository Pattern.
* **State Management:** Riverpod (`@riverpod` code generation) for robust, predictable, and testable state handling.
* **Local Storage:** Drift (Reactive SQLite) for type-safe database queries and real-time UI updates via Streams.

---

## Getting Started 🚀

### Prerequisites
* Flutter SDK (Latest stable version)
* Dart SDK
* Android Studio / VS Code with Flutter extensions

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Maaz-saqib/tick_notes.git
   ```
2. Navigate to the project directory:
   ```bash
   cd tick_notes
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Generate the Riverpod and Drift boilerplate code (if not already present):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
5. Run the app:
   ```bash
   flutter run
   ```

---

## Testing 🧪

This project includes a comprehensive test suite covering different layers of the app:
* **Unit Tests:** Verifying ViewModel logic.
* **Widget Tests:** Ensuring UI components render correctly.
* **E2E Integration Tests:** Simulating real user flows across the app.

Run all the tests using:
```bash
flutter test
```
