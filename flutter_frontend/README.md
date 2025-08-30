# Recycle App - Flutter Frontend

This is the Flutter frontend for the Recycle App, which integrates with a Node.js backend and blockchain smart contracts for product tracking and recycling rewards.

## Features

- **User Authentication**: Register and login functionality
- **QR Code Scanning**: Scan products and recycling codes
- **Product Management**: Track owned products and their lifecycle
- **Recycling System**: Process product disposal and earn rewards
- **Rewards System**: View reward points and transaction history
- **Profile Management**: User profile and settings

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user.dart
│   ├── product.dart
│   └── reward_transaction.dart
├── providers/                # State management
│   └── auth_provider.dart
├── screens/                  # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home_screen.dart
│   ├── qr_scanner_screen.dart
│   ├── products_screen.dart
│   ├── rewards_screen.dart
│   ├── profile_screen.dart
│   └── splash_screen.dart
├── services/                 # API and external services
│   └── api_service.dart
├── utils/                    # Utilities and constants
│   └── constants.dart
└── widgets/                  # Reusable widgets
```

## Setup Instructions

1. **Prerequisites**
   - Flutter SDK installed
   - Android Studio/VS Code with Flutter extensions
   - Backend server running (see backend folder)

2. **Installation**
   ```bash
   cd flutter_frontend
   flutter pub get
   ```

3. **Configuration**
   - Update the API base URL in `lib/utils/constants.dart`
   - Ensure your backend server is running on the specified port

4. **Running the App**
   ```bash
   flutter run
   ```

## API Integration

The app connects to the following backend endpoints:

- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get current user
- `POST /api/products/add` - Add new product
- `POST /api/products/scan-by-consumer` - Scan product
- `POST /api/recycle/process` - Process recycling
- `GET /api/rewards/my` - Get user rewards
- `POST /api/rewards/redeem` - Redeem points

## Key Features Implemented

### Authentication
- Secure login and registration
- JWT token management
- Persistent authentication state

### QR Code Functionality
- Camera-based QR code scanning
- Product barcode scanning
- User QR code display

### Product Tracking
- Add products to user inventory
- Track product lifecycle
- Product disposal and recycling

### Rewards System
- Earn points for recycling
- View transaction history
- Redeem reward points

## Dependencies

- `provider`: State management
- `http`: API communication
- `shared_preferences`: Local storage
- `qr_code_scanner`: QR code scanning
- `qr_flutter`: QR code generation
- `permission_handler`: Camera permissions

## Notes

- The app requires camera permissions for QR code scanning
- Make sure your backend server is running before testing
- Update the API base URL in constants.dart to match your backend
- For production, implement proper error handling and loading states

## Development Tips

1. **Testing with Backend**: Start the backend server first, then run the Flutter app
2. **Debugging**: Use Flutter DevTools for debugging and performance monitoring
3. **API Testing**: Test API endpoints individually before integrating with the app
4. **State Management**: The app uses Provider for state management - extend as needed

## Future Enhancements

- Add offline support
- Implement real QR code generation
- Add biometric authentication
- Implement push notifications
- Add data visualization for environmental impact
