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

  Future<bool> reportSighting(int dealerId, bool isAvailable, String notes) async {
    final success = await _apiService.reportSighting(dealerId, isAvailable, notes);
    if (success) await refreshDealers();
    return success;
  }

  Future<bool> requestToken(String token, int dealerId) async {
    return await _apiService.requestToken(token, dealerId);
  }
}
