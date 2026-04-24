import 'home_model.dart';

class CartResponse {
  final int id;
  final List<CartItem> items;
  final double totalPrice;

  CartResponse({required this.id, required this.items, required this.totalPrice});

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      id: json['id'] ?? 0,
      items: (json['items'] as List?)?.map((i) => CartItem.fromJson(i)).toList() ?? [],
      totalPrice: _toDouble(json['totalPrice'] ?? json['totalAmount']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class CartItem {
  final int id;
  final int productId;
  final String productName;
  final String productImg;
  final double price;
  final int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImg,
    required this.price,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? 0,
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? "Unknown",
      productImg: json['img'] ?? "",
      price: _toDouble(json['productPrice']), // تم التغيير لـ productPrice
      quantity: json['quantity'] ?? 0,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
