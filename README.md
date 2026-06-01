# TaskFlow

A task management app built with Flutter, featuring offline-first architecture, cloud sync via Firebase Firestore, and clean BLoC state management.

## Features

- **Email & Google Sign-In** via Firebase Authentication
- **Task CRUD** with priority levels (Low, Medium, High) and due dates
- **Categories** with custom color coding
- **Cloud Sync** via Firestore, tasks are tied to your account and accessible across devices
- **Offline-First** with Hive local caching, works without internet and syncs when back online
- **Dark / Light / System Theme** toggle, persisted across sessions
- **Due Date Notifications** scheduled 1 hour before deadline
- **Drag-to-Reorder** and **Swipe-to-Delete**
- **Smart Due Date Labels** (Today, Tomorrow, 3d left, Overdue)
- **Progress Tracking** with animated progress bar on the home screen

## Architecture

Clean Architecture with three layers:

```
lib/
  core/
    di/              # GetIt dependency injection
    router/          # GoRouter with auth guards
    theme/           # Material 3 theming
    notifications/   # Local notification service
  data/
    datasources/
      local/         # Hive (offline cache)
      remote/        # Firestore (cloud sync)
    models/          # Data models with JSON serialization
    repositories/    # Repository implementations (sync local + remote)
  domain/
    entities/        # Business entities
    repositories/    # Abstract repository contracts
  presentation/
    blocs/
      auth/          # AuthCubit (Firebase Auth + Google Sign-In)
      task/          # TaskBloc (CRUD, filter, reorder)
      category/      # CategoryCubit
      theme/         # ThemeCubit (persisted via Hive)
    pages/           # Screens (Home, Login, Register, TaskDetail, Settings, Categories)
    widgets/         # Reusable UI (TaskCard, AddTaskSheet)
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter 3.32 + Dart |
| **State Management** | BLoC / Cubit (flutter_bloc) |
| **Dependency Injection** | GetIt |
| **Navigation** | GoRouter with auth redirect |
| **Local Storage** | Hive (offline cache + theme persistence) |
| **Cloud Database** | Firebase Cloud Firestore |
| **Authentication** | Firebase Auth (Email + Google Sign-In) |
| **Notifications** | flutter_local_notifications + timezone |
| **Design System** | Material 3 with custom theming |

## Data Flow

```
User Action
    |
    v
BLoC/Cubit (presentation)
    |
    v
Repository (data)
    |
    +---> Hive (local, instant)
    |
    +---> Firestore (remote, async)
```

Write operations save to Hive first (instant feedback), then sync to Firestore in the background. Read operations fetch from Firestore when online, fall back to Hive when offline.

## Setup

### Prerequisites
- Flutter 3.x installed
- A Firebase project with Authentication and Firestore enabled

### Steps

1. Clone the repo
```bash
git clone https://github.com/yeabsiradaniel/TaskFlow.git
cd TaskFlow
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
```bash
flutterfire configure --project=your-project-id
```

4. Enable Firebase services
   - Authentication: Enable Email/Password and Google Sign-In
   - Firestore: Create database in production or test mode

5. Deploy Firestore rules
```bash
firebase deploy --only firestore:rules
```

6. Run the app
```bash
flutter run
```

## Download

[Download APK](https://github.com/yeabsiradaniel/TaskFlow/releases/latest) from GitHub Releases.

## License

MIT
