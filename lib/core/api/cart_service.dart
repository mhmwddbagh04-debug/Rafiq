import 'package:dio/dio.dart';
import '../../data/models/cart_model.dart';
import 'dio_client.dart';

class CartService {
  final Dio _dio = DioClient.instance;

  // جلب محتويات السلة (GET)
  Future<CartResponse> getCart() async {
    try {
      final response = await _dio.get("/Customer/Cart");
      return CartResponse.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioError(e, "Failed to load cart");
      rethrow;
    }
  }

  // إضافة منتج للسلة (POST)
  Future<void> addToCart(int productId, int quantity) async {
    try {
      await _dio.post("/Customer/Cart", data: {
        "productId": productId,
        "quantity": quantity,
      });
    } on DioException catch (e) {
      _handleDioError(e, "Failed to add to cart");
    }
  }

  // تعديل الكمية (PUT)
  Future<void> updateCartItem(int cartItemId, int quantity) async {
    try {
      await _dio.put("/Customer/Cart/$cartItemId", data: {
        "quantity": quantity,
      });
    } on DioException catch (e) {
      _handleDioError(e, "Failed to update item");
    }
  }

  // حذف عنصر من السلة (DELETE)
  Future<void> deleteCartItem(int cartItemId) async {
    try {
      await _dio.delete("/Customer/Cart/$cartItemId");
    } on DioException catch (e) {
      _handleDioError(e, "Failed to delete item");
    }
  }

  // وظيفة مساعدة لمعالجة الأخطاء بشكل آمن
  void _handleDioError(DioException e, String defaultMessage) {
    String errorMessage = defaultMessage;
    
    // التحقق مما إذا كان الرد عبارة عن Map (JSON) أم نص عادي
    if (e.response?.data != null) {
      if (e.response?.data is Map) {
        errorMessage = e.response?.data['message'] ?? defaultMessage;
      } else if (e.response?.data is String) {
        errorMessage = e.response?.data;
      }
    }
    
    throw Exception(errorMessage);
  }
}
