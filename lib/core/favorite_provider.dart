import 'dart:convert';
import 'package:Rafiq/data/models/home_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProvider extends ChangeNotifier {
  List<Product> _favoriteProducts = [];

  List<Product> get favorites => _favoriteProducts;

  FavoriteProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString('favorite_products');
      if (favoritesJson != null) {
        final List<dynamic> decodedList = jsonDecode(favoritesJson);
        _favoriteProducts = decodedList.map((item) => Product.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading favorites: $e");
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedList = jsonEncode(_favoriteProducts.map((p) => p.toJson()).toList());
      await prefs.setString('favorite_products', encodedList);
    } catch (e) {
      debugPrint("Error saving favorites: $e");
    }
  }

  void toggleFavorite(Product product) {
    final index = _favoriteProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _favoriteProducts.removeAt(index);
    } else {
      _favoriteProducts.add(product);
    }
    _saveFavorites(); // حفظ التغييرات فوراً
    notifyListeners();
  }

  bool isFavorite(int productId) {
    return _favoriteProducts.any((p) => p.id == productId);
  }
}
