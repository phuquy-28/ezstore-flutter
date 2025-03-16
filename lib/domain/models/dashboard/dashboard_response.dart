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

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      totalUsers: json['totalUsers'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: json['totalRevenue'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'totalProducts': totalProducts,
    };
  }
}
