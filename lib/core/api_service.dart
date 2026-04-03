import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // روابط الـ API الصحيحة
  static const String loginUrl = "https://rafiqec.runasp.net/api/Identity/Account/Login";
  static const String registerUrl = "https://rafiqec.runasp.net/api/Identity/Account/Register";

  // حفظ التوكن
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // جلب التوكن
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // تسجيل الدخول
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse(loginUrl);
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data['token'] != null) {
        await saveToken(data['token']);
      }
      return data;
    } else {
      throw Exception(data['message'] ?? "Login failed");
    }
  }

  // إنشاء حساب جديد
  static Future<Map<String, dynamic>> register(
      String firstName, String lastName, String email, String password) async {
    final url = Uri.parse(registerUrl);
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "password": password,
        "confirmPassword": password,
        "userName": email
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? "Register failed");
    }
  }
}
