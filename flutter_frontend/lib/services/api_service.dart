import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Dynamic base URL based on platform
  static String get baseUrl {
    if (kIsWeb) {
      // For web development
      return 'http://localhost:3001/api';
    } else if (Platform.isAndroid) {
      // For Android emulator
      return 'http://10.0.2.2:3001/api';
    } else if (Platform.isIOS) {
      // For iOS simulator
      return 'http://localhost:3001/api';
    } else {
      // Default fallback
      return 'http://localhost:3001/api';
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
      };

  static Future<Map<String, String>> get authHeaders async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'x-auth-token': token,
    };
  }

  // Auth endpoints
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      print('🔄 Attempting registration to: $baseUrl/auth/register');

      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/register'),
        headers: headers,
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      )
          .timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception(
              'Connection timeout. Please check if the backend server is running on port 5000.');
        },
      );

      print('📱 Response status: ${response.statusCode}');
      print('📱 Response body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'No response from server. Backend URL: $baseUrl'
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await saveToken(data['token']);
        return {'success': true, 'user': data['user']};
      } else {
        return {
          'success': false,
          'message': data['msg'] ?? 'Registration failed'
        };
      }
    } catch (e) {
      print('❌ Registration error: $e');
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup')) {
        return {
          'success': false,
          'message':
              'Cannot connect to server. Please ensure:\n1. Backend is running on port 5000\n2. Network connectivity is available\n\nTrying to connect to: $baseUrl'
        };
      }
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔄 Attempting login to: $baseUrl/auth/login');
      print('📧 Email: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message':
              'No response from server. Is backend running and accessible?'
        };
      }
      print('📊 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await saveToken(data['token']);
        print('✅ Login successful for user: ${data['user']['username']}');
        return {'success': true, 'user': data['user']};
      } else {
        print('❌ Login failed: ${data['msg']}');
        return {'success': false, 'message': data['msg'] ?? 'Login failed'};
      }
    } catch (e) {
      print('🚨 Network error during login: $e');
      return {
        'success': false,
        'message':
            'Network error: Check if backend server is running. Error: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: await authHeaders,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'user': data};
      } else {
        return {
          'success': false,
          'message': data['msg'] ?? 'Failed to get user'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Product endpoints
  static Future<Map<String, dynamic>> addProduct({
    required String barcode,
    required String name,
    required String category,
    required String manufacturer,
    required String manufactureDate,
    List<Map<String, dynamic>>? distributionHistory,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products/add'),
        headers: await authHeaders,
        body: jsonEncode({
          'barcode': barcode,
          'name': name,
          'category': category,
          'manufacturer': manufacturer,
          'manufactureDate': manufactureDate,
          'distributionHistory': distributionHistory ?? [],
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'product': data['product']};
      } else {
        return {
          'success': false,
          'message': data['msg'] ?? 'Failed to add product'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> scanProduct(String barcode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products/scan-by-consumer'),
        headers: await authHeaders,
        body: jsonEncode({'barcode': barcode}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'product': data['product']};
      } else {
        return {
          'success': false,
          'message': data['msg'] ?? 'Failed to scan product'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Recycling endpoints
  static Future<Map<String, dynamic>> processRecycling({
    required String productBarcode,
    required String userQRData,
    required String disposalMachineLocation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recycle/process'),
        headers: await authHeaders,
        body: jsonEncode({
          'productBarcode': productBarcode,
          'userQRData': userQRData,
          'disposalMachineLocation': disposalMachineLocation,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['msg'] ?? 'Failed to process recycling'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Rewards endpoints
  static Future<Map<String, dynamic>> getRewards() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rewards/my'),
        headers: await authHeaders,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['msg'] ?? 'Failed to get rewards'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> redeemRewards({
    required int pointsToRedeem,
    required String description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rewards/redeem'),
        headers: await authHeaders,
        body: jsonEncode({
          'pointsToRedeem': pointsToRedeem,
          'description': description,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['msg'] ?? 'Failed to redeem rewards'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
