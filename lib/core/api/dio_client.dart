import 'package:dio/dio.dart';
import 'token_manager.dart';

class DioClient {
  static const String _baseUrl = "https://rafiq1.runasp.net/api";
  static final Dio _dio = _createDio();
  static bool _isRefreshing = false;

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenManager.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";

            // طباعة الوقت المتبقي للتوكن للمراقبة
            final remaining = TokenManager.getTokenRemainingTime(token);
            print("⏳ [Token Status] Remaining: $remaining");
          }
          print("📡 [API Request] ${options.method} ${options.path}");
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // إذا انتهت صلاحية التوكن (401)
          if (e.response?.statusCode == 401 && !_isRefreshing) {
            _isRefreshing = true;
            print(
              "⚠️ [401 Error] Unauthorized! Attempting to refresh token...",
            );

            try {
              final oldToken = await TokenManager.getToken();
              final oldRefreshToken = await TokenManager.getRefreshToken();

              if (oldToken != null) {
                final expiry = TokenManager.getTokenExpiryDate(oldToken);
                print("📅 [Expired Token Info] Expiry Date: $expiry");
              }

              if (oldToken != null && oldRefreshToken != null) {
                // نستخدم Dio منفصل لعملية الريفريش لتجنب التداخل
                final refreshDio = Dio(
                  BaseOptions(
                    baseUrl: _baseUrl,
                    headers: {'Content-Type': 'application/json'},
                  ),
                );

                final response = await refreshDio.post(
                  "/Identity/Account/refresh",
                  data: {
                    "accessToken": oldToken,
                    "refreshToken": oldRefreshToken,
                  },
                );

                if (response.statusCode == 200) {
                  final newAccessToken = response.data['accessToken'];
                  final newRefreshToken = response.data['refreshToken'];

                  final newExpiry = TokenManager.getTokenExpiryDate(
                    newAccessToken,
                  );
                  print("✅ [Refresh Success] New Expiry: $newExpiry");

                  // حفظ التوكنات الجديدة
                  await TokenManager.saveToken(newAccessToken);
                  await TokenManager.saveRefreshToken(newRefreshToken);

                  // تحديث هيدر الطلب الحالي بالتوكن الجديد
                  e.requestOptions.headers["Authorization"] =
                      "Bearer $newAccessToken";

                  // إعادة إرسال الطلب الأصلي
                  final retryResponse = await dio.request(
                    e.requestOptions.path,
                    options: Options(
                      method: e.requestOptions.method,
                      headers: e.requestOptions.headers,
                    ),
                    data: e.requestOptions.data,
                    queryParameters: e.requestOptions.queryParameters,
                  );

                  return handler.resolve(retryResponse);
                }
              }
            } catch (refreshError) {
              print("❌ [Refresh Error] Critical failure: $refreshError");
              await TokenManager.clearTokens();
            } finally {
              _isRefreshing = false;
            }
          }
          return handler.next(e);
        },
      ),
    );

    return dio;
  }

  static Dio get instance => _dio;
}
