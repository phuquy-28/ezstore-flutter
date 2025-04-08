import 'package:ezstore_flutter/domain/models/review/widgets/review_response.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_app_bar.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_button.dart';
import 'package:ezstore_flutter/ui/review/view_models/review_detail_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReviewDetailScreen extends StatefulWidget {
  final ReviewDetailViewModel viewModel;
  final int reviewId;

  const ReviewDetailScreen({
    Key? key,
    required this.viewModel,
    required this.reviewId,
  }) : super(key: key);

  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_viewModelListener);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_viewModelListener);
    super.dispose();
  }

  void _viewModelListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.viewModel.review;
    if (review == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: DetailAppBar(
        title: 'Chi tiết đánh giá',
        isEditMode: false,
        showEditButton: false,
        onEditToggle: () {},
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReviewInfo(review),
            const SizedBox(height: 16),
            _buildUserInfo(review),
            const SizedBox(height: 16),
            _buildReviewContent(review),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewInfo(ReviewResponse review) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin đánh giá',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Mã đánh giá:', review.reviewId?.toString() ?? 'N/A'),
            _buildInfoRow(
              'Ngày tạo:',
              review.createdAt != null
                  ? DateFormat('dd/MM/yyyy HH:mm')
                      .format(DateTime.parse(review.createdAt!))
                  : 'N/A',
            ),
            _buildInfoRow('Đánh giá:', _buildRatingStars(review)),
            _buildStatusRow(
              'Trạng thái:',
              review.published ?? false ? 'Công khai' : 'Ẩn',
              review.published ?? false ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(ReviewResponse review) {
    final user = review.userReviewDTO;
    if (user == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin người dùng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Họ tên:', '${user.firstName} ${user.lastName}'),
            _buildInfoRow('Email:', user.email ?? 'N/A'),
            _buildInfoRow(
              'Tổng chi tiêu:',
              NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                  .format(user.totalSpend ?? 0),
            ),
            _buildInfoRow(
                'Số lượng đánh giá:', user.totalReview?.toString() ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewContent(ReviewResponse review) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nội dung đánh giá',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              review.description ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final review = widget.viewModel.review;
    if (review == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: CustomButton(
              text: review.published ?? false ? 'Ẩn' : 'Công khai',
              onPressed: () => widget.viewModel.togglePublished(),
              isLoading: widget.viewModel.isLoading,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              text: 'Xóa',
              onPressed: () => _showDeleteConfirmationDialog(context),
              isLoading: widget.viewModel.isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: value is Widget
                ? value
                : Text(
                    value.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          Wrap(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(ReviewResponse review) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < (review.rating ?? 0) ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa đánh giá này?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onPressed: () {
                widget.viewModel.deleteReview();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
