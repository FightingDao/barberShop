# Flutter Service Layer Documentation

This directory contains the complete service layer implementation for the barber shop app.

## File Overview

### 1. **storage_service.dart**
Local storage service using `shared_preferences` for data persistence.

**Features:**
- Token management (save/get/remove)
- User information caching
- Custom key-value storage (String, Bool, Int, Double)
- Singleton pattern

**Usage:**
```dart
import 'services/services.dart';

// Initialize (call once at app startup)
await StorageService.instance.init();

// Check if user is logged in
final isLoggedIn = StorageService.instance.isLoggedIn();

// Get cached user
final user = StorageService.instance.getUser();

// Get token
final token = StorageService.instance.getToken();
```

---

### 2. **api_service.dart**
Base API service with Dio HTTP client.

**Features:**
- Automatic snake_case ↔ camelCase conversion
- Request/Response interceptors
- Token management (adds Bearer token to headers)
- Error handling (401 redirects, network errors)
- Configurable base URL and timeout

**Key Functions:**
- `get<T>()` - GET requests
- `post<T>()` - POST requests
- `put<T>()` - PUT requests
- `delete<T>()` - DELETE requests

**Usage:**
```dart
final api = ApiService.instance;

// GET request
final response = await api.get<User>(
  '/api/v1/user/profile',
  fromJson: (json) => User.fromJson(json),
);

if (response.success) {
  final user = response.data;
}
```

---

### 3. **auth_service.dart**
Authentication service for user login, registration, and profile management.

**API Endpoints:**
- `POST /api/v1/auth/login` - Login with phone and code
- `POST /api/v1/auth/send-code` - Send verification code
- `POST /api/v1/auth/verify` - Verify code
- `GET /api/v1/auth/profile` - Get user profile
- `PUT /api/v1/auth/profile` - Update user profile
- `POST /api/v1/auth/logout` - Logout

**Usage:**
```dart
final authService = AuthService.instance;

// Send verification code
await authService.sendVerificationCode('13800138000');

// Login with code
final loginResponse = await authService.login(
  phone: '13800138000',
  code: '123456',
);

// Check if logged in
final isLoggedIn = authService.isLoggedIn();

// Get profile
final user = await authService.getProfile();

// Update profile
final updatedUser = await authService.updateProfile({
  'nickname': 'John Doe',
  'avatarUrl': 'https://example.com/avatar.jpg',
});

// Logout
await authService.logout();
```

---

### 4. **shop_service.dart**
Shop service for browsing shops, services, and stylists.

**API Endpoints:**
- `GET /api/v1/shops` - Get shop list with optional search/location filters
- `GET /api/v1/shops/:id` - Get shop details
- `GET /api/v1/shops/:id/services` - Get shop services
- `GET /api/v1/shops/:id/stylists` - Get shop stylists

**Usage:**
```dart
final shopService = ShopService.instance;

// Get all shops
final shops = await shopService.getShops();

// Search shops
final searchResults = await shopService.searchShops('剪发');

// Get nearby shops
final nearbyShops = await shopService.getNearbyShops(
  latitude: 39.9042,
  longitude: 116.4074,
  radius: 5.0, // 5km radius
);

// Get shop details
final shop = await shopService.getShopDetail(1);

// Get shop services
final services = await shopService.getShopServices(1);

// Get shop stylists
final stylists = await shopService.getShopStylists(1);
```

---

### 5. **booking_service.dart**
Booking service for appointment management.

**API Endpoints:**
- `GET /api/v1/availability` - Get available time slots
- `POST /api/v1/appointments` - Create appointment
- `GET /api/v1/appointments` - Get user's appointments
- `GET /api/v1/appointments/:id` - Get appointment details
- `PUT /api/v1/appointments/:id/cancel` - Cancel appointment

**Usage:**
```dart
final bookingService = BookingService.instance;

// Get available time slots
final timeSlots = await bookingService.getAvailableTimeSlots(
  shopId: 1,
  serviceId: 1,
  date: '2025-11-15',
  stylistId: 1, // optional
);

// Create appointment
final appointment = await bookingService.createAppointment(
  shopId: 1,
  serviceId: 1,
  appointmentDate: '2025-11-15',
  appointmentTime: '10:00',
  stylistId: 1, // optional
  notes: 'Please use special shampoo', // optional
);

// Get all appointments
final appointments = await bookingService.getAppointments();

// Get pending appointments
final pendingAppointments = await bookingService.getPendingAppointments();

// Get appointment details
final appointmentDetail = await bookingService.getAppointmentDetail(1);

// Cancel appointment
final success = await bookingService.cancelAppointment(1);
```

---

## Configuration

### App Config
Located at `/lib/config/app_config.dart`:

```dart
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000',
  );

  static const Duration apiTimeout = Duration(seconds: 10);
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_info';
}
```

To set custom API URL when running:
```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com
```

---

## Error Handling

All services throw exceptions on errors. Wrap calls in try-catch:

```dart
try {
  final shops = await shopService.getShops();
  // Handle success
} catch (e) {
  // Handle error
  print('Error: $e');
}
```

The `ApiResponse<T>` object contains:
- `success: bool` - Whether request succeeded
- `data: T?` - Response data
- `message: String?` - Success/error message
- `error: ApiError?` - Error details (code, message, details)

---

## Initialization

Initialize storage service at app startup (in `main.dart`):

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  await StorageService.instance.init();

  runApp(MyApp());
}
```

---

## Dependencies

Add these to `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.4.0
  shared_preferences: ^2.2.2
  json_annotation: ^4.8.1

dev_dependencies:
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
```

---

## Architecture Notes

1. **Singleton Pattern**: All services use singleton pattern for easy access
2. **Type Safety**: Strongly typed with generics and model classes
3. **Case Conversion**: Automatic snake_case ↔ camelCase conversion
4. **Token Management**: Automatic token injection in request headers
5. **Error Handling**: Centralized error handling with meaningful messages
6. **Separation of Concerns**: Clear separation between API, storage, and business logic

---

## Example: Complete Login Flow

```dart
import 'services/services.dart';

class LoginExample {
  final authService = AuthService.instance;

  Future<void> loginFlow() async {
    try {
      // 1. Send verification code
      final codeSent = await authService.sendVerificationCode('13800138000');

      if (!codeSent) {
        print('Failed to send code');
        return;
      }

      // 2. User enters code (simulated here)
      final code = '123456';

      // 3. Login with phone and code
      final loginResponse = await authService.login(
        phone: '13800138000',
        code: code,
      );

      if (loginResponse != null) {
        print('Login successful!');
        print('User: ${loginResponse.user.nickname}');
        print('Token saved to local storage');

        // 4. Navigate to home page
        // Navigator.pushReplacementNamed(context, '/home');
      }

    } catch (e) {
      print('Login failed: $e');
    }
  }
}
```

---

## Example: Complete Booking Flow

```dart
import 'services/services.dart';

class BookingExample {
  final shopService = ShopService.instance;
  final bookingService = BookingService.instance;

  Future<void> bookingFlow() async {
    try {
      // 1. Get shops
      final shops = await shopService.getShops();
      final selectedShop = shops.first;

      // 2. Get shop services
      final services = await shopService.getShopServices(selectedShop.id);
      final selectedService = services.first;

      // 3. Get shop stylists (optional)
      final stylists = await shopService.getShopStylists(selectedShop.id);
      final selectedStylist = stylists.first;

      // 4. Get available time slots
      final timeSlots = await bookingService.getAvailableTimeSlots(
        shopId: selectedShop.id,
        serviceId: selectedService.id,
        date: '2025-11-15',
        stylistId: selectedStylist.id,
      );

      final selectedTimeSlot = timeSlots.first;

      // 5. Create appointment
      final appointment = await bookingService.createAppointment(
        shopId: selectedShop.id,
        serviceId: selectedService.id,
        appointmentDate: selectedTimeSlot.date,
        appointmentTime: selectedTimeSlot.startTime,
        stylistId: selectedStylist.id,
        notes: 'First time customer',
      );

      if (appointment != null) {
        print('Booking successful!');
        print('Confirmation code: ${appointment.confirmationCode}');

        // 6. Navigate to success page
        // Navigator.pushNamed(context, '/booking-success');
      }

    } catch (e) {
      print('Booking failed: $e');
    }
  }
}
```

---

## Testing

Example unit test structure:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('AuthService Tests', () {
    test('login should return LoginResponse on success', () async {
      // Arrange
      final authService = AuthService.instance;

      // Act
      final result = await authService.login(
        phone: '13800138000',
        code: '123456',
      );

      // Assert
      expect(result, isNotNull);
      expect(result?.user, isNotNull);
      expect(result?.token, isNotEmpty);
    });
  });
}
```

---

## Notes

- All API endpoints follow RESTful conventions
- Date format: `YYYY-MM-DD` (e.g., `2025-11-15`)
- Time format: `HH:mm` (e.g., `10:00`)
- Phone numbers should include country code or use local format
- All timestamps from API are automatically parsed to `DateTime` objects
