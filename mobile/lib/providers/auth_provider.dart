import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();
  
  User? _user;
  bool _isLoading = true; // Start with loading to check for persistent token
  String? _token;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  String? get token => _token;

  AuthProvider() {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    try {
      _token = await _storage.read(key: 'jwt_token');
      if (_token != null) {
        _user = await _apiService.fetchUserProfile(_token!);
        
        if (_user == null) {
          // Token might be invalid or expired
          _token = null;
          await _storage.delete(key: 'jwt_token');
        }
      }
    } catch (e) {
      print('Auto-login error: $e');
      // On error (e.g. network timeout), don't delete the token, 
      // just let the user try again or wait.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final token = await _apiService.login(username, password);
    if (token != null) {
      _token = token;
      await _storage.write(key: 'jwt_token', value: token);
      _user = await _apiService.fetchUserProfile(token);
      
      _isLoading = false;
      notifyListeners();
      return _user != null;
    }

    _isLoading = false;
    notifyListeners();
    return false;
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
    _isLoading = true;
    notifyListeners();

    final success = await _apiService.signup(
      username: username,
      fullName: fullName,
      phoneNumber: phoneNumber,
      password: password,
      role: role,
      licenseNumber: licenseNumber,
      panNumber: panNumber,
      openingTime: openingTime,
      closingTime: closingTime,
      contactPerson: contactPerson,
    );
    
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (_token == null) return false;
    _isLoading = true;
    notifyListeners();

    final success = await _apiService.updateUserProfile(_token!, data);
    
    if (success) {
      _user = await _apiService.fetchUserProfile(_token!);
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> updateStock(int dealerId, int full, int empty) async {
    if (_token == null) return false;
    _isLoading = true;
    notifyListeners();
    
    final success = await _apiService.updateStock(_token!, dealerId, full, empty);
    
    if (success) {
      // Re-fetch profile to potentially get updated info (though stock isn't in profile yet)
      _user = await _apiService.fetchUserProfile(_token!);
    }
    
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await _storage.delete(key: 'jwt_token');
    notifyListeners();
  }
}
