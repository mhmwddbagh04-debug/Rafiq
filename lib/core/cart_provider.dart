import 'package:Rafiq/core/api/cart_service.dart';
import 'package:flutter/material.dart';
import '../data/models/home_model.dart';
import '../data/models/cart_model.dart' as model;

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  Map<int, model.CartItem> _serverItems = {};
  double _totalPrice = 0.0;
  bool _isLoading = false;

  Map<int, model.CartItem> get items => _serverItems;
  double get totalAmount => _totalPrice;
  bool get isLoading => _isLoading;
  
  int get itemCount {
    int count = 0;
    _serverItems.forEach((key, item) {
      count += item.quantity;
    });
    return count;
  }

  Future<void> fetchCart() async {
    try {
      final response = await _cartService.getCart();
      _serverItems = { for (var item in response.items) item.productId : item };
      _totalPrice = response.totalPrice;
      notifyListeners(); // إرسال تنبيه فور استلام البيانات
    } catch (e) {
      debugPrint("Error fetching cart: $e");
    }
  }

  // دالة لجلب السلة مع حالة التحميل (للاستخدام في الشاشات الرئيسية)
  Future<void> fetchCartWithLoading() async {
    _isLoading = true;
    notifyListeners();
    await fetchCart();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(Product product) async {
    try {
      // إرسال للسيرفر
      await _cartService.addToCart(product.id, 1);
      // جلب السلة المحدثة فوراً لضمان ظهور المنتج في صفحة السلة
      await fetchCart();
    } catch (e) {
      debugPrint("Error adding to cart: $e");
    }
  }

  Future<void> addItemById(int productId) async {
    try {
      await _cartService.addToCart(productId, 1);
      await fetchCart();
    } catch (e) {
      debugPrint("Error adding by id: $e");
    }
  }

  Future<void> removeSingleItem(int productId) async {
    if (!_serverItems.containsKey(productId)) return;
    
    final item = _serverItems[productId]!;
    try {
      if (item.quantity > 1) {
        await _cartService.updateCartItem(item.id, item.quantity - 1);
      } else {
        await _cartService.deleteCartItem(item.id);
      }
      await fetchCart();
    } catch (e) {
      debugPrint("Error removing item: $e");
    }
  }

  Future<void> removeItem(int productId) async {
    if (!_serverItems.containsKey(productId)) return;
    try {
      await _cartService.deleteCartItem(_serverItems[productId]!.id);
      await fetchCart();
    } catch (e) {
      debugPrint("Error deleting item: $e");
    }
  }

  Future<void> clear() async {
    try {
      // حذف العناصر واحداً تلو الآخر (بانتظار رابط مسح الكل من الباك اند)
      final itemsToDelete = _serverItems.values.toList();
      for (var item in itemsToDelete) {
        await _cartService.deleteCartItem(item.id);
      }
      _serverItems.clear();
      _totalPrice = 0.0;
      notifyListeners();
    } catch (e) {
      debugPrint("Error clearing cart: $e");
    }
  }
}
