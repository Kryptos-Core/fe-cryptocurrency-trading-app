# Currencies API Implementation - Flutter/Dart

## Kiến Trúc

### Clean Architecture Layers

1. **Domain Layer** (Business Logic)
   - `lib/domain/entities/currency.dart` - Currency entity
   - `lib/domain/repositories/currencies_repository.dart` - Repository interface
   - `lib/domain/usecases/currencies_usecases.dart` - Use cases

2. **Data Layer** (Data Sources & Models)
   - `lib/data/models/currency_model.dart` - Currency DTO model
   - `lib/data/models/create_currency_dto.dart` - Create DTO
   - `lib/data/models/update_currency_dto.dart` - Update DTO
   - `lib/data/models/paginated_currencies_response.dart` - Paginated response model
   - `lib/data/datasources/currencies_remote_datasource.dart` - Remote data source
   - `lib/data/repositories/currencies_repository_impl.dart` - Repository implementation

3. **Core Layer** (Shared Utilities)
   - `lib/core/models/api_response.dart` - Generic API response
   - `lib/core/models/error_response.dart` - Error response model
   - `lib/core/services/currency_cache_service.dart` - Caching service
   - `lib/core/services/mock_service.dart` - Mock service configuration
   - `lib/core/utils/currency_validator.dart` - Validation utilities
   - `lib/core/constants/api_constants.dart` - API endpoints (reads from .env)
   - `lib/core/error/exceptions.dart` - Custom exceptions
   - `lib/core/error/failures.dart` - Failure types

## Design Patterns Được Áp Dụng

### 1. Repository Pattern
- **Mục đích**: Tách biệt data access logic khỏi business logic
- **Implementation**: 
  - `CurrenciesRepository` (interface) - Domain layer
  - `CurrenciesRepositoryImpl` (implementation) - Data layer
- **Lợi ích**: Dễ test, dễ thay đổi data source (mock/real API)

### 2. Strategy Pattern
- **Mục đích**: Hỗ trợ nhiều strategies cho caching
- **Implementation**: 
  - `CurrencyCacheService` (abstract) - Interface
  - `InMemoryCurrencyCacheService` (implementation) - In-memory cache
- **Lợi ích**: Có thể thay đổi caching strategy (memory, disk, Redis) mà không ảnh hưởng code khác

### 3. Factory Pattern
- **Mục đích**: Tạo Dio client với cấu hình sẵn
- **Implementation**: `DioClient` class
- **Lợi ích**: Centralized HTTP client configuration

### 4. Singleton Pattern
- **Mục đích**: Đảm bảo chỉ có 1 instance của cache service
- **Implementation**: `InMemoryCurrencyCacheService` factory constructor
- **Lợi ích**: Consistent cache state across app

### 5. Dependency Injection (Service Locator)
- **Mục đích**: Loose coupling, dễ test
- **Implementation**: GetIt service locator
- **Lợi ích**: Dễ mock dependencies trong testing

### 6. Value Object Pattern
- **Mục đích**: Immutable data objects
- **Implementation**: 
  - `Currency` entity
  - `ValidationResult`
  - `PaginatedCurrenciesResult`
- **Lợi ích**: Type safety, immutability

### 7. DTO Pattern
- **Mục đích**: Tách biệt API contract khỏi domain model
- **Implementation**: 
  - `CurrencyModel` - API response model
  - `CreateCurrencyDto` - Create request DTO
  - `UpdateCurrencyDto` - Update request DTO
- **Lợi ích**: API changes không ảnh hưởng domain layer

## SOLID Principles

### Single Responsibility Principle (SRP)
- Mỗi class chỉ có 1 trách nhiệm:
  - `CurrencyValidator` - chỉ validate
  - `CurrencyCacheService` - chỉ cache
  - `CurrenciesRemoteDataSource` - chỉ fetch data
  - `CurrenciesRepository` - chỉ convert exceptions to failures

### Open/Closed Principle (OCP)
- `Failure` class mở cho extension, đóng cho modification
- Có thể thêm failure types mới mà không sửa code cũ

### Liskov Substitution Principle (LSP)
- `CurrenciesRepositoryImpl` có thể thay thế `CurrenciesRepository` interface
- `InMemoryCurrencyCacheService` có thể thay thế `CurrencyCacheService` interface

### Interface Segregation Principle (ISP)
- Repository interface chỉ có methods cần thiết
- Không force clients implement methods không dùng

### Dependency Inversion Principle (DIP)
- Domain layer (high-level) không phụ thuộc vào Data layer (low-level)
- Cả 2 đều phụ thuộc vào abstractions (interfaces)

## Environment Configuration

### .env File Setup
- **File**: `.env` (root directory)
- **Variables**:
  - `BASE_URL`: Base URL including `/api/v1` prefix (e.g., `http://localhost:3000/api/v1`)
  - `ENV`: Environment (development/production)
- **Loading**: Automatically loaded in `main.dart` using `flutter_dotenv`
- **Fallback**: Defaults to `http://localhost:3000/api/v1` if `.env` not found

### API Constants
- `ApiConstants.baseUrl`: Reads from `.env` file (includes `/api/v1` prefix)
- All endpoints are relative paths (no prefix needed)
- Example: `BASE_URL/currencies` → `http://localhost:3000/api/v1/currencies`

## API Endpoints Đã Triển Khai

**Base URL**: Loaded from `.env` file (includes `/api/v1` prefix)

### 1. GET /currencies
- **Full URL**: `{BASE_URL}/currencies`
- **Use Case**: `GetCurrenciesUseCase`
- **Params**: `GetCurrenciesParams` (page, limit, includeInactive)
- **Response**: `PaginatedCurrenciesResult`
- **Example**: `http://localhost:3000/api/v1/currencies?page=1&limit=10&includeInactive=false`

### 2. GET /currencies/active
- **Full URL**: `{BASE_URL}/currencies/active`
- **Use Case**: `GetActiveCurrenciesUseCase`
- **Cached**: Yes (via `CurrencyCacheService`)
- **Response**: `List<Currency>`
- **Example**: `http://localhost:3000/api/v1/currencies/active`

### 3. GET /currencies/tradable
- **Full URL**: `{BASE_URL}/currencies/tradable`
- **Use Case**: `GetTradableCurrenciesUseCase`
- **Cached**: Yes (via `CurrencyCacheService`)
- **Response**: `List<Currency>`
- **Example**: `http://localhost:3000/api/v1/currencies/tradable`

### 4. GET /currencies/:id
- **Full URL**: `{BASE_URL}/currencies/:id`
- **Use Case**: `GetCurrencyByIdUseCase`
- **Response**: `Currency`
- **Example**: `http://localhost:3000/api/v1/currencies/17`

### 5. GET /currencies/symbol/:symbol
- **Full URL**: `{BASE_URL}/currencies/symbol/:symbol`
- **Use Case**: `GetCurrencyBySymbolUseCase`
- **Response**: `Currency`
- **Example**: `http://localhost:3000/api/v1/currencies/symbol/BTC`

### 6. POST /currencies
- **Full URL**: `{BASE_URL}/currencies`
- **Use Case**: `CreateCurrencyUseCase`
- **DTO**: `CreateCurrencyDto`
- **Response**: `Currency`
- **Admin Only**: Yes
- **Example**: `http://localhost:3000/api/v1/currencies`

### 7. PATCH /currencies/:id
- **Full URL**: `{BASE_URL}/currencies/:id`
- **Use Case**: `UpdateCurrencyUseCase`
- **DTO**: `UpdateCurrencyDto`
- **Response**: `Currency`
- **Admin Only**: Yes
- **Example**: `http://localhost:3000/api/v1/currencies/17`

### 8. DELETE /currencies/:id
- **Full URL**: `{BASE_URL}/currencies/:id`
- **Use Case**: `DeleteCurrencyUseCase`
- **Response**: `void` (204 No Content)
- **Admin Only**: Yes
- **Note**: Soft delete (sets `is_active = false`)
- **Example**: `http://localhost:3000/api/v1/currencies/17`

## Error Handling

### Exception Types
- `NetworkException` - Network/timeout errors
- `ServerException` - Server errors (5xx)
- `NotFoundException` - 404 errors
- `ValidationException` - 400 validation errors
- `AuthenticationException` - 401 errors

### Failure Types
- `NetworkFailure`
- `ServerFailure`
- `NotFoundFailure`
- `ValidationFailure`
- `AuthenticationFailure`
- `ConflictFailure` - 409 errors

### Error Response Model
- `ErrorResponse` - Parsed error response từ API
- `ValidationError` - Validation error details

## Validation

### CurrencyValidator
- `validateSymbol()` - Validate currency symbol (pattern, length)
- `validateName()` - Validate currency name
- `validatePrecisionScale()` - Validate precision (0-18)
- `validateMinWithdraw()` - Validate min withdrawal amount
- `validateCreateCurrencyDto()` - Validate full DTO
- `validateWithdrawalAmount()` - Validate withdrawal against currency
- `formatAmountByCurrency()` - Format amount by precision

## Mock Service Configuration

### Per-Module Mock Control
- **File**: `lib/core/services/mock_service.dart`
- **Purpose**: Control mock mode independently for each module
- **Configuration**:
  ```dart
  static bool useMockForCurrencies = false; // Use real API
  static bool useMockForMarkets = true;    // Use mock data
  static bool useMockForWallets = true;    // Use mock data
  static bool useMockForUsers = true;      // Use mock data
  ```

### Strategy
- **Currencies**: Uses real API (backend ready)
- **Markets**: Uses mock data (backend not ready)
- **Wallets**: Uses mock data (backend not ready)
- **Users**: Uses mock data (backend not ready)

### Usage
- Check mock mode: `MockService.isMockModeFor('currencies')`
- Switch to real API: Set `useMockFor[Module] = false`
- Switch to mock: Set `useMockFor[Module] = true`

## Caching

### CurrencyCacheService
- **Strategy**: In-memory caching
- **TTL**: 5 minutes (configurable)
- **Methods**:
  - `getCachedActiveCurrencies()`
  - `cacheActiveCurrencies()`
  - `getCachedTradableCurrencies()`
  - `cacheTradableCurrencies()`
  - `clearCache()`

### Cache Invalidation
- Cache được clear khi:
  - Create currency
  - Update currency
  - Delete currency

## Search Functionality

### Real-Time Search
- **Location**: `CurrenciesListScreen`
- **Features**:
  - Real-time filtering as user types
  - Case-insensitive search
  - Searches both symbol and name
  - Client-side filtering (no API call needed)

### Implementation
- Search query stored in state: `_searchQuery`
- Filter logic:
  ```dart
  displayedCurrencies.where((c) {
    final symbol = c.symbol.toLowerCase();
    final name = c.name.toLowerCase();
    return symbol.contains(_searchQuery) || name.contains(_searchQuery);
  })
  ```

### User Experience
- Instant results as user types
- Shows "No currencies match your search" when no results
- Works with existing filters (Active, Tradable)

## Usage Examples

Xem file `lib/examples/currencies_api_usage_example.dart` để xem các ví dụ sử dụng.

### Basic Usage

```dart
// Get active currencies
final useCase = sl<GetActiveCurrenciesUseCase>();
final result = await useCase(NoParams());

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (currencies) => print('Found ${currencies.length} currencies'),
);
```

### With Validation

```dart
// Validate before creating
final dto = CreateCurrencyDto(
  symbol: 'DOGE',
  name: 'Dogecoin',
  precisionScale: 8,
);

final validation = CurrencyValidator.validateCreateCurrencyDto(dto);
if (!validation.isValid) {
  print('Error: ${validation.error}');
  return;
}

// Create currency
final useCase = sl<CreateCurrencyUseCase>();
final result = await useCase(CreateCurrencyParams(dto: dto));
```

### With Caching

```dart
final cacheService = sl<CurrencyCacheService>();

// Try cache first
final cached = await cacheService.getCachedActiveCurrencies();
if (cached != null) {
  return cached; // Use cached data
}

// Cache miss - fetch from API
final useCase = sl<GetActiveCurrenciesUseCase>();
final result = await useCase(NoParams());

result.fold(
  (failure) => throw failure,
  (currencies) {
    // Cache for next time
    cacheService.cacheActiveCurrencies(currencies);
    return currencies;
  },
);
```

## Testing

### Unit Testing
- Test use cases với mock repository
- Test validator với various inputs
- Test cache service với TTL

### Integration Testing
- Test datasource với mock Dio
- Test repository với real datasource

### Example Test Structure

```dart
// Test use case
test('should return currencies from repository', () async {
  // Arrange
  final mockRepository = MockCurrenciesRepository();
  when(mockRepository.getActiveCurrencies())
      .thenAnswer((_) async => Right(tCurrencies));
  
  final useCase = GetActiveCurrenciesUseCase(repository: mockRepository);
  
  // Act
  final result = await useCase(NoParams());
  
  // Assert
  expect(result, Right(tCurrencies));
});
```

## Dependencies

### Core Dependencies
- `dio` - HTTP client
- `dartz` - Functional programming (Either)
- `equatable` - Value equality
- `json_annotation` - JSON serialization
- `get_it` - Dependency injection
- `flutter_dotenv` - Environment variable management

### Dev Dependencies
- `build_runner` - Code generation
- `json_serializable` - JSON code generation

## Migration Notes

### Breaking Changes
1. **Base URL Structure**: 
   - Old: `http://localhost:3000` + `/api/v1/currencies`
   - New: `http://localhost:3000/api/v1` (from .env) + `/currencies`
   - Base URL now includes `/api/v1` prefix
2. **Environment Variables**: 
   - Must create `.env` file with `BASE_URL` variable
   - App will use default if `.env` not found
3. **Paginated Response**: Structure changed (nested `currencies` array)
4. **Repository Interface**: Added new methods for CRUD operations
5. **Mock Service**: Changed from global flag to per-module flags

### Migration Steps
1. **Create `.env` file**:
   ```env
   BASE_URL=http://localhost:3000/api/v1
   ENV=development
   ```
2. **Add dependency**: `flutter_dotenv: ^6.0.0` (already in pubspec.yaml)
3. **Update API constants**: Now reads from `.env`
4. **Update datasource implementations**: Use `ApiConstants` instead of hardcoded paths
5. **Update repository implementations**: Handle new response structures
6. **Update use cases**: Add new CRUD use cases
7. **Update dependency injection**: Register new services
8. **Update mock service**: Configure per-module flags
9. **Run code generation**: `flutter pub run build_runner build`

## Best Practices

1. **Environment Configuration**:
   - Always use `.env` file for BASE_URL
   - Never hardcode API endpoints
   - Use `ApiConstants` for all endpoint references

2. **Mock Service**:
   - Use per-module flags for granular control
   - Set `useMockFor[Module] = false` when backend is ready
   - Keep mock data updated for development

3. **API Usage**:
   - Always validate input trước khi gửi request
   - Use cached endpoints (`/active`, `/tradable`) khi có thể
   - Handle errors properly với Either pattern
   - Clear cache sau khi create/update/delete

4. **Code Organization**:
   - Use use cases thay vì gọi repository trực tiếp
   - Follow SOLID principles khi thêm features mới
   - Keep datasources focused on API calls only

5. **Search & Filtering**:
   - Use client-side filtering for search (real-time UX)
   - Combine search with API filters when needed
   - Show appropriate messages when no results found

## Recent Updates (2026-01-22)

### v1.1.0 - Environment & API Refactoring
- Added environment variable support with `.env` file
- Migrated all API endpoints to use `/api/v1` prefix in base URL
- Implemented per-module mock service configuration
- Added real-time search functionality for currencies
- Fixed bottom navigation bar visibility issue
- Updated all datasources to use `ApiConstants` instead of hardcoded paths

### Key Changes
1. **Environment Configuration**: Base URL now loaded from `.env` file
2. **API Structure**: Base URL includes `/api/v1`, endpoints are relative paths
3. **Mock Service**: Granular control per module (currencies, markets, wallets, users)
4. **Search Feature**: Real-time client-side filtering by symbol and name
5. **UI Improvements**: Fixed navigation bar visibility in child screens

### Migration Required
- Create `.env` file with `BASE_URL` variable
- Update any hardcoded API endpoints to use `ApiConstants`
- Configure mock service flags based on backend readiness

---

**Last Updated**: 2026-01-23
**Version**: 1.1.0  
