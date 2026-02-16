// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://almerpro.com/api';

  // Token management
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ========== AUTHENTICATION ==========
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String phone,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: await getHeaders(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'phone_number': phone,
      }),
    );

    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: await getHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['token'] != null) {
      await saveToken(data['token']);
    }

    return data;
  }

  Future<void> logout() async {
    await removeToken();
  }

  // ========== DAFTAR KAMERA ==========
  Future<List<dynamic>> getAllCameras() async {
    final response = await http.get(
      Uri.parse('$baseUrl/all/camera'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final data = jsonDecode(response.body);
      return data is List ? data : data['data'] ?? [];
    }

    throw Exception('Failed to load cameras');
  }

  Future<Map<String, dynamic>> getCountCamera() async {
    final response = await http.get(
      Uri.parse('$baseUrl/count/camera'),
      headers: await getHeaders(),
    );

    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    return jsonDecode(response.body);
  }

  // ========== PEMBAYARAN & RENTAL ==========
  Future<Map<String, dynamic>> createRental(
      int cameraId, String startDate, String endDate) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rentals'),
      headers: await getHeaders(),
      body: jsonEncode({
        'camera_id': cameraId,
        'start_date': startDate,
        'due_date': endDate,
      }),
    );

    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    final data = jsonDecode(response.body);
    print('Create Rental Response: $data');
    return data;
  }

  Future<Map<String, dynamic>> payRental(int rentalId, String method) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rentals/$rentalId/pay'),
      headers: await getHeaders(),
      body: jsonEncode({'method': method}),
    );

    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    return jsonDecode(response.body);
  }

  // ========== HISTORI ==========
  Future<List<dynamic>> getUserRentals() async {
    final response = await http.get(
      Uri.parse('$baseUrl/rentals'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final data = jsonDecode(response.body);
      return data is List ? data : data['data'] ?? [];
    }

    throw Exception('Failed to load rentals');
  }

  // ========== PROFILE/AKUN ==========
  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load profile');
  }
}