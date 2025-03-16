class UserInfoResponse {
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final int cartItemsCount;

  UserInfoResponse({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.cartItemsCount,
  });

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) {
    return UserInfoResponse(
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: json['role'],
      cartItemsCount: (json['cartItemsCount'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'cartItemsCount': cartItemsCount,
    };
  }

  String get fullName => '$firstName $lastName';
}
