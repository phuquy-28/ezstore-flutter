import 'package:json_annotation/json_annotation.dart';

part 'dashboard_response.g.dart';

@JsonSerializable()
class DashboardResponse {
  final num totalUsers;
  final num totalOrders;
  final num totalRevenue;
  final num totalProducts;

  DashboardResponse({
    required this.totalUsers,
    required this.totalOrders,
    required this.totalRevenue,
    required this.totalProducts,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) =>
      _$DashboardResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardResponseToJson(this);
}
