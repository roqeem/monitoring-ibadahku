import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

class AppState extends ChangeNotifier {
  UserProfile? user;
  bool loaded = false;

  AppState() {
    init();
  }

  Future<void> init() async {
    user = await _loadUser();
    loaded = true;
    notifyListeners();
  }

  Future<UserProfile?> _loadUser() async {
    // In production: persist session via SharedPreferences or secure storage
    return null;
  }

  Future<void> login(UserProfile u) async {
    user = u;
    notifyListeners();
  }

  Future<void> logout() async {
    await FirebaseService.instance.signOut();
    user = null;
    notifyListeners();
  }
}
