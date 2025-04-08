import 'package:ezstore_flutter/domain/models/review/widgets/review_response.dart';
import 'package:ezstore_flutter/ui/review/widgets/review_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReviewCard extends StatelessWidget {
  final ReviewResponse review;
  final VoidCallback onViewDetails;
  final VoidCallback onTogglePublished;
  final VoidCallback onDelete;

  const ReviewCard({
    Key? key,
    required this.review,
    required this.onViewDetails,
    required this.onTogglePublished,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: onViewDetails,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cột bên trái - Thông tin reviewer
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        '${review.userReviewDTO?.firstName} ${review.userReviewDTO?.lastName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tổng chi tiêu: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(review.userReviewDTO?.totalSpend ?? 0)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Đã đánh giá: ${review.userReviewDTO?.totalReview}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Cột bên phải - Thông tin review
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildRatingStars(),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showActionSheet(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.description ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          review.createdAt != null
                              ? DateFormat('dd/MM/yyyy HH:mm')
                                  .format(DateTime.parse(review.createdAt!))
                              : '',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (review.published ?? false)
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: (review.published ?? false)
                                  ? Colors.green
                                  : Colors.red,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            (review.published ?? false) ? 'Công khai' : 'Ẩn',
                            style: TextStyle(
                              color: (review.published ?? false)
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingStars() {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < (review.rating ?? 0) ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ReviewActionSheet(
          review: review,
          onTogglePublished: onTogglePublished,
          onDelete: onDelete,
        );
      },
    );
  }
}
