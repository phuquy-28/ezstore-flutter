import 'package:flutter/material.dart';
import '../../../data/repositories/dashboard_repository.dart';
import '../../../domain/models/dashboard/dashboard_response.dart';
import '../../../domain/models/dashboard/revenue_response.dart';
import '../../../provider/user_info_provider.dart';

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

  // Phương thức để hiển thị thông báo lỗi
  void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Phương thức khởi tạo ban đầu cho dashboard
  Future<void> initDashboard(
      BuildContext context, int year, UserInfoProvider userInfoProvider) async {
    try {
      _setLoading(true);

      // Đặt lại dữ liệu về null để đảm bảo gọi mới
      _dashboardData = null;
      _revenueData = null;
      _errorMessage = null;
      notifyListeners();

      // Gọi API đồng thời để lấy dữ liệu
      await Future.wait([
        userInfoProvider.fetchUserInfo(),
        _dashboardRepository.getDashboardMetric().then((value) {
          _dashboardData = value;
        }),
        _dashboardRepository.getRevenueByMonth(year).then((value) {
          _revenueData = value;
        }),
      ]);

      if (_errorMessage != null && context.mounted) {
        showErrorSnackbar(context, 'Đã xảy ra lỗi: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (context.mounted) {
        showErrorSnackbar(context, 'Đã xảy ra lỗi: ${e.toString()}');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Phương thức làm mới tất cả dữ liệu
  Future<void> refreshAllData(
      BuildContext context, int year, UserInfoProvider userInfoProvider) async {
    if (_isLoading) return;

    try {
      _setLoading(true);

      // Đặt lại dữ liệu về null
      _dashboardData = null;
      _revenueData = null;
      _errorMessage = null;
      notifyListeners();

      // Gọi API để lấy dữ liệu mới
      await Future.wait([
        userInfoProvider.fetchUserInfo(forceRefresh: true),
        _dashboardRepository.getDashboardMetric().then((value) {
          _dashboardData = value;
        }),
        _dashboardRepository.getRevenueByMonth(year).then((value) {
          _revenueData = value;
        }),
      ]);

      if (_errorMessage != null && context.mounted) {
        showErrorSnackbar(context, 'Đã xảy ra lỗi: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (context.mounted) {
        showErrorSnackbar(context, 'Đã xảy ra lỗi: ${e.toString()}');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Phương thức lấy dữ liệu dashboard
  Future<void> fetchDashboardData() async {
    try {
      _setLoading(true);

      final result = await _dashboardRepository.getDashboardMetric();
      _dashboardData = result;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Không thể tải dữ liệu dashboard: ${e.toString()}";
      print("Dashboard Error: $_errorMessage");
    } finally {
      _setLoading(false);
    }
  }

  // Phương thức lấy dữ liệu doanh thu theo năm
  Future<void> fetchRevenueData(int year) async {
    try {
      _setLoading(true);

      final result = await _dashboardRepository.getRevenueByMonth(year);
      _revenueData = result;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Không thể tải dữ liệu doanh thu: ${e.toString()}";
      print("Revenue Error: $_errorMessage");
    } finally {
      _setLoading(false);
    }
  }

  // Phương thức xử lý khi thay đổi năm
  void handleYearChange(BuildContext context, int newYear) async {
    try {
      _setLoading(true);
      await fetchRevenueData(newYear);

      if (_errorMessage != null && context.mounted) {
        showErrorSnackbar(context, 'Đã xảy ra lỗi: $_errorMessage');
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackbar(context, 'Đã xảy ra lỗi: ${e.toString()}');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Phương thức xử lý khi nhấn nút "Thử lại"
  Future<void> retry(
      BuildContext context, int year, UserInfoProvider userInfoProvider) async {
    await initDashboard(context, year, userInfoProvider);
  }

  // Phương thức riêng để cập nhật trạng thái loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
