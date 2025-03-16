import 'package:ezstore_flutter/data/services/dashboard_service.dart';
import 'package:ezstore_flutter/domain/models/dashboard/dashboard_response.dart';
import 'package:ezstore_flutter/domain/models/dashboard/revenue_response.dart';
import 'dart:developer' as dev;

class DashboardRepository {
  final DashboardService _dashboardService;

  DashboardRepository(this._dashboardService);

  Future<DashboardResponse?> getDashboardMetric() async {
    try {
      final response = await _dashboardService.getDashboard();
      
      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }
      
      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi lấy dữ liệu dashboard: $e');
      rethrow;
    }
  }

  Future<RevenueResponse?> getRevenueByMonth(int year) async {
    try {
      final response = await _dashboardService.getRevenueByMonth(year);
      
      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }
      
      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi lấy dữ liệu doanh thu: $e');
      rethrow;
    }
  }
}
