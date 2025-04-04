import 'package:ezstore_flutter/domain/models/promotion/promotion_response.dart';
import 'package:ezstore_flutter/ui/promotion/widgets/promotion_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PromotionCard extends StatelessWidget {
  final PromotionResponse promotion;
  final VoidCallback? onTap;
  final Function(int)? onDelete; // Callback khi người dùng muốn xóa khuyến mãi

  const PromotionCard({
    Key? key,
    required this.promotion,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Function to check if promotion is active
    bool isActive() {
      if (promotion.startDate == null || promotion.endDate == null)
        return false;

      final now = DateTime.now();
      final startDate = DateTime.parse(promotion.startDate!);
      final endDate = DateTime.parse(promotion.endDate!);

      return now.isAfter(startDate) && now.isBefore(endDate);
    }

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
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
                          promotion.name ?? 'Unnamed Promotion',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          promotion.description ?? 'No description',
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
                      '-${promotion.discountRate?.toInt() ?? 0}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => PromotionActionSheet(
                          promotion: promotion,
                          onDelete: promotion.id != null && onDelete != null
                              ? () => onDelete!(promotion.id!)
                              : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (promotion.startDate != null)
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Start: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(promotion.startDate!))}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              if (promotion.endDate != null)
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'End: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(promotion.endDate!))}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (promotion.categories != null &&
                      promotion.categories!.isNotEmpty)
                    Container(
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
                        '${promotion.categories!.length} danh mục',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  if (promotion.products != null &&
                      promotion.products!.isNotEmpty)
                    Container(
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
                        '${promotion.products!.length} sản phẩm',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isActive()
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isActive() ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Text(
                      isActive() ? 'Hoạt động' : 'Không hoạt động',
                      style: TextStyle(
                        color: isActive() ? Colors.green : Colors.red,
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
}
