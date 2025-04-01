import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/provider/user_info_provider.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_app_bar.dart';
import 'package:ezstore_flutter/ui/drawer/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'metric_card.dart';
import 'package:provider/provider.dart';
import 'package:ezstore_flutter/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  final DashboardViewModel viewModel;

  const DashboardScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedYear = 2024;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_viewModelListener);

    // Sử dụng Future.microtask để đảm bảo gọi sau khi build hoàn tất
    Future.microtask(() {
      final userInfoProvider =
          Provider.of<UserInfoProvider>(context, listen: false);
      // Đảm bảo gọi initDashboard để lấy đầy đủ dữ liệu
      widget.viewModel.initDashboard(context, _selectedYear, userInfoProvider);
    });
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_viewModelListener);
    super.dispose();
  }

  void _viewModelListener() {
    if (mounted) {
      setState(() {
        _isLoading = widget.viewModel.isLoading;
      });
    }
  }

  void _handleYearChange(int? year) {
    if (year != null && year != _selectedYear) {
      setState(() {
        _selectedYear = year;
      });
      widget.viewModel.handleYearChange(context, year);
    }
  }

  Future<void> _handleRefresh() async {
    final userInfoProvider =
        Provider.of<UserInfoProvider>(context, listen: false);
    await widget.viewModel
        .refreshAllData(context, _selectedYear, userInfoProvider);
    return;
  }

  void _handleRetry() {
    final userInfoProvider =
        Provider.of<UserInfoProvider>(context, listen: false);
    widget.viewModel.retry(context, _selectedYear, userInfoProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppStrings.appName),
      drawer: CustomDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Nếu có lỗi, hiển thị màn hình lỗi
    if (widget.viewModel.errorMessage != null) {
      return _buildErrorView();
    }

    // Nếu đang tải dữ liệu ban đầu, hiển thị màn hình loading
    if (_isLoading && widget.viewModel.dashboardData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Hiển thị nội dung chính với RefreshIndicator
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildMetrics(),
              const SizedBox(height: 24),
              _buildRevenueChart(),
              const SizedBox(height: 24),
              _buildLatestOrders(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            "Đã xảy ra lỗi",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.viewModel.errorMessage!,
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _handleRetry,
            child: const Text("Thử lại"),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final userInfoProvider = Provider.of<UserInfoProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Xin chào, ${userInfoProvider.userInfo?.firstName ?? "Người dùng"}!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Đây là tổng quan hoạt động của cửa hàng',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMetrics() {
    final numberFormat = NumberFormat('#,##0');
    final dashboardData = widget.viewModel.dashboardData;

    // Nếu dữ liệu chưa được tải, hiển thị loading
    if (dashboardData == null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: const CircularProgressIndicator(),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        MetricCard(
          title: 'Tổng doanh thu',
          value: numberFormat.format(dashboardData.totalRevenue),
          subtitle: 'Tổng quan',
          change: '+15.2%',
          icon: Icons.attach_money,
          color: Colors.green,
        ),
        MetricCard(
          title: 'Tổng đơn hàng',
          value: numberFormat.format(dashboardData.totalOrders),
          subtitle: 'Tổng quan',
          change: '+10.3%',
          icon: Icons.shopping_cart,
          color: Colors.blue,
        ),
        MetricCard(
          title: 'Tổng khách hàng',
          value: numberFormat.format(dashboardData.totalUsers),
          subtitle: 'Tổng quan',
          change: '+8.1%',
          icon: Icons.people,
          color: Colors.purple,
        ),
        MetricCard(
          title: 'Tổng sản phẩm',
          value: numberFormat.format(dashboardData.totalProducts),
          subtitle: 'Tổng quan',
          change: '+5.7%',
          icon: Icons.inventory,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildRevenueChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Doanh thu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButton<int>(
              value: _selectedYear,
              items: [2024, 2023, 2022].map((year) {
                return DropdownMenuItem<int>(
                  value: year,
                  child: Text(year.toString()),
                );
              }).toList(),
              onChanged: _handleYearChange,
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: _buildChart(),
        ),
      ],
    );
  }

  Widget _buildChart() {
    final revenueData = widget.viewModel.revenueData;

    // Kiểm tra dữ liệu biểu đồ
    if (revenueData == null) {
      // Hiển thị loading nếu không có dữ liệu hoặc đang tải
      return const Center(child: CircularProgressIndicator());
    }

    // Kiểm tra trường hợp không có dữ liệu hoặc dữ liệu rỗng
    if (revenueData.revenueByMonth.isEmpty) {
      return Center(
        child: Text(
          'Không có dữ liệu doanh thu cho năm $_selectedYear',
          style: TextStyle(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: revenueData.revenueByMonth.map((data) {
              return FlSpot(data.month.toDouble() - 1,
                  data.revenue / 1_000_000); // Chia cho 1 triệu
            }).toList(),
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = [
                  'T1',
                  'T2',
                  'T3',
                  'T4',
                  'T5',
                  'T6',
                  'T7',
                  'T8',
                  'T9',
                  'T10',
                  'T11',
                  'T12'
                ];
                return Text(months[value.toInt()]);
              },
              reservedSize: 38,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text('${value.toDouble().toStringAsFixed(1)}M');
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 5,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: Colors.black12),
            left: BorderSide(color: Colors.black12),
          ),
        ),
      ),
    );
  }

  Widget _buildLatestOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đơn hàng mới nhất',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // OrdersTable(orders: OrdersTable.getMockOrders()),
      ],
    );
  }
}
