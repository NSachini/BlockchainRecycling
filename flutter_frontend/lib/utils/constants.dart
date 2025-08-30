class Constants {
  // API Base URL - Change this to your backend server URL
  static const String apiBaseUrl = 'http://localhost:5000/api';
  
  // App Information
  static const String appName = 'Recycle App';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String tokenKey = 'token';
  static const String userKey = 'user';
  
  // Error Messages
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String unknownErrorMessage = 'An unknown error occurred.';
  
  // Success Messages
  static const String loginSuccessMessage = 'Login successful!';
  static const String registerSuccessMessage = 'Registration successful!';
  static const String logoutSuccessMessage = 'Logged out successfully!';
}
