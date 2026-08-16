/// Penyimpanan lokal berbasis SharedPreferences.
/// Frontend-first: semua data ibadah disimpan di perangkat. Sinkronisasi
/// cloud (Firebase) menyusul pada fase backend.
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class LocalStore {
  static const _kUser = 'user';
  static const _kOnboarding = 'onboarding_done';
  static const _kSettings = 'settings';
  static const _kDays = 'daily_data_v1';
  static const _kConditions = 'conditions';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // -- profil & onboarding -------------------------------------------------
  Future<UserProfile?> loadUser() async {
    final p = await _prefs;
    final raw = p.getString(_kUser);
    if (raw == null) return null;
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveUser(UserProfile user) async {
    final p = await _prefs;
    await p.setString(_kUser, jsonEncode(user.toJson()));
  }

  Future<void> clearUser() async {
    final p = await _prefs;
    await p.remove(_kUser);
  }

  Future<bool> loadOnboarding() async {
    final p = await _prefs;
    return p.getBool(_kOnboarding) ?? false;
  }

  Future<void> saveOnboarding(bool done) async {
    final p = await _prefs;
    await p.setBool(_kOnboarding, done);
  }

  // -- settings ------------------------------------------------------------
  Future<UserSettings> loadSettings() async {
    final p = await _prefs;
    final raw = p.getString(_kSettings);
    if (raw == null) return UserSettings();
    return UserSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSettings(UserSettings s) async {
    final p = await _prefs;
    await p.setString(_kSettings, jsonEncode(s.toJson()));
  }

  // -- data harian ---------------------------------------------------------
  Future<Map<String, DailyData>> loadDays() async {
    final p = await _prefs;
    final raw = p.getString(_kDays);
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(
        k, DailyData.fromJson(v as Map<String, dynamic>)));
  }

  Future<void> saveDays(Map<String, DailyData> days) async {
    final p = await _prefs;
    await p.setString(
        _kDays, jsonEncode(days.map((k, v) => MapEntry(k, v.toJson()))));
  }

  // -- kondisi khusus ------------------------------------------------------
  Future<List<SpecialCondition>> loadConditions() async {
    final p = await _prefs;
    final raw = p.getString(_kConditions);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SpecialCondition.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveConditions(List<SpecialCondition> c) async {
    final p = await _prefs;
    await p.setString(
        _kConditions, jsonEncode(c.map((e) => e.toJson()).toList()));
  }

  Future<void> wipeAll() async {
    final p = await _prefs;
    await p.remove(_kDays);
    await p.remove(_kConditions);
    await p.remove(_kSettings);
  }
}
