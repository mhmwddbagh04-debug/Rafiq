import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' hide Category;
import '../../data/models/home_model.dart';
import 'dio_client.dart';

class HomeService {
  final Dio _dio = DioClient.instance;

  Future<HomeResponse> getHomeData() async {
    try {
      final response = await _dio.get("/Customer/Home");
      return HomeResponse.fromJson(response.data);
    } on DioException catch (e) {
      String errorMessage = "Failed to load home data";
      if (e.response?.data is Map) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      throw Exception(errorMessage);
    } catch (_) {
      throw Exception("An unexpected error occurred while loading home data");
    }
  }

  Future<PaginatedProductResponse> getAllProducts({int page = 1, int pageSize = 8, String? search}) async {
    try {
      final Map<String, dynamic> params = {
        'page': page,
        'pageSize': pageSize,
      };
      
      if (search != null && search.isNotEmpty) {
        params['search'] = search; 
      }

      final response = await _dio.get("/Customer/Products", queryParameters: params);
      return PaginatedProductResponse.fromJson(response.data);
    } on DioException {
      throw Exception("Failed to load products");
    }
  }

  // البحث باستخدام اسم الدواء
  Future<List<Product>> searchProducts(String query) async {
    try {
      // 1. نحاول البحث عبر المسار العام مع بارامتر البحث
      final response = await getAllProducts(page: 1, pageSize: 100, search: query);
      
      // فلترة إضافية للتأكد من النتائج
      final List<Product> filteredResults = response.products.where((p) => 
        p.name.toLowerCase().contains(query.toLowerCase()) || 
        (p.description?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
        (p.activeIngredients?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();

      if (filteredResults.isNotEmpty) return filteredResults;

      // 2. إذا لم نجد نتائج، نحاول استخدام مسار البحث المخصص
      final searchResponse = await _dio.get("/Customer/Search/Search", queryParameters: {'search': query});
      dynamic rawData = searchResponse.data;
      List dataList = [];
      
      if (rawData is List) {
        dataList = rawData;
      } else if (rawData is Map) {
        dataList = rawData['data'] ?? rawData['Data'] ?? rawData['products'] ?? [];
      }
      
      return dataList.map((p) => Product.fromJson(p)).toList();
    } catch (e) {
      debugPrint("❌ Search Error: $e");
      return [];
    }
  }

  // البحث عن أدوية بديلة (نفس المادة الفعالة) باستخدام ID الدواء
  Future<List<Product>> getSimilarProducts(int productId) async {
    try {
      final response = await _dio.get("/Customer/Search/$productId/similar");
      
      dynamic rawData = response.data;
      List dataList = [];
      
      if (rawData is List) {
        dataList = rawData;
      } else if (rawData is Map) {
        dataList = rawData['data'] ?? rawData['Data'] ?? rawData['products'] ?? [];
      }
      
      return dataList.map((p) => Product.fromJson(p)).toList();
    } catch (e) {
      debugPrint("❌ Similar Products Error: $e");
      return [];
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get("/Customer/Store/AllCategories");
      final List data = response.data['data'] ?? response.data['Data'] ?? [];
      return data.map((c) => Category.fromJson(c)).toList();
    } on DioException {
      throw Exception("Failed to load categories");
    }
  }

  Future<PaginatedProductResponse> getProductsByCategory(int categoryId, {int page = 1, int pageSize = 8, String? search}) async {
    try {
      final Map<String, dynamic> params = {
        'page': page,
        'pageSize': pageSize,
      };
      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }

      final response = await _dio.get(
        "/Customer/Store/Category/$categoryId/Products",
        queryParameters: params,
      );
      return PaginatedProductResponse.fromJson(response.data);
    } on DioException {
      throw Exception("Failed to load category products");
    }
  }
}
