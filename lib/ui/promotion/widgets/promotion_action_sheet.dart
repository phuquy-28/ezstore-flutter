import 'package:ezstore_flutter/domain/models/promotion/promotion_response.dart';
import 'package:ezstore_flutter/routing/app_routes.dart';
import 'package:flutter/material.dart';

class PromotionActionSheet extends StatelessWidget {
  final PromotionResponse promotion;
  final Function()? onEdit;
  final Function()? onDelete;

  const PromotionActionSheet({
    Key? key,
    required this.promotion,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  bool isActive() {
    if (promotion.startDate == null || promotion.endDate == null) return false;

    final now = DateTime.now();
    final startDate = DateTime.parse(promotion.startDate!);
    final endDate = DateTime.parse(promotion.endDate!);

    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  // Hiển thị hộp thoại xác nhận xóa
  void _showDeleteConfirmation(BuildContext context) {
    // Lưu tham chiếu context để tránh lỗi
    final navigationContext = context;

    // Đóng action sheet trước
    Navigator.pop(context);

    // Hiển thị hộp thoại xác nhận
    showDialog(
      context: navigationContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa khuyến mãi này? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Đóng hộp thoại
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Đóng hộp thoại
              if (onDelete != null) {
                onDelete!(); // Gọi hàm xóa được truyền vào
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Sửa'),
            onTap: () {
              // Lưu tham chiếu đến context và đường dẫn trước khi đóng action sheet
              final navigationContext = context;
              final promotionId = promotion.id;

              // Đóng action sheet trước
              Navigator.pop(context);

              // Sau đó mới thực hiện điều hướng
              if (onEdit != null) {
                onEdit!();
              } else if (promotionId != null) {
                // Sử dụng context đã lưu để điều hướng
                Navigator.pushNamed(
                  navigationContext,
                  AppRoutes.editPromotion,
                  arguments: {'id': promotionId},
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Xóa', style: TextStyle(color: Colors.red)),
            onTap: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
    );
  }
}
