import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/dealer.dart';
import '../models/user.dart';

class ApiService {
  // Use the Hugging Face Space URL for the live server
  static const String baseUrl = 'https://bishal26-gas-cylinder-management.hf.space/api';

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

  Future<bool> updateUserProfile(String token, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/profile/update_me/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        return true;
      }
      print('Update profile failed: ${response.body}');
      return false;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }

  Future<bool> signup({
    required String username, 
    required String fullName, 
    required String phoneNumber, 
    required String password, 
    required UserRole role,
    String? licenseNumber,
    String? panNumber,
    String? openingTime,
    String? closingTime,
    String? contactPerson,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile/signup/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'full_name': fullName,
          'phone_number': phoneNumber,
          'password': password,
          'role': role == UserRole.dealer ? 'DEALER' : 'CUSTOMER',
          'license_number': licenseNumber,
          'pan_number': panNumber,
          'opening_time': openingTime,
          'closing_time': closingTime,
          'contact_person': contactPerson,
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

  Future<Dealer?> createDealer(String name, String brand, double lat, double lng, String address) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dealers/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'brand': brand,
          'latitude': lat,
          'longitude': lng,
          'address': address,
        }),
      );
      
      if (response.statusCode == 201) {
        return Dealer.fromJson(json.decode(response.body));
      }
    } catch (e) {
      print('Error creating dealer: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchOfficialStock(int dealerId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stock/?dealer=$dealerId'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) return data[0];
      }
    } catch (e) {
      print('Error fetching official stock: $e');
    }
    return null;
  }

  Future<bool> requestToken(String token, int dealerId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tokens/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'dealer_id': dealerId}),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Token request error: $e');
      return false;
    }
  }

  Future<List<dynamic>> fetchTokens(String token, int dealerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tokens/?dealer=$dealerId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching tokens: $e');
    }
    return [];
  }

  Future<bool> fulfillToken(String token, int tokenId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tokens/$tokenId/fulfill/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Token fulfillment error: $e');
      return false;
    }
  }

  // Google Places API Key (Using the same one provided for Android/iOS)
  static const String googleMapsApiKey = 'AIzaSyBlBI8VS5joyt525hxNxYqabaHyp7kFKoE';

  Future<List<Map<String, dynamic>>> fetchNearbyPlaces(double lat, double lng) async {
    // Search for gas cylinder dealers and depots within 5km
    final url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$lat,$lng'
        '&radius=5000'
        '&keyword=gas%20cylinder%20dealer|gas%20depot|LPG%20gas%20store'
        '&key=$googleMapsApiKey';

    try {
      print('Places API request: $url');
      final response = await http.get(Uri.parse(url));
      print('Places API status: ${response.statusCode}');
      print('Places API body: ${response.body.substring(0, response.body.length.clamp(0, 500))}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'];
        print('Places API Google status: $status');
        return List<Map<String, dynamic>>.from(data['results'] ?? []);
      }
    } catch (e) {
      print('Error fetching nearby places: $e');
    }
    return [];
  }
}
