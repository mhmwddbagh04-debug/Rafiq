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
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching cart: $e");
    }
  }

  Future<void> fetchCartWithLoading() async {
    _isLoading = true;
    notifyListeners();
    await fetchCart();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(Product product, {int quantity = 1}) async {
    if (_serverItems.containsKey(product.id)) {
      final existing = _serverItems[product.id]!;
      _serverItems[product.id] = model.CartItem(
        id: existing.id,
        productId: existing.productId,
        productName: existing.productName,
        productImg: existing.productImg,
        price: existing.price,
        quantity: existing.quantity + quantity,
      );
    } else {
      _serverItems[product.id] = model.CartItem(
        id: 0, 
        productId: product.id,
        productName: product.name,
        productImg: product.imageUrl,
        price: product.price,
        quantity: quantity,
      );
    }
    _totalPrice += (product.price * quantity);
    notifyListeners();

    try {
      await _cartService.addToCart(product.id, quantity);
      await Future.delayed(const Duration(milliseconds: 500));
      await fetchCart();
    } catch (e) {
      await fetchCart();
    }
  }

  Future<void> addItemById(int productId) async {
    if (_serverItems.containsKey(productId)) {
      final item = _serverItems[productId]!;
      _serverItems[productId] = model.CartItem(
        id: item.id,
        productId: item.productId,
        productName: item.productName,
        productImg: item.productImg,
        price: item.price,
        quantity: item.quantity + 1,
      );
      _totalPrice += item.price;
      notifyListeners();
    }

    try {
      await _cartService.addToCart(productId, 1);
      await Future.delayed(const Duration(milliseconds: 500));
      await fetchCart();
    } catch (e) {
      await fetchCart();
    }
  }

  Future<void> removeSingleItem(int productId) async {
    if (!_serverItems.containsKey(productId)) return;
    
    final item = _serverItems[productId]!;
    final int oldQuantity = item.quantity;

    // 1. تحديث متفائل (إظهار النتيجة فوراً للـ UI)
    if (oldQuantity > 1) {
      _serverItems[productId] = model.CartItem(
        id: item.id,
        productId: item.productId,
        productName: item.productName,
        productImg: item.productImg,
        price: item.price,
        quantity: oldQuantity - 1,
      );
      _totalPrice -= item.price;
    } else {
      _totalPrice -= item.price;
      _serverItems.remove(productId);
    }
    notifyListeners();

    try {
      // 2. استخدام addToCart مع -1 للإنقاص (أضمن طريقة بدلاً من PUT أو DELETE)
      // السيرفر سيتعامل معها بذكاء: إنقاص واحد، وإذا وصل لصفر سيحذفه
      await _cartService.addToCart(productId, -1);
      
      // 3. تأخير بسيط لضمان استقرار السيرفر ثم المزامنة
      await Future.delayed(const Duration(milliseconds: 500));
      await fetchCart();
    } catch (e) {
      // في حالة الفشل نستعيد البيانات الحقيقية
      await fetchCart();
      debugPrint("Error removing item: $e");
    }
  }

  Future<void> removeItem(int productId) async {
    if (!_serverItems.containsKey(productId)) return;
    final item = _serverItems[productId]!;
    
    _totalPrice -= (item.price * item.quantity);
    _serverItems.remove(productId);
    notifyListeners();

    try {
      await _cartService.deleteCartItem(item.id);
      await Future.delayed(const Duration(milliseconds: 500));
      await fetchCart();
    } catch (e) {
      await fetchCart();
    }
  }

  Future<void> clear() async {
    try {
      final itemsToDelete = _serverItems.values.toList();
      _serverItems.clear();
      _totalPrice = 0.0;
      notifyListeners();

      for (var item in itemsToDelete) {
        await _cartService.deleteCartItem(item.id);
      }
      await Future.delayed(const Duration(milliseconds: 500));
      await fetchCart();
    } catch (e) {
      debugPrint("Error clearing cart: $e");
    }
  }
}
