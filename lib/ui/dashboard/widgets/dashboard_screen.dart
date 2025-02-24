import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../drawer/widgets/custom_drawer.dart';
import 'metric_card.dart';
import '../../../config/constants.dart';
import '../../core/shared/custom_app_bar.dart';
import '../../core/shared/orders_table.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedYear = 2024;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppStrings.appName),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
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

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Xin chào, Matthew!',
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
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: const [
        MetricCard(
          title: 'Tổng doanh thu',
          value: '₫45.5M',
          subtitle: 'Tổng quan',
          change: '+15.2%',
          icon: Icons.attach_money,
          color: Colors.green,
        ),
        MetricCard(
          title: 'Tổng đơn hàng',
          value: '1,234',
          subtitle: 'Tổng quan',
          change: '+10.3%',
          icon: Icons.shopping_cart,
          color: Colors.blue,
        ),
        MetricCard(
          title: 'Tổng khách hàng',
          value: '3.2K',
          subtitle: 'Tổng quan',
          change: '+8.1%',
          icon: Icons.people,
          color: Colors.purple,
        ),
        MetricCard(
          title: 'Tổng sản phẩm',
          value: '456',
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
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    const FlSpot(0, 12),
                    const FlSpot(1, 8),
                    const FlSpot(2, 15),
                    const FlSpot(3, 10),
                    const FlSpot(4, 13),
                    const FlSpot(5, 18),
                    const FlSpot(6, 14),
                    const FlSpot(7, 12),
                    const FlSpot(8, 16),
                    const FlSpot(9, 11),
                    const FlSpot(10, 13),
                    const FlSpot(11, 15),
                  ],
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
                      return Text('${value.toInt()}M');
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
