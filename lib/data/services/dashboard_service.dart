import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/data/services/api_service.dart';
import 'package:ezstore_flutter/domain/models/dashboard_response.dart';
import 'package:ezstore_flutter/domain/models/revenue_response.dart';

class DashboardService {
  final ApiService _api;

  DashboardService(this._api);

  Future<DashboardResponse> getDashboard() async {
    try {
      return _api.get(
        path: ApiConstants.dashboard,
        fromJson: (json) => DashboardResponse.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<RevenueResponse> getRevenueByMonth(int year) async {
    try {
      return await _api.get(
        path: '/workspace/revenue-by-month?year=$year',
        fromJson: (json) => RevenueResponse.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }
}
