class OrderResponse {
  final int id;
  final String orderDate;
  final String status;
  final double totalAmount;
  final List<OrderItem>? items;

  OrderResponse({
    required this.id,
    required this.orderDate,
    required this.status,
    required this.totalAmount,
    this.items,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      id: json['id'],
      orderDate: json['orderDate'] ?? "",
      status: json['status'] ?? "Pending",
      totalAmount: (json['totalAmount'] as num).toDouble(),
      items: (json['items'] as List?)?.map((i) => OrderItem.fromJson(i)).toList(),
    );
  }
}

class OrderItem {
  final int id;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productName: json['productName'] ?? "",
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num).toDouble(),
    );
  }
}
