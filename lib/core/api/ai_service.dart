import 'dart:convert';
import 'package:dio/dio.dart';
import 'dio_client.dart';

class AiService {
  final Dio _dio = DioClient.instance;

  Future<String> askAi(String text) async {
    if (text.trim().isEmpty) {
      throw Exception("لا يمكن إرسال رسالة فارغة");
    }

    try {
      final response = await _dio.post(
        "/Customer/AI/ask",
        data: jsonEncode({"message": text.trim()}),
        options: Options(
          contentType: 'application/json',
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      print("✅ AI Success: ${response.data}");

      if (response.data is Map) {
        final data = response.data as Map;

        dynamic innerRaw = data['response'];
        Map? inner;

        if (innerRaw is String) {
          try {
            inner = jsonDecode(innerRaw) as Map;
          } catch (_) {
            return innerRaw;
          }
        } else if (innerRaw is Map) {
          inner = innerRaw;
        }

        if (inner != null) {
          if (inner['error'] != null) {
            final errMsg = inner['error']['message']?.toString() ?? "خطأ من الـ AI";
            print("❌ AI Inner Error: $errMsg");
            throw Exception(errMsg);
          }

          return (inner['answer'] ??
              inner['response'] ??
              inner['text'] ??
              inner['message'] ??
              inner['content'] ??
              "لا يوجد رد مقروء").toString();
        }

        return (data['answer'] ??
            data['message'] ??
            data['text'] ??
            "لا يوجد رد مقروء").toString();
      }

      if (response.data is String) return response.data;
      return response.data.toString();

    } on DioException catch (e) {
      print("❌ AI Error Details:");
      print("Status Code: ${e.response?.statusCode}");
      print("Response Data: ${e.response?.data}");

      final statusCode = e.response?.statusCode;
      final data = e.response?.data;

      String errorMsg = "خطأ $statusCode";
      if (data is Map) {
        errorMsg = data['errors']?.toString() ??
            data['message']?.toString() ??
            data['title']?.toString() ??
            errorMsg;
      } else if (data != null) {
        errorMsg = data.toString();
      }

      throw Exception(errorMsg);
    } catch (e) {
      throw Exception("حدث خطأ غير متوقع: $e");
    }
  }
}