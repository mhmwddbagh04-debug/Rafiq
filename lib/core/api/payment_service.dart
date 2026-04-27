import 'package:Rafiq/core/api/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

class PaymentService {
  final Dio _dio = DioClient.instance;

  /// Returns:
  /// 'redirected' -> User sent to browser.
  /// 'success'    -> Payment completed successfully (for native payment sheet).
  /// 'error'      -> Something went wrong.
  Future<String> makePayment({
    required BuildContext context,
    required double amount,
  }) async {
    try {
      debugPrint("بدء عملية الدفع للمبلغ: $amount");

      // 1. طلب الـ Checkout
      // ملاحظة للباك اند: يجب أن يقوم هذا الرابط بإنشاء طلب جديد بناءً على السلة الحالية
      final response = await _dio.post("/Customer/Order/checkout");
      debugPrint("استجابة الـ Checkout: ${response.data}");
      
      int? orderId = response.data['orderId'];

      if (orderId != null) {
        // 2. طلب جلسة الدفع (التي ترسل الرابط حالياً)
        final sessionRes = await _dio.post("/Customer/Payment/create-session/$orderId");
        debugPrint("استجابة الجلسة: ${sessionRes.data}");
        
        final String? paymentUrl = sessionRes.data['url'];

        if (paymentUrl != null) {
          debugPrint("جاري فتح رابط الدفع: $paymentUrl");

          // 3. فتح الرابط في المتصفح الخارجي
          final Uri url = Uri.parse(paymentUrl);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
            // نرجع 'redirected' لكي لا تقوم السلة بمسح نفسها فوراً
            return 'redirected';
          } else {
            throw 'تعذر فتح رابط الدفع $paymentUrl';
          }
        }
      } else {
        debugPrint("تحذير: لم يتم استلام orderId من السيرفر");
      }
      return 'error';
    } catch (e) {
      debugPrint("خطأ في عملية الدفع: $e");
      return 'error';
    }
  }
}
