import 'package:flutter/material.dart';
import '../models/dealer.dart';
import '../services/api_service.dart';

class DealerProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Dealer> _dealers = [];
  bool _isLoading = false;

  List<Dealer> get dealers => _dealers;
  bool get isLoading => _isLoading;

  Future<void> refreshDealers() async {
    _isLoading = true;
    notifyListeners();
    
    _dealers = await _apiService.fetchDealers();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addSighting(int dealerId, bool isAvailable, String notes) async {
    final success = await _apiService.reportSighting(dealerId, isAvailable, notes);
    if (success) {
      await refreshDealers(); // Refresh map after reporting
    }
    return success;
  }
}
