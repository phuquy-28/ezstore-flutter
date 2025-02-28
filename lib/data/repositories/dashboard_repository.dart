import 'package:ezstore_flutter/data/services/dashboard_service.dart';
import 'package:ezstore_flutter/domain/models/dashboard_response.dart';
import 'package:ezstore_flutter/domain/models/revenue_response.dart';

class DashboardRepository {
  final DashboardService _dashboardService;

  DashboardRepository(this._dashboardService);

  Future<DashboardResponse> getDashboardMetric() async {
    return await _dashboardService.getDashboard();
  }

  Future<RevenueResponse> getRevenueByMonth(int year) async {
    return await _dashboardService.getRevenueByMonth(year);
  }
}
