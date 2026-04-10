import 'package:dio/dio.dart';
import '../../data/models/user_model.dart';
import 'dio_client.dart';

class ProfileService {
  final Dio _dio = DioClient.instance;

  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get("/Identity/Profile/me");
      // تحويل الـ JSON القادم من السيرفر إلى UserModel
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      String errorMessage = "Failed to load profile";
      if (e.response?.data is Map) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      throw Exception(errorMessage);
    }
  }
}
