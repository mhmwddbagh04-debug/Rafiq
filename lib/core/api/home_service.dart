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
    }
  }

  // الوظيفة الجديدة لجلب كل المنتجات مع الوصف
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _dio.get("/Customer/Products");
      final List data = response.data['data'];
      return data.map((p) => Product.fromJson(p)).toList();
    } on DioException catch (e) {
      String errorMessage = "Failed to load products";
      if (e.response?.data is Map) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      throw Exception(errorMessage);
    }
  }
}
