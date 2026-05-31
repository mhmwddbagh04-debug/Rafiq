import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../data/models/order_model.dart';
import 'dio_client.dart';

class OrderService {
  final Dio _dio = DioClient.instance;

  // إتمام الطلب (Checkout)
  Future<Map<String, dynamic>> checkout({required String address, String? notes}) async {
    try {
      final response = await _dio.post("/Customer/Order/checkout", data: {
        "address": address,
        "notes": notes,
      });
      debugPrint("✅ [Checkout Success]: ${response.data}");
      return response.data is Map ? response.data : {"orderId": response.data};
    } on DioException catch (e) {
      debugPrint("❌ [Checkout Error]: ${e.response?.statusCode} - ${e.response?.data}");
      throw Exception(e.response?.data['message'] ?? "Checkout failed");
    }
  }

  // جلب كل طلباتي (GET)
  Future<List<OrderResponse>> getMyOrders() async {
    try {
      final response = await _dio.get("/Customer/Order/my-orders");
      debugPrint("📥 [Get Orders Success]: ${response.data}");
      
      dynamic rawData = response.data;
      List dataList = [];
      
      if (rawData is List) {
        dataList = rawData;
      } else if (rawData is Map) {
        // التحقق من مفاتيح محتملة أخرى قد يرسلها السيرفر
        dataList = rawData['data'] ?? rawData['Data'] ?? rawData['orders'] ?? rawData['items'] ?? [];
      }
      
      return dataList.map((o) => OrderResponse.fromJson(o)).toList();
    } on DioException catch (e) {
      debugPrint("❌ [Get Orders Error]: ${e.response?.statusCode} - ${e.response?.data}");
      throw Exception(e.response?.data['message'] ?? "Failed to load orders");
    }
  }

  // جلب تفاصيل طلب واحد
  Future<OrderResponse> getOrderDetails(int orderId) async {
    try {
      final response = await _dio.get("/Customer/Order/$orderId");
      debugPrint("📥 [Get Order Details Success]: ${response.data}");
      return OrderResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("❌ [Get Order Details Error]: ${e.response?.statusCode} - ${e.response?.data}");
      throw Exception(e.response?.data['message'] ?? "Failed to load order details");
    }
  }

  // إلغاء الطلب (POST)
  Future<void> cancelOrder(int orderId) async {
    try {
      // المحاولة الأولى: المعرف في المسار
      await _dio.post("/Customer/Order/cancel/$orderId");
      debugPrint("✅ [Cancel Order Success]: Order #$orderId");
    } on DioException catch (e) {
      debugPrint("❌ [Cancel Order Error]: ${e.response?.statusCode} - ${e.response?.data}");
      
      // محاولة بديلة 1: المعرف في المسار بطريقة أخرى (بعض الـ APIs تستخدم هذا النمط)
      if (e.response?.statusCode == 404 || e.response?.statusCode == 405) {
        try {
          debugPrint("🔄 [Cancel Order Retry 1] Trying /Customer/Order/$orderId/cancel...");
          await _dio.post("/Customer/Order/$orderId/cancel");
          debugPrint("✅ [Cancel Order Retry 1 Success]");
          return;
        } catch (_) {}
      }

      // محاولة بديلة 2: تمرير المعرف في الجسم (Body)
      if (e.response?.statusCode == 404) {
        try {
          debugPrint("🔄 [Cancel Order Retry 2] Trying with orderId in Body...");
          await _dio.post("/Customer/Order/cancel", data: {"orderId": orderId});
          debugPrint("✅ [Cancel Order Retry 2 Success]");
          return;
        } catch (retryE) {
          debugPrint("❌ [Cancel Order Retry 2 Failed]: $retryE");
        }
      }

      String errorMsg = "Failed to cancel order";
      if (e.response?.data != null) {
        if (e.response?.data is Map) {
          errorMsg = e.response?.data['message'] ?? e.response?.data['error'] ?? errorMsg;
        } else if (e.response?.data is String) {
          errorMsg = e.response?.data;
        }
      }
      throw Exception(errorMsg);
    }
  }
}
