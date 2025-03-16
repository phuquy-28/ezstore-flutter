import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/data/services/api_service.dart';
import 'package:ezstore_flutter/domain/models/dashboard/dashboard_response.dart';
import 'package:ezstore_flutter/domain/models/dashboard/revenue_response.dart';
import 'package:ezstore_flutter/data/models/api_response.dart';

class DashboardService {
  final ApiService _api;

  DashboardService(this._api);

  Future<ApiResponse<DashboardResponse>> getDashboard() async {
    return await _api.get(
      path: ApiConstants.dashboard,
      fromJson: (json) => DashboardResponse.fromJson(json),
    );
  }

  Future<ApiResponse<RevenueResponse>> getRevenueByMonth(int year) async {
    return await _api.get(
      path: '/workspace/revenue-by-month',
      queryParameters: {'year': year},
      fromJson: (json) => RevenueResponse.fromJson(json),
    );
  }
}
