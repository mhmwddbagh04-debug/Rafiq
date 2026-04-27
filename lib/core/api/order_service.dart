import 'package:dio/dio.dart';
import '../../data/models/order_model.dart';
import 'dio_client.dart';

class OrderService {
  final Dio _dio = DioClient.instance;

  // إتمام الطلب (Checkout) ويرد برابط الدفع
  Future<String?> checkout() async {
    try {
      final response = await _dio.post("/Customer/Order/checkout");
      // نفترض أن الرابط يعود في حقل اسمه paymentUrl أو url
      return response.data['paymentUrl'] ?? response.data['url'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Checkout failed");
    }
  }

  // جلب كل طلباتي (GET)
  Future<List<OrderResponse>> getMyOrders() async {
    try {
      final response = await _dio.get("/Customer/Order/my-orders");
      final List data = response.data;
      return data.map((o) => OrderResponse.fromJson(o)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to load orders");
    }
  }

  // جلب تفاصيل طلب واحد
  Future<OrderResponse> getOrderDetails(int orderId) async {
    try {
      final response = await _dio.get("/Customer/Order/$orderId");
      return OrderResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to load order details");
    }
  }

  // إلغاء الطلب (POST)
  Future<void> cancelOrder(int orderId) async {
    try {
      await _dio.post("/Customer/Order/cancel/$orderId");
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to cancel order");
    }
  }
}
