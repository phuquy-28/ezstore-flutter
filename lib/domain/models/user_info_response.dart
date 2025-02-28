import 'package:json_annotation/json_annotation.dart';

part 'user_info_response.g.dart';

@JsonSerializable()
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

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$UserInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoResponseToJson(this);
}
