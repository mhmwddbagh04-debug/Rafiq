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

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
            
            final remaining = TokenManager.getTokenRemainingTime(token);
            print("⏳ [Token Status] Remaining: $remaining");
          }
          print("📡 [API Request] ${options.method} ${options.path}");
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            
            if (_isRefreshing) {
              print("⏳ [Auth Wait] Waiting for ongoing refresh: ${e.requestOptions.path}");
              final success = await _refreshCompleter?.future;
              if (success == true) {
                return _retryOriginalRequest(e.requestOptions, handler);
              } else {
                return handler.next(e);
              }
            }

            _isRefreshing = true;
            _refreshCompleter = Completer<bool>();
            print("⚠️ [Auth] 401 Detected. Starting Refresh Process...");

            try {
              final oldToken = await TokenManager.getToken();
              final oldRefreshToken = await TokenManager.getRefreshToken();

              if (oldToken != null && oldRefreshToken != null) {
                final refreshDio = Dio();
                final response = await refreshDio.post(
                  "$_baseUrl/Identity/Account/refresh",
                  data: {
                    "accessToken": oldToken,
                    "refreshToken": oldRefreshToken,
                  },
                );

                if (response.statusCode == 200) {
                  final newAccessToken = response.data['accessToken'];
                  final newRefreshToken = response.data['refreshToken'];

                  await TokenManager.saveToken(newAccessToken);
                  await TokenManager.saveRefreshToken(newRefreshToken);

                  print("✅ [Auth] Refresh Successful. Retrying all requests...");
                  
                  _isRefreshing = false;
                  _refreshCompleter?.complete(true);
                  _refreshCompleter = null;

                  return _retryOriginalRequest(e.requestOptions, handler);
                }
              }
              
              _isRefreshing = false;
              _refreshCompleter?.complete(false);
              _refreshCompleter = null;
              return handler.next(e);

            } on DioException catch (refreshErr) {
              _isRefreshing = false;
              _refreshCompleter?.complete(false);
              _refreshCompleter = null;
              print("❌ [Auth Refresh Error]: ${refreshErr.response?.statusCode} - ${refreshErr.response?.data}");
              
              if (refreshErr.response?.statusCode == 400) {
                print("🚨 [Auth] Refresh Token Invalid/Mismatch. User must re-login.");
                await TokenManager.clearTokens();
                if (navigatorKey.currentState != null) {
                  navigatorKey.currentState!.pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
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

  static Future<void> _retryOriginalRequest(RequestOptions requestOptions, ErrorInterceptorHandler handler) async {
    print("🔁 [Retry] Retrying original request: ${requestOptions.path}");
    final token = await TokenManager.getToken();
    
    try {
      final response = await _dio.request(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: Options(
          method: requestOptions.method,
          headers: {...requestOptions.headers, "Authorization": "Bearer $token"},
        ),
      );
      return handler.resolve(response);
    } catch (err) {
      if (err is DioException) return handler.next(err);
      return handler.reject(DioException(requestOptions: requestOptions, error: err));
    }
  }

  static Dio get instance => _dio;
}
