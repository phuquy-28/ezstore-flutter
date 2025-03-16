class RevenueResponse {
  final List<RevenueByMonth> revenueByMonth;

  RevenueResponse({required this.revenueByMonth});

  factory RevenueResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> revenueList = json['revenueByMonth'] ?? [];
    List<RevenueByMonth> revenueByMonthList = revenueList
        .map((item) => RevenueByMonth.fromJson(item))
        .toList();
    
    return RevenueResponse(revenueByMonth: revenueByMonthList);
  }

  Map<String, dynamic> toJson() {
    return {
      'revenueByMonth': revenueByMonth.map((item) => item.toJson()).toList(),
    };
  }
}

class RevenueByMonth {
  final int month;
  final int revenue;

  RevenueByMonth({required this.month, required this.revenue});

  factory RevenueByMonth.fromJson(Map<String, dynamic> json) {
    return RevenueByMonth(
      month: (json['month'] as num).toInt(),
      revenue: (json['revenue'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'revenue': revenue,
    };
  }
}
