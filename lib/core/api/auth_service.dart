import 'package:dio/dio.dart';
import 'dio_client.dart';
import 'token_manager.dart';

class AuthService {
  final Dio _dio = DioClient.instance;

  // تسجيل الدخول
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
  Future<Map<String, dynamic>> refreshToken(
    Map<String, dynamic> responseData,
  ) async {
    final response = await _dio.post(
      "/Identity/Account/refresh",
      data: {
        "accessToken": responseData['accessToken'],
        "refreshToken": responseData['refreshToken'],
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

  // تسجيل الخروج وإبطال التوكن
  Future<void> logout() async {
    try {
      final accessToken = await TokenManager.getToken();
      final refreshToken = await TokenManager.getRefreshToken();

      if (accessToken != null && refreshToken != null) {
        await _dio.post(
          "/Identity/Account/revoke",
          data: {"accessToken": accessToken, "refreshToken": refreshToken},
        );
      }
    } catch (e) {
      print("Error during logout/revoke: $e");
    } finally {
      await TokenManager.clearTokens();
    }
  }

  // طلب رمز جديد
  Future<void> forgetPassword(String email) async {
    await _dio.post("/Identity/Account/ForgetPassword", data: {"email": email});
  }

  // التحقق من الرمز وإرجاع البيانات
  Future<Map<String, dynamic>> validateOTP(String email, String otp) async {
    final response = await _dio.post(
      "/Identity/Account/ValidateOTP",
      data: {"email": email, "otp": otp},
    );
    return response.data;
  }

  // إعادة تعيين كلمة المرور باستخدام المفاتيح المطلوبة
  Future<void> resetPassword({
    required String applicationUserId,
    required String password,
    required String confirmPassword,
  }) async {
    await _dio.post(
      "/Identity/Account/NewPassword",
      data: {
        "password": password,
        "confirmPassword": confirmPassword,
        "applicationUserId": applicationUserId,
      },
    );
  }
}
