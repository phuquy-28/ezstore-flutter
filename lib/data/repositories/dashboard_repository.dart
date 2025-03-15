import 'package:ezstore_flutter/data/services/dashboard_service.dart';
import 'package:ezstore_flutter/domain/models/dashboard_response.dart';
import 'package:ezstore_flutter/domain/models/revenue_response.dart';

class DashboardRepository {
  final DashboardService _dashboardService;

  DashboardRepository(this._dashboardService);

  Future<DashboardResponse?> getDashboardMetric() async {
    final response = await _dashboardService.getDashboard();
    
    if (response.statusCode == 200 && response.data != null) {
      return response.data;
    }
    
    return null;
  }

  Future<RevenueResponse?> getRevenueByMonth(int year) async {
    final response = await _dashboardService.getRevenueByMonth(year);
    
    if (response.statusCode == 200 && response.data != null) {
      return response.data;
    }
    
    return null;
  }
}
