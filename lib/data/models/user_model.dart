class UserModel {
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String? gender;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.address,
    this.gender,
  });

  // هذه الدالة تحول الـ JSON القادم من السيرفر إلى Object من نوع UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      gender: json['gender'],
    );
  }

  // دالة مساعدة للحصول على الاسم الكامل
  String get fullName => "$firstName $lastName".trim();
}
