class HomeResponse {
  final List<ImportantQuestion> importantQuestions;
  final List<Advertisement> advertisements;
  final List<DidYouKnow> didYouKnows;
  final List<Product> topSellingProducts;
  final List<Product> newArrivals;

  HomeResponse({
    required this.importantQuestions,
    required this.advertisements,
    required this.didYouKnows,
    required this.topSellingProducts,
    required this.newArrivals,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      importantQuestions: (json['importantQuestions'] as List?)
              ?.map((i) => ImportantQuestion.fromJson(i))
              .toList() ??
          [],
      advertisements: (json['advertisements'] as List?)
              ?.map((i) => Advertisement.fromJson(i))
              .toList() ??
          [],
      didYouKnows: (json['didYouKnows'] as List?)
              ?.map((i) => DidYouKnow.fromJson(i))
              .toList() ??
          [],
      topSellingProducts: (json['topSellingProducts'] as List?)
              ?.map((i) => Product.fromJson(i))
              .toList() ??
          [],
      newArrivals: (json['newArrivals'] as List?)
              ?.map((i) => Product.fromJson(i))
              .toList() ??
          [],
    );
  }
}

class PaginatedProductResponse {
  final List<Product> products;
  final int totalPages;
  final int currentPage;

  PaginatedProductResponse({
    required this.products,
    required this.totalPages,
    required this.currentPage,
  });

  factory PaginatedProductResponse.fromJson(Map<String, dynamic> json) {
    final List? dataList = json['data'] ?? json['Data'];
    
    return PaginatedProductResponse(
      products: dataList?.map((p) => Product.fromJson(p)).toList() ?? [],
      totalPages: json['totalPages'] ?? 1,
      currentPage: json['currentPage'] ?? 1,
    );
  }
}

class Product {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final int totalSold;
  final String? description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.totalSold = 0,
    this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String extractImage(Map<String, dynamic> map) {
      final keys = ['img', 'Img', 'imageUrl', 'ImageUrl', 'productImg', 'image'];
      String rawPath = "";
      for (var key in keys) {
        if (map[key] != null && map[key].toString().isNotEmpty && map[key].toString() != "null") {
          rawPath = map[key].toString();
          break;
        }
      }
      
      if (rawPath.isEmpty) return "";
      if (rawPath.startsWith('http')) return rawPath;
      
      if (rawPath.startsWith('/')) {
        return "https://rafiq1.runasp.net/Images$rawPath";
      }
      return "https://rafiq1.runasp.net/Images/$rawPath";
    }

    return Product(
      id: json['id'] ?? json['Id'] ?? 0,
      name: json['name'] ?? json['Name'] ?? "Unknown",
      price: _toDouble(json['price'] ?? json['Price'] ?? json['productPrice']),
      imageUrl: extractImage(json),
      totalSold: json['totalSold'] ?? 0,
      description: json['description'] ?? json['Description'],
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'totalSold': totalSold,
      'description': description,
    };
  }
}

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? json['Id'] ?? 0,
      name: json['name'] ?? json['Name'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class ImportantQuestion {
  final int id;
  final String question;
  final String answer;

  ImportantQuestion({required this.id, required this.question, required this.answer});

  factory ImportantQuestion.fromJson(Map<String, dynamic> json) {
    return ImportantQuestion(
      id: json['id'] ?? json['Id'] ?? 0, 
      question: json['question'] ?? json['Question'] ?? "", 
      answer: json['answer'] ?? json['Answer'] ?? ""
    );
  }
}

class Advertisement {
  final int id;
  final String imageUrl;

  Advertisement({required this.id, required this.imageUrl});

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    String extractImage(Map<String, dynamic> map) {
      final keys = ['img', 'Img', 'imageUrl', 'ImageUrl', 'image', 'advImg'];
      String rawPath = "";
      for (var key in keys) {
        if (map[key] != null && map[key].toString().isNotEmpty && map[key].toString() != "null") {
          rawPath = map[key].toString();
          break;
        }
      }
      
      if (rawPath.isEmpty) return "";
      if (rawPath.startsWith('http')) return rawPath;
      
      // جربنا Advertisement_images ولم يعمل، سنستخدم Images مثل المنتجات
      if (rawPath.startsWith('/')) {
        return "https://rafiq1.runasp.net/Images$rawPath";
      }
      return "https://rafiq1.runasp.net/Images/$rawPath";
    }

    return Advertisement(
      id: json['id'] ?? json['Id'] ?? 0,
      imageUrl: extractImage(json),
    );
  }
}

class DidYouKnow {
  final int id;
  final String imageUrl;

  DidYouKnow({required this.id, required this.imageUrl});

  factory DidYouKnow.fromJson(Map<String, dynamic> json) {
    String extractImage(Map<String, dynamic> map) {
      final keys = ['img', 'Img', 'imageUrl', 'ImageUrl', 'image'];
      String rawPath = "";
      for (var key in keys) {
        if (map[key] != null && map[key].toString().isNotEmpty && map[key].toString() != "null") {
          rawPath = map[key].toString();
          break;
        }
      }
      
      if (rawPath.isEmpty) return "";
      if (rawPath.startsWith('http')) return rawPath;
      
      if (rawPath.startsWith('/')) {
        return "https://rafiq1.runasp.net/Images$rawPath";
      }
      return "https://rafiq1.runasp.net/Images/$rawPath";
    }

    return DidYouKnow(
      id: json['id'] ?? json['Id'] ?? 0,
      imageUrl: extractImage(json),
    );
  }
}
