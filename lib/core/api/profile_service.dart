import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import 'dio_client.dart';

class ProfileService {
  final Dio _dio = DioClient.instance;

  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get("/Identity/Profile/me");
      if (response.data == null) throw Exception("Empty response");
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("❌ [Profile Get Error]: ${e.response?.statusCode} - ${e.response?.data}");
      rethrow; 
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? address,
    String? gender,
  }) async {
    try {
      final data = {
        "firstName": firstName,
        "lastName": lastName,
        "phoneNumber": phoneNumber,
        "address": address,
        "gender": gender,
      };

      debugPrint("🚀 [API Request] PUT /Identity/Profile/me");
      debugPrint("Payload: $data");

      final response = await _dio.put("/Identity/Profile/me", data: data);

      debugPrint("✅ [API Success] Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");

    } on DioException catch (e) {
      debugPrint("❌ [API DioError] Status: ${e.response?.statusCode}");
      debugPrint("Data: ${e.response?.data}");
      
      String? errorMessage = "فشل تحديث البيانات";
      if (e.response?.data != null) {
        if (e.response?.data is Map) {
          errorMessage = e.response?.data['message'] ?? 
                         e.response?.data['title'] ?? 
                         e.response?.data.toString();
        } else {
          errorMessage = e.response?.data.toString();
        }
      } else {
        errorMessage = e.message ?? "مشكلة في الاتصال بالسيرفر";
      }
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint("❌ [API Unexpected Error]: $e");
      throw Exception("حدث خطأ غير متوقع");
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final data = {
        "currentPassword": currentPassword,
        "newPassword": newPassword,
      };

      debugPrint("🚀 [API Request] POST /Identity/Profile/changePassword");
      final response = await _dio.post("/Identity/Profile/changePassword", data: data);

      debugPrint("✅ [API Success] Status: ${response.statusCode}");
    } on DioException catch (e) {
      debugPrint("❌ [API DioError] Status: ${e.response?.statusCode}");
      String? errorMessage = "فشل تغيير كلمة المرور";
      if (e.response?.data != null && e.response?.data is Map) {
        errorMessage = e.response?.data['message'] ?? e.response?.data['title'] ?? errorMessage;
      }
      throw Exception(errorMessage);
    } catch (e) {
      rethrow;
    }
  }
}
