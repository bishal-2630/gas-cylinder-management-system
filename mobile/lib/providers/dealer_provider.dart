import 'package:flutter/material.dart';
import '../models/dealer.dart';
import '../services/api_service.dart';

class DealerProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Dealer> _dealers = [];
  bool _isLoading = false;

  List<Dealer> get dealers => _dealers;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? _officialStock;
  Map<String, dynamic>? get officialStock => _officialStock;

  List<dynamic> _tokens = [];
  List<dynamic> get tokens => _tokens;

  List<dynamic> _userTokens = [];
  List<dynamic> get userTokens => _userTokens;

  String? _selectedBrandFilter;
  String? get selectedBrandFilter => _selectedBrandFilter;

  Future<void> fetchStock(int dealerId) async {
    _officialStock = await _apiService.fetchOfficialStock(dealerId);
    notifyListeners();
  }

  Future<void> fetchTokens(String authToken, int dealerId) async {
    // We should add this method to ApiService too, but for now we'll use a generic fetch
    // Actually let's assume ApiService has fetchTokens or we add it
    try {
      final response = await _apiService.fetchTokens(authToken, dealerId);
      _tokens = response;
      notifyListeners();
    } catch (e) {
      print('Error fetching tokens: $e');
    }
  }

  Future<void> fetchUserTokens(String authToken) async {
    try {
      final response = await _apiService.fetchTokens(authToken);
      _userTokens = response;
      notifyListeners();
    } catch (e) {
      print('Error fetching user tokens: $e');
    }
  }

  Future<bool> fulfillToken(String authToken, int tokenId, int dealerId) async {
    final success = await _apiService.fulfillToken(authToken, tokenId);
    if (success) {
      await fetchTokens(authToken, dealerId);
    }
    return success;
  }

  Future<void> refreshDealers() async {
    _isLoading = true;
    notifyListeners();
    _dealers = await _apiService.fetchDealers();
    _isLoading = false;
    notifyListeners();
  }

  List<Dealer> get filteredDealers {
    if (_selectedBrandFilter == null || _selectedBrandFilter!.isEmpty) {
      return _dealers;
    }
    return _dealers.where((d) => d.brand == _selectedBrandFilter).toList();
  }

  void setBrandFilter(String? brand) {
    _selectedBrandFilter = brand;
    notifyListeners();
  }

  Future<bool> addSighting(int dealerId, bool isAvailable, String notes, [String? brand]) async {
    final success = await _apiService.reportSighting(dealerId, isAvailable, notes, brand);
    if (success) await refreshDealers();
    return success;
  }

  Future<bool> requestToken(String token, int dealerId) async {
    return await _apiService.requestToken(token, dealerId);
  }

  List<Map<String, dynamic>> _nearbyPlaces = [];
  List<Map<String, dynamic>> get nearbyPlaces => _nearbyPlaces;

  Future<void> findNearbyGasStores(double lat, double lng) async {
    _isLoading = true;
    notifyListeners();
    _nearbyPlaces = await _apiService.fetchNearbyPlaces(lat, lng);
    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> searchPlace(String query) async {
    return await _apiService.searchPlace(query);
  }
}
