import 'package:dio/dio.dart';
import 'dio_client.dart';
import 'token_manager.dart';

class AuthService {
  final Dio _dio = DioClient.instance;

  // تسجيل الدخول باستخدام الرابط الجديد
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      "/Identity/Account/Login",
      data: {"email": email, "password": password},
    );

    final data = response.data;
    print(response.data);
    if (data['accessToken'] != null) {
      await TokenManager.saveToken(data['accessToken']);
    }
    if (data['refreshToken'] != null) {
      await TokenManager.saveRefreshToken(data['refreshToken']);
    }
    return data;
  }

  // تجديد التوكن باستخدام البيانات القادمة من الاستجابة (response.data)
  Future<Map<String, dynamic>> refreshToken(Map<String, dynamic> responseData) async {
    final response = await _dio.post(
      "/Identity/Account/refresh",
      data: {
        "accessToken": responseData['accessToken'],
        "refreshToken": responseData['refreshToken']
      },
    );
    print(response.data);
    if (response.statusCode == 200) {
      final data = response.data;
      if (data['accessToken'] != null) {
        await TokenManager.saveToken(data['accessToken']);
      }
      if (data['refreshToken'] != null) {
        await TokenManager.saveRefreshToken(data['refreshToken']);
      }
      return data;

    }
    throw Exception("Failed to refresh token");
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      "/Identity/Account/Register",
      data: {
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "password": password,
        "confirmPassword": password,
        "userName": email,
      },
    );
    final data = response.data;
    if (data['accessToken'] != null) {
      await TokenManager.saveToken(data['accessToken']);
    }
    if (data['refreshToken'] != null) {
      await TokenManager.saveRefreshToken(data['refreshToken']);
    }
    return data;
  }
}
