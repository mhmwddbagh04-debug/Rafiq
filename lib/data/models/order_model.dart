class OrderResponse {
  final int id;
  final String orderDate;
  final String status;
  final double totalAmount;
  final String? address;
  final String? phone;
  final String? notes;
  final List<OrderItem>? items;

  OrderResponse({
    required this.id,
    required this.orderDate,
    required this.status,
    required this.totalAmount,
    this.address,
    this.phone,
    this.notes,
    this.items,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    // تحويل الحالة من رقم إلى نص إذا لزم الأمر
    String getStatusString(dynamic status) {
      if (status is int) {
        switch (status) {
          case 0: return "Pending";
          case 1: return "Paid";
          case 2: return "Shipped";
          case 3: return "Delivered";
          case 4: return "Cancelled";
          default: return "Status $status";
        }
      }
      return status?.toString() ?? "Pending";
    }

    return OrderResponse(
      id: json['id'] ?? json['orderId'] ?? 0,
      orderDate: json['createAt'] ?? json['orderDate'] ?? json['date'] ?? "",
      status: getStatusString(json['status'] ?? json['orderStatus']),
      totalAmount: (json['totalPrice'] ?? json['totalAmount'] ?? json['price'] ?? 0.0).toDouble(),
      address: json['address'] ?? json['shippingAddress'],
      phone: json['phone'] ?? json['phoneNumber'] ?? json['customerPhone'] ?? json['customerPhoneNumber'] ?? json['tele'],
      notes: json['notes'],
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
      id: json['id'] ?? 0,
      productName: json['productName'] ?? "",
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }
}
