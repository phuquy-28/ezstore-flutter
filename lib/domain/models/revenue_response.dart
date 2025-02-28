import 'package:json_annotation/json_annotation.dart';

part 'revenue_response.g.dart';

@JsonSerializable()
class RevenueResponse {
  final List<RevenueByMonth> revenueByMonth;

  RevenueResponse({required this.revenueByMonth});

  factory RevenueResponse.fromJson(Map<String, dynamic> json) =>
      _$RevenueResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RevenueResponseToJson(this);
}

@JsonSerializable()
class RevenueByMonth {
  final int month;
  final int revenue;

  RevenueByMonth({required this.month, required this.revenue});

  factory RevenueByMonth.fromJson(Map<String, dynamic> json) =>
      _$RevenueByMonthFromJson(json);

  Map<String, dynamic> toJson() => _$RevenueByMonthToJson(this);
}
