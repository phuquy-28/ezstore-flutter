import 'package:flutter/material.dart';
import '../../../data/repositories/dashboard_repository.dart';
import '../../../domain/models/dashboard/dashboard_response.dart';
import '../../../domain/models/dashboard/revenue_response.dart';

class DashboardViewModel with ChangeNotifier {
  final DashboardRepository _dashboardRepository;
  DashboardResponse? _dashboardData;
  RevenueResponse? _revenueData;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardViewModel(this._dashboardRepository);

  DashboardResponse? get dashboardData => _dashboardData;
  RevenueResponse? get revenueData => _revenueData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Phương thức mới để làm mới tất cả dữ liệu
  Future<void> refreshAllData(int year) async {
    if (_isLoading) return;
    
    try {
      _setLoading(true);
      
      // Đặt lại dữ liệu về null
      _dashboardData = null;
      _revenueData = null;
      _errorMessage = null;
      notifyListeners();
      
      // Gọi API để lấy dữ liệu mới
      _dashboardData = await _dashboardRepository.getDashboardMetric();
      _revenueData = await _dashboardRepository.getRevenueByMonth(year);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchDashboardData() async {
    if (_isLoading) return; // Tránh gọi nhiều lần khi đang tải
    
    try {
      _setLoading(true);
      
      _dashboardData = await _dashboardRepository.getDashboardMetric();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchRevenueData(int year) async {
    if (_isLoading) return; // Tránh gọi nhiều lần khi đang tải
    
    try {
      _setLoading(true);
      
      _revenueData = await _dashboardRepository.getRevenueByMonth(year);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  // Phương thức riêng để cập nhật trạng thái loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
