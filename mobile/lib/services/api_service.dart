import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/dealer.dart';
import '../models/user.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator to reach localhost
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  Future<List<Dealer>> fetchDealers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dealers/'));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Dealer.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load dealers');
      }
    } catch (e) {
      print('Error fetching dealers: $e');
      return [];
    }
  }

  Future<String?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/token/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body)['access'];
      }
    } catch (e) {
      print('Login error: $e');
    }
    return null;
  }

  Future<User?> fetchUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/me/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      }
    } catch (e) {
      print('Fetch profile error: $e');
    }
    return null;
  }

  Future<bool> signup(String username, String email, String password, UserRole role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile/signup/'), // We need to create this endpoint
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'role': role == UserRole.dealer ? 'DEALER' : 'CUSTOMER',
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Signup error: $e');
      return false;
    }
  }

  Future<bool> updateStock(String token, int dealerId, int full, int empty) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/stock/$dealerId/'), // Assuming ID matches stock record
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'full_cylinders': full,
          'empty_cylinders': empty,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Stock update error: $e');
      return false;
    }
  }

  Future<bool> reportSighting(int dealerId, bool isAvailable, String notes) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sightings/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'dealer_id': dealerId,
          'is_available': isAvailable,
          'notes': notes,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error reporting sighting: $e');
      return false;
    }
  }
}
