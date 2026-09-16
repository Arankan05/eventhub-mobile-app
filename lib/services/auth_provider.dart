import 'package:flutter/material.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isOrganizer => _user?.role == UserRole.organizer;

  Future<void> checkAuth() async {
    _user = await _storageService.getUser();
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.login(email, password);
      _user = User.fromJson(response['user']);
      await _storageService.saveUser(_user!);
      await _storageService.saveToken(response['token']);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.register(userData);
      _user = User.fromJson(response);
      await _storageService.saveUser(_user!);
      // In a real app, registration might return a token or require login
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storageService.clearAll();
    _user = null;
    notifyListeners();
  }
}
