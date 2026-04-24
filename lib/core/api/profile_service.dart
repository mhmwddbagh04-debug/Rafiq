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
      // بدلاً من رمي خطأ يكسر التطبيق، سنقوم بطباعة الخطأ وإرجاع استثناء يمكن للواجهة التعامل معه
      print("❌ [Profile Error]: ${e.message}");
      rethrow; 
    } catch (e) {
      print("❌ [Profile Unexpected Error]: $e");
      rethrow;
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    try {
      final response = await _dio.put("/Identity/Profile/update", data: {
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
      });
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("❌ [Update Profile Error]: ${e.message}");
      return false;
    }
  }
}
