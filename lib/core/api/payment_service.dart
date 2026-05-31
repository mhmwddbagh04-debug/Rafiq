import 'package:Rafiq/core/api/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

class PaymentService {
  final Dio _dio = DioClient.instance;

  Future<String?> createSession(int orderId) async {
    try {
      // محاولة أولى: كـ Path Parameter (كما ذكرت في الطلب)
      final url = "/Customer/Payment/create-session/$orderId";
      debugPrint("🚀 [Payment Request] POST $url");
      
      final sessionRes = await _dio.post(url);
      
      debugPrint("✅ [Payment Session Success]: ${sessionRes.data}");
      return sessionRes.data['url'] ?? sessionRes.data['paymentUrl'];
    } on DioException catch (e) {
      debugPrint("❌ [Payment Error]: ${e.response?.statusCode} - ${e.response?.data}");
      
      // محاولة بديلة فقط في حال كان الخطأ 404 أو 405 (احتمالية خطأ في المسار)
      if (e.response?.statusCode == 404 || e.response?.statusCode == 405) {
        try {
           debugPrint("🔄 [Payment Retry] Trying with orderId in Body...");
           final retryRes = await _dio.post("/Customer/Payment/create-session", data: {"orderId": orderId});
           debugPrint("✅ [Payment Retry Success]: ${retryRes.data}");
           return retryRes.data['url'] ?? retryRes.data['paymentUrl'];
        } catch (retryE) {
           debugPrint("❌ [Payment Retry Failed]: $retryE");
        }
      }

      String errorMsg = "فشل في إنشاء جلسة الدفع";
      if (e.response?.data != null) {
        if (e.response?.data is Map) {
          errorMsg = e.response?.data['message'] ?? e.response?.data['error'] ?? errorMsg;
        } else if (e.response?.data is String) {
          errorMsg = e.response?.data!;
        }
      }
      throw Exception(errorMsg);
    } catch (e) {
      debugPrint("خطأ غير متوقع: $e");
      rethrow;
    }
  }

  /// دالة متوافقة مع الكود القديم في OrdersScreen
  Future<String> makePayment({
    required BuildContext context,
    required double amount,
    int? orderId,
  }) async {
    try {
      if (orderId == null) return 'error';
      
      final url = await createSession(orderId);
      if (url != null && url.isNotEmpty) {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return 'redirected';
        }
      }
      return 'error';
    } catch (e) {
      debugPrint("❌ [makePayment Error]: $e");
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains("pending")) {
        return "pending_order_error";
      } else if (errorStr.contains("server") || errorStr.contains("500")) {
        return "server_error";
      }
      return 'error';
    }
  }
}
