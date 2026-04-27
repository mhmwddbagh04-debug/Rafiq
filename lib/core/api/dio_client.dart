import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../app_router.dart';
import 'token_manager.dart';

class DioClient {
  static const String _baseUrl = "https://rafiq1.runasp.net/api";
  static final Dio _dio = _createDio();
  static bool _isRefreshing = false;
  static Completer<bool>? _refreshCompleter;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

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
            options.headers["Authorization"] = "Bearer ${token.trim()}";
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final String? failedToken = e
                .requestOptions
                .headers["Authorization"]
                ?.toString()
                .replaceAll("Bearer ", "")
                .trim();

            // قراءة أحدث توكن موجود في التخزين الآن
            final String? currentToken = (await TokenManager.getToken())
                ?.trim();

            // 1. فحص حيوي: إذا كان التوكن تغير بالفعل، لا تحاول التجديد، فقط أعد المحاولة بالجديد
            if (currentToken != null &&
                failedToken != null &&
                currentToken != failedToken) {
              print(
                "ℹ️ [Auth] Token already refreshed by another request. Retrying original request.",
              );
              return _retryOriginalRequest(e.requestOptions, handler);
            }

            // 2. إذا كان هناك طلب تجديد شغال حالياً، انتظر نتيجته
            if (_isRefreshing) {
              print(
                "⏳ [Auth Wait] Waiting for ongoing refresh: ${e.requestOptions.path}",
              );
              final success = await _refreshCompleter?.future;
              if (success == true) {
                return _retryOriginalRequest(e.requestOptions, handler);
              } else {
                return handler.next(e);
              }
            }

            // 3. قفل الأمان لمنع تداخل الطلبات
            _isRefreshing = true;
            _refreshCompleter = Completer<bool>();

            try {
              print("⚠️ [Auth] Starting REFRESH process...");

              final storageToken = (await TokenManager.getToken())?.trim();
              final storageRefreshToken = (await TokenManager.getRefreshToken())
                  ?.trim();

              if (storageToken == null || storageRefreshToken == null) {
                throw Exception("No tokens found in storage");
              }

              // طباعة المعلومات للتحقق (Debug)
              print("🔍 [DEBUG] Sending to Server:");
              print(
                "👉 Token End: ...${storageToken.substring(storageToken.length - 10)}",
              );
              print("👉 Refresh: $storageRefreshToken");

              final refreshDio = Dio();
              final response = await refreshDio.post(
                "$_baseUrl/Identity/Account/refresh",
                options: Options(
                  headers: {
                    "Authorization": "Bearer $storageToken",
                    // إرسال التوكن القديم في الهيدر أيضاً للأمان
                    "Content-Type": "application/json",
                  },
                ),
                data: {
                  "accessToken": storageToken,
                  "refreshToken": storageRefreshToken,
                },
              );

              print("🔍 [DEBUG] Refresh Response: ${response.data}");

              if (response.statusCode == 200) {
                final newAccessToken = response.data['accessToken']
                    ?.toString()
                    .trim();
                final newRefreshToken = response.data['refreshToken']
                    ?.toString()
                    .trim();

                if (newAccessToken != null && newRefreshToken != null) {
                  await TokenManager.saveToken(newAccessToken);
                  await TokenManager.saveRefreshToken(newRefreshToken);

                  print("✅ [Auth] Refresh SUCCESSFUL.");

                  _isRefreshing = false;
                  _refreshCompleter?.complete(true);
                  _refreshCompleter = null;

                  return _retryOriginalRequest(e.requestOptions, handler);
                }
              }
              throw Exception("Invalid response structure");
            } on DioException catch (refreshErr) {
              print(
                "❌ [Auth Refresh Error]: ${refreshErr.response?.statusCode} - ${refreshErr.response?.data}",
              );

              _isRefreshing = false;
              _refreshCompleter?.complete(false);
              _refreshCompleter = null;

              // إذا رفض السيرفر التوكن نهائياً، نخرج المستخدم
              if (refreshErr.response?.statusCode == 400 ||
                  refreshErr.response?.statusCode == 401) {
                print("🚨 [Auth] Refresh Token Rejected. Forced Logout.");
                await TokenManager.clearTokens();
                if (navigatorKey.currentState != null) {
                  navigatorKey.currentState!.pushNamedAndRemoveUntil(
                    AppRouter.login,
                    (route) => false,
                  );
                }
              }
              return handler.next(e);
            } catch (err) {
              _isRefreshing = false;
              _refreshCompleter?.complete(false);
              _refreshCompleter = null;
              print("❌ [Auth Unexpected Error]: $err");
              return handler.next(e);
            }
          }
          return handler.next(e);
        },
      ),
    );

    return dio;
  }

  static Future<void> _retryOriginalRequest(
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    final token = await TokenManager.getToken();
    print("🔁 [Retry] Retrying: ${requestOptions.path}");

    try {
      final response = await _dio.request(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: Options(
          method: requestOptions.method,
          headers: {
            ...requestOptions.headers,
            "Authorization": "Bearer ${token?.trim()}",
          },
        ),
      );
      return handler.resolve(response);
    } catch (err) {
      if (err is DioException) return handler.next(err);
      return handler.reject(
        DioException(requestOptions: requestOptions, error: err),
      );
    }
  }

  static Dio get instance => _dio;
}
