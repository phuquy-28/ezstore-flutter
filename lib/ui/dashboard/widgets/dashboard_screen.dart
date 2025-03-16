import 'package:ezstore_flutter/domain/models/dashboard/dashboard_response.dart';
import 'package:ezstore_flutter/provider/user_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../drawer/widgets/custom_drawer.dart';
import 'metric_card.dart';
import '../../../config/constants.dart';
import '../../core/shared/custom_app_bar.dart';
import '../../core/shared/orders_table.dart';
import 'package:provider/provider.dart';
import 'package:ezstore_flutter/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedYear = 2024;

  @override
  void initState() {
    super.initState();

    // Sử dụng Future.microtask để đảm bảo gọi sau khi build hoàn tất
    Future.microtask(() {
      final userInfoProvider =
          Provider.of<UserInfoProvider>(context, listen: false);
      final dashboardViewModel =
          Provider.of<DashboardViewModel>(context, listen: false);

      // Gọi API đồng thời chỉ một lần
      Future.wait([
        userInfoProvider.fetchUserInfo(),
        dashboardViewModel.fetchDashboardData(),
        dashboardViewModel.fetchRevenueData(selectedYear),
      ]).then((_) {
        // Kiểm tra lỗi sau khi tất cả các API đã được gọi
        if (dashboardViewModel.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Đã xảy ra lỗi: ${dashboardViewModel.errorMessage}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppStrings.appName),
      drawer: CustomDrawer(),
      body: Consumer<DashboardViewModel>(
        builder: (context, dashboardViewModel, child) {
          // Nếu có lỗi, hiển thị màn hình lỗi
          if (dashboardViewModel.errorMessage != null) {
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
                    dashboardViewModel.errorMessage!,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final userInfoProvider =
                          Provider.of<UserInfoProvider>(context, listen: false);

                      // Tải lại dữ liệu khi người dùng nhấn "Thử lại"
                      Future.wait([
                        userInfoProvider.fetchUserInfo(),
                        dashboardViewModel.fetchDashboardData(),
                        dashboardViewModel.fetchRevenueData(selectedYear),
                      ]);
                    },
                    child: const Text("Thử lại"),
                  ),
                ],
              ),
            );
          }

          // Nếu đang tải dữ liệu ban đầu, hiển thị màn hình loading
          if (dashboardViewModel.isLoading &&
              dashboardViewModel.dashboardData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Hiển thị nội dung chính với RefreshIndicator
          return RefreshIndicator(
            onRefresh: () async {
              try {
                final userInfoProvider =
                    Provider.of<UserInfoProvider>(context, listen: false);

                // Gọi API để làm mới thông tin người dùng
                await userInfoProvider.fetchUserInfo();

                // Gọi phương thức mới để làm mới tất cả dữ liệu dashboard
                await dashboardViewModel.refreshAllData(selectedYear);

                // Kiểm tra lỗi sau khi làm mới
                if (dashboardViewModel.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Đã xảy ra lỗi: ${dashboardViewModel.errorMessage}'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xảy ra lỗi: ${e.toString()}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    const SizedBox(height: 24),
                    _buildMetrics(dashboardViewModel.dashboardData),
                    const SizedBox(height: 24),
                    _buildRevenueChart(),
                    const SizedBox(height: 24),
                    _buildLatestOrders(),
                  ],
                ),
              ),
            ),
          );
        },
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

  Widget _buildMetrics(DashboardResponse? dashboardData) {
    final numberFormat = NumberFormat('#,##0');

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
          value: numberFormat.format(dashboardData?.totalRevenue ?? 0),
          subtitle: 'Tổng quan',
          change: '+15.2%',
          icon: Icons.attach_money,
          color: Colors.green,
        ),
        MetricCard(
          title: 'Tổng đơn hàng',
          value: numberFormat.format(dashboardData?.totalOrders ?? 0),
          subtitle: 'Tổng quan',
          change: '+10.3%',
          icon: Icons.shopping_cart,
          color: Colors.blue,
        ),
        MetricCard(
          title: 'Tổng khách hàng',
          value: numberFormat.format(dashboardData?.totalUsers ?? 0),
          subtitle: 'Tổng quan',
          change: '+8.1%',
          icon: Icons.people,
          color: Colors.purple,
        ),
        MetricCard(
          title: 'Tổng sản phẩm',
          value: numberFormat.format(dashboardData?.totalProducts ?? 0),
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
            Consumer<DashboardViewModel>(
              builder: (context, dashboardViewModel, child) {
                return DropdownButton<int>(
                  value: selectedYear,
                  items: [2024, 2023, 2022].map((year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value!;
                    });
                    // Gọi lại dữ liệu doanh thu khi năm thay đổi
                    dashboardViewModel.fetchRevenueData(selectedYear);
                  },
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: Consumer<DashboardViewModel>(
            builder: (context, dashboardViewModel, child) {
              final revenueData = dashboardViewModel.revenueData;

              // Nếu revenueData là null và không đang tải, gọi fetchRevenueData
              if (revenueData == null && !dashboardViewModel.isLoading) {
                // Sử dụng Future.microtask để tránh gọi trong quá trình build
                Future.microtask(() {
                  dashboardViewModel.fetchRevenueData(selectedYear);
                });
                return const Center(child: CircularProgressIndicator());
              }

              return LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: revenueData?.revenueByMonth.map((data) {
                            return FlSpot(data.month.toDouble() - 1,
                                data.revenue / 1_000_000); // Chia cho 1 triệu
                          }).toList() ??
                          [],
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
                          return Text(
                              '${value.toDouble().toStringAsFixed(1)}M');
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
            },
          ),
        ),
      ],
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
        OrdersTable(orders: OrdersTable.getMockOrders()),
      ],
    );
  }
}
