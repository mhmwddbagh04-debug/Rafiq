import 'package:dio/dio.dart';
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
    } catch (e) {
      throw Exception("An unexpected error occurred while loading home data");
    }
  }

  Future<PaginatedProductResponse> getAllProducts({int page = 1, int pageSize = 8, String? search}) async {
    try {
      final Map<String, dynamic> params = {
        'page': page,
        'pageSize': pageSize,
      };
      
      // جربنا 'name' ولم يعمل، سنحول إلى 'search' أو 'SearchQuery'
      if (search != null && search.isNotEmpty) {
        params['search'] = search; 
      }

      final response = await _dio.get("/Customer/Products", queryParameters: params);
      return PaginatedProductResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception("Failed to load products");
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get("/Customer/Store/AllCategories");
      final List data = response.data['data'];
      return data.map((c) => Category.fromJson(c)).toList();
    } on DioException catch (e) {
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
    } on DioException catch (e) {
      throw Exception("Failed to load category products");
    }
  }
}
