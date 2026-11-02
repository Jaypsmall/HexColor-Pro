import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rust_engine.dart';

class FavoritesManager extends ChangeNotifier {
  static final FavoritesManager _instance = FavoritesManager._internal();
  factory FavoritesManager() => _instance;

  FavoritesManager._internal() {
    loadFavorites();
  }

  List<String> _favorites = [];

  List<String> get favorites => List.unmodifiable(_favorites);

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('fav_colors') ?? [];
    _favorites = raw.map((hex) => _normalizeHex(hex)).where((h) => h.isNotEmpty).toList();
    notifyListeners();
  }

  String _normalizeHex(String hex) {
    String clean = hex.replaceAll('#', '').trim().toUpperCase();
    if (clean.length == 6) {
      return '#$clean';
    } else if (clean.length == 8) {
      return '#${clean.substring(2)}';
    }
    return '';
  }

  bool isFavorite(Color color) {
    final hex = RustEngine.colorToHex(color);
    return _favorites.contains(hex);
  }

  bool isFavoriteHex(String hex) {
    final norm = _normalizeHex(hex);
    return _favorites.contains(norm);
  }

  Future<bool> toggleFavorite(Color color) async {
    final hex = RustEngine.colorToHex(color);
    if (_favorites.contains(hex)) {
      await removeFavorite(hex);
      return false; // Now removed
    } else {
      await addFavorite(hex);
      return true; // Now added
    }
  }

  Future<void> addFavorite(String hex) async {
    final norm = _normalizeHex(hex);
    if (norm.isEmpty) return;

    if (!_favorites.contains(norm)) {
      _favorites.add(norm);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('fav_colors', _favorites);
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String hex) async {
    final norm = _normalizeHex(hex);
    if (_favorites.contains(norm)) {
      _favorites.remove(norm);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('fav_colors', _favorites);
      notifyListeners();
    }
  }

  Future<void> clearAll() async {
    _favorites.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fav_colors');
    notifyListeners();
  }
}
