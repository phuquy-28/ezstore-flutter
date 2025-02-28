import 'package:flutter/material.dart';
import '../../../data/repositories/dashboard_repository.dart';
import '../../../domain/models/dashboard_response.dart';
import '../../../domain/models/revenue_response.dart';

class DashboardViewModel with ChangeNotifier {
  final DashboardRepository _dashboardRepository;
  DashboardResponse? _dashboardData;
  RevenueResponse? _revenueData;

  DashboardViewModel(this._dashboardRepository);

  DashboardResponse? get dashboardData => _dashboardData;
  RevenueResponse? get revenueData => _revenueData;

  Future<void> fetchDashboardData() async {
    _dashboardData = await _dashboardRepository.getDashboardMetric();
    notifyListeners();
  }

  Future<void> fetchRevenueData(int year) async {
    _revenueData = await _dashboardRepository.getRevenueByMonth(year);
    print(revenueData?.toJson()); // In ra dữ liệu doanh thu dưới dạng chuỗi
    notifyListeners();
  }
}
