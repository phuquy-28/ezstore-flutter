import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_app_bar.dart';
import 'package:ezstore_flutter/ui/drawer/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Promotion {
  final String name;
  final String description;
  final int discount;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, int> scope;
  final bool isActive;

  Promotion({
    required this.name,
    required this.description,
    required this.discount,
    required this.startDate,
    required this.endDate,
    required this.scope,
    required this.isActive,
  });
}

class PromotionScreen extends StatefulWidget {
  const PromotionScreen({super.key});

  @override
  State<PromotionScreen> createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen> {
  final List<Promotion> promotions = [
    Promotion(
      name: 'Christmas 2024',
      description: 'Sales cuối năm',
      discount: 30,
      startDate: DateTime(2024, 11, 30),
      endDate: DateTime(2025, 10, 30),
      scope: {'danh mục': 2},
      isActive: true,
    ),
    Promotion(
      name: 'Super Sale 12.12',
      description: 'Sales tháng 12',
      discount: 40,
      startDate: DateTime(2024, 12, 8),
      endDate: DateTime(2025, 10, 30),
      scope: {
        'danh mục': 1,
        'sản phẩm': 1,
      },
      isActive: true,
    ),
    Promotion(
      name: 'Products Sale',
      description: 'For specific products',
      discount: 50,
      startDate: DateTime(2024, 11, 30),
      endDate: DateTime(2025, 10, 30),
      scope: {'sản phẩm': 2},
      isActive: true,
    ),
  ];

  String searchQuery = '';

  List<Promotion> get filteredPromotions {
    if (searchQuery.isEmpty) {
      return promotions;
    }
    return promotions
        .where((promotion) =>
            promotion.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.promotions,
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddPromotionDialog(context);
            },
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppSizes.paddingNormal,
              top: AppSizes.paddingNormal,
              right: AppSizes.paddingNormal,
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm khuyến mãi...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusNormal),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSizes.paddingNormal),
              itemCount: filteredPromotions.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSizes.paddingSmall),
              itemBuilder: (context, index) {
                final promotion = filteredPromotions[index];
                return PromotionCard(promotion: promotion);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPromotionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm khuyến mãi mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Tên khuyến mãi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Giảm giá (%)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Ngày bắt đầu',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () {
                        // Show date picker
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Ngày kết thúc',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () {
                        // Show date picker
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Add promotion logic
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}

class PromotionCard extends StatelessWidget {
  final Promotion promotion;

  const PromotionCard({super.key, required this.promotion});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          _showPromotionDetails(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promotion.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          promotion.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '-${promotion.discount}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      _showActionSheet(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Bắt đầu: ${DateFormat('dd/MM/yyyy').format(promotion.startDate)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Kết thúc: ${DateFormat('dd/MM/yyyy').format(promotion.endDate)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ...promotion.scope.entries.map(
                    (entry) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${entry.value} ${entry.key}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Text(
                      'Đang diễn ra',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Sửa'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditPromotionDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('Xem chi tiết'),
                onTap: () {
                  Navigator.pop(context);
                  _showPromotionDetails(context);
                },
              ),
              if (promotion.isActive)
                ListTile(
                  leading: const Icon(Icons.stop_circle),
                  title: const Text('Dừng khuyến mãi'),
                  onTap: () {
                    Navigator.pop(context);
                    _showStopConfirmation(context);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Xóa', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPromotionDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chi tiết khuyến mãi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Tên khuyến mãi:', promotion.name),
              _buildDetailRow('Mô tả:', promotion.description),
              _buildDetailRow('Giảm giá:', '${promotion.discount}%'),
              _buildDetailRow(
                'Thời gian:',
                '${DateFormat('dd/MM/yyyy').format(promotion.startDate)} - ${DateFormat('dd/MM/yyyy').format(promotion.endDate)}',
              ),
              const SizedBox(height: 8),
              const Text(
                'Phạm vi áp dụng:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: promotion.scope.entries
                    .map(
                      (entry) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${entry.value} ${entry.key}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showEditPromotionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa khuyến mãi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Tên khuyến mãi',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: promotion.name),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: promotion.description),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Giảm giá (%)',
                  border: OutlineInputBorder(),
                ),
                controller:
                    TextEditingController(text: promotion.discount.toString()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Ngày bắt đầu',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: DateFormat('dd/MM/yyyy')
                            .format(promotion.startDate),
                      ),
                      readOnly: true,
                      onTap: () {
                        // Show date picker
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Ngày kết thúc',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text:
                            DateFormat('dd/MM/yyyy').format(promotion.endDate),
                      ),
                      readOnly: true,
                      onTap: () {
                        // Show date picker
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Update promotion logic
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showStopConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận dừng'),
        content:
            Text('Bạn có chắc chắn muốn dừng khuyến mãi ${promotion.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Stop promotion logic
            },
            child: Text(
              'Có',
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content:
            Text('Bạn có chắc chắn muốn xóa khuyến mãi ${promotion.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete promotion logic
            },
            child: Text(
              'Có',
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }
}
