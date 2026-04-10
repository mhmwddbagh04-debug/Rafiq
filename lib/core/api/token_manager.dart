import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// جلب تاريخ انتهاء التوكن
  static DateTime? getTokenExpiryDate(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final payloadMap = json.decode(payload);

      final exp = payloadMap['exp'];
      if (exp == null) return null;

      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    } catch (e) {
      return null;
    }
  }

  /// جلب الوقت المتبقي للتوكن (بالدقائق والثواني)
  static String getTokenRemainingTime(String token) {
    final expiryDate = getTokenExpiryDate(token);
    if (expiryDate == null) return "Unknown";
    
    final difference = expiryDate.difference(DateTime.now());
    if (difference.isNegative) return "Expired";

    return "${difference.inMinutes}m ${difference.inSeconds % 60}s";
  }

  static bool isTokenExpired(String token) {
    final expiryDate = getTokenExpiryDate(token);
    if (expiryDate == null) return true;
    return DateTime.now().isAfter(expiryDate);
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}
