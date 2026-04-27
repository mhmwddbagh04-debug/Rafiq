import 'package:dio/dio.dart';
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
      print("❌ [Profile Get Error]: ${e.response?.statusCode} - ${e.response?.data}");
      rethrow; 
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    try {
      final data = {
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
      };

      print("🚀 [API Request] PUT /Identity/Profile/me");
      print("Payload: $data");

      // تغيير الرابط من /update إلى /me لأن الـ GET يعمل على /me
      final response = await _dio.put("/Identity/Profile/me", data: data);

      print("✅ [API Success] Status: ${response.statusCode}");
      print("Response Body: ${response.data}");

    } on DioException catch (e) {
      print("❌ [API DioError] Status: ${e.response?.statusCode}");
      print("Data: ${e.response?.data}");
      
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
      print("❌ [API Unexpected Error]: $e");
      throw Exception("حدث خطأ غير متوقع");
    }
  }
}
