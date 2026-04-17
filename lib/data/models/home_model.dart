class HomeResponse {
  final List<ImportantQuestion> importantQuestions;
  final List<Advertisement> advertisements;
  final List<DidYouKnow> didYouKnows;
  final List<Product> topSellingProducts;
  final List<Product> newArrivals; // الحقل الجديد

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
      newArrivals: (json['newArrivals'] as List?) // جلب المنتجات الجديدة
              ?.map((i) => Product.fromJson(i))
              .toList() ??
          [],
    );
  }
}

class ImportantQuestion {
  final int id;
  final String question;
  final String answer;

  ImportantQuestion({required this.id, required this.question, required this.answer});

  factory ImportantQuestion.fromJson(Map<String, dynamic> json) {
    return ImportantQuestion(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
    );
  }
}

class Advertisement {
  final int id;
  final String imageUrl;

  Advertisement({required this.id, required this.imageUrl});

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['id'],
      imageUrl: json['imageUrl'],
    );
  }
}

class DidYouKnow {
  final int id;
  final String imageUrl;

  DidYouKnow({required this.id, required this.imageUrl});

  factory DidYouKnow.fromJson(Map<String, dynamic> json) {
    return DidYouKnow(
      id: json['id'],
      imageUrl: json['imageUrl'],
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
    return Product(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] ?? json['img'] ?? "",
      totalSold: json['totalSold'] ?? 0,
      description: json['description'],
    );
  }
}
