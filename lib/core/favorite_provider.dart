import 'package:Rafiq/data/models/home_model.dart';
import 'package:flutter/material.dart';

class FavoriteProvider extends ChangeNotifier {
  final List<Product> _favoriteProducts = [];

  List<Product> get favorites => _favoriteProducts;

  void toggleFavorite(Product product) {
    final index = _favoriteProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _favoriteProducts.removeAt(index);
    } else {
      _favoriteProducts.add(product);
    }
    notifyListeners();
  }

  bool isFavorite(int productId) {
    return _favoriteProducts.any((p) => p.id == productId);
  }
}
