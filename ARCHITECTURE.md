# Cryptocurrency Trading App - Clean Architecture

## Tổng quan

Dự án được xây dựng theo **Clean Architecture** của Uncle Bob với 5 layers rõ ràng, đảm bảo:
- Separation of Concerns
- Dependency Inversion (dependencies point inward)
- Testability (mỗi layer có thể test độc lập)
- Maintainability (dễ mở rộng và sửa đổi)

## Architecture Diagram

```
┌────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ LoginScreen  │  │RegisterScreen│  │  HomeScreen  │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                  │                  │             │
│         └──────────────────┴──────────────────┘             │
└────────────────────────────┬───────────────────────────────┘
                             │
┌────────────────────────────┴───────────────────────────────┐
│                      Domain Layer                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ LoginUseCase │  │RegisterUse..│  │GetCurrentU.. │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         └──────────────────┴──────────────────┘             │
│                             │                               │
│                   ┌─────────┴─────────┐                     │
│                   │ AuthRepository    │ (interface)         │
│                   │ (interface)       │                     │
│                   └─────────┬─────────┘                     │
└─────────────────────────────┼─────────────────────────────┘
                              │ implements
┌─────────────────────────────┴─────────────────────────────┐
│                      Data Layer                             │
│           ┌───────────────────────────┐                     │
│           │ AuthRepositoryImpl        │                     │
│           └─────────┬─────────────────┘                     │
│                     │                                       │
│           ┌─────────┴─────────────┐                         │
│           │ AuthRemoteDataSource  │                         │
│           └─────────┬─────────────┘                         │
│                     │                                       │
└─────────────────────┼─────────────────────────────────────┘
                      │
┌─────────────────────┴─────────────────────────────────────┐
│                      Core Layer                             │
│           ┌───────────────────────────┐                     │
│           │      DioClient            │                     │
│           │  (HTTP Client Wrapper)    │                     │
│           └───────────────────────────┘                     │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ TokenService │  │ ToastService │  │ GetIt (DI)   │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## Folder Structure

```
lib/
├── core/                       # Shared components across the app
│   ├── constants/             # App-wide constants (API endpoints, strings)
│   │   └── api_constants.dart # Backend API endpoints
│   ├── di/                    # Dependency Injection setup (GetIt)
│   │   └── injection_container.dart # Service locator setup
│   ├── error/                 # Error handling (Failures, Exceptions)
│   │   ├── exceptions.dart    # Custom exceptions (Server, Network, Auth, Validation)
│   │   └── failures.dart      # Failure classes for Either<L,R> pattern
│   ├── network/               # Network configuration (Dio client)
│   │   └── dio_client.dart    # Dio wrapper với 3 interceptors
│   ├── services/              # Core services
│   │   ├── token_service.dart # JWT token management
│   │   └── toast_service.dart # Custom toast notifications
│   ├── usecases/              # Base UseCase interface
│   │   └── usecase.dart       # Base class cho tất cả use cases
│   └── utils/                 # Utility functions
│
├── data/                      # Data Layer
│   ├── datasources/          # Data sources (API, Local DB)
│   │   └── auth_remote_datasource.dart # Auth API calls
│   ├── models/               # Data models (DTOs) with JSON serialization
│   │   ├── user_model.dart           # User DTO
│   │   ├── auth_response_model.dart  # Login/Register response DTO
│   │   └── login_request_model.dart  # Login request DTO
│   └── repositories/         # Repository implementations
│       └── auth_repository_impl.dart # AuthRepository implementation
│
├── domain/                    # Domain Layer (Business Logic)
│   ├── entities/             # Domain entities (pure Dart objects)
│   │   ├── user.dart         # User entity với business logic
│   │   └── auth_response.dart # Auth response entity
│   ├── repositories/         # Repository interfaces
│   │   └── auth_repository.dart # AuthRepository interface
│   └── usecases/             # Use cases (business rules)
│       └── auth_usecases.dart # Login, Register, GetCurrentUser use cases
│
├── presentation/              # Presentation Layer (UI)
│   ├── providers/            # State management (hiện chưa dùng)
│   └── widgets/              # Reusable widgets (hiện chưa có)
│
└── screens/                   # App screens (ngoài presentation folder)
    ├── login_screen.dart      # Login UI
    ├── register_screen.dart   # Register UI với 5-step flow
    └── home_screen.dart       # Home dashboard UI
```
