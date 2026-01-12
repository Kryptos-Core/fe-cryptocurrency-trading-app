# Cryptocurrency Trading App - Clean Architecture
## Folder Structure

```
lib/
├── core/                       # Shared components across the app
│   ├── constants/             # App-wide constants (API endpoints, strings)
│   ├── di/                    # Dependency Injection setup (GetIt)
│   ├── error/                 # Error handling (Failures, Exceptions)
│   ├── network/               # Network configuration (Dio client)
│   ├── usecases/              # Base UseCase interface
│   └── utils/                 # Utility functions
│
├── data/                      # Data Layer
│   ├── datasources/          # Data sources (API, Local DB)
│   │   ├── remote/           # Remote data sources (API calls)
│   │   └── local/            # Local data sources (Cache, Hive)
│   ├── models/               # Data models (DTOs) with JSON serialization
│   └── repositories/         # Repository implementations
│
├── domain/                    # Domain Layer (Business Logic)
│   ├── entities/             # Domain entities (pure Dart objects)
│   ├── repositories/         # Repository interfaces
│   └── usecases/             # Use cases (business rules)
│
└── presentation/              # Presentation Layer (UI)
    ├── providers/            # State management (Provider/ChangeNotifier)
    ├── screens/              # App screens
    └── widgets/              # Reusable widgets
```