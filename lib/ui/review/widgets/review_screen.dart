import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_app_bar.dart';
import 'package:ezstore_flutter/ui/drawer/widgets/custom_drawer.dart';
import 'package:ezstore_flutter/ui/user/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Review {
  final int reviewId;
  final String description;
  final int rating;
  final DateTime createdAt;
  final UserReview userReviewDTO;
  bool published;

  Review({
    required this.reviewId,
    required this.description,
    required this.rating,
    required this.createdAt,
    required this.userReviewDTO,
    required this.published,
  });
}

class UserReview {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final int totalSpend;
  final int totalReview;

  UserReview({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.totalSpend,
    required this.totalReview,
  });
}

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({Key? key}) : super(key: key);

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final List<Review> reviews = [
    Review(
      reviewId: 19,
      description: "Sản phẩm rất tốt. Đã mua lại lần 2.",
      rating: 5,
      createdAt: DateTime.parse("2024-12-23T00:11:55.082944"),
      userReviewDTO: UserReview(
        id: 2,
        firstName: "Oss",
        lastName: "Sssss",
        email: "phuquy2823@gmail.com",
        totalSpend: 1671390,
        totalReview: 100,
      ),
      published: true,
    ),
    Review(
      reviewId: 19,
      description: "Sản phẩm rất tốt. Đã mua lại lần 2.",
      rating: 5,
      createdAt: DateTime.parse("2024-12-23T00:11:55.082944"),
      userReviewDTO: UserReview(
        id: 2,
        firstName: "Oss",
        lastName: "Sssss",
        email: "phuquy2823@gmail.com",
        totalSpend: 6713900,
        totalReview: 1,
      ),
      published: false,
    ),
    Review(
      reviewId: 19,
      description: "Sản phẩm rất tốt. Đã mua lại lần 2.",
      rating: 5,
      createdAt: DateTime.parse("2024-12-23T00:11:55.082944"),
      userReviewDTO: UserReview(
        id: 2,
        firstName: "Oss",
        lastName: "Sssss",
        email: "phuquy2823@gmail.com",
        totalSpend: 16713900,
        totalReview: 1,
      ),
      published: true,
    ),
    Review(
      reviewId: 19,
      description: "Sản phẩm rất tốt. Đã mua lại lần 2.",
      rating: 5,
      createdAt: DateTime.parse("2024-12-23T00:11:55.082944"),
      userReviewDTO: UserReview(
        id: 2,
        firstName: "Oss",
        lastName: "Sssss",
        email: "phuquy2823@gmail.com",
        totalSpend: 16713900,
        totalReview: 1,
      ),
      published: false,
    ),
    Review(
      reviewId: 19,
      description: "Sản phẩm rất tốt. Đã mua lại lần 2.",
      rating: 5,
      createdAt: DateTime.parse("2024-12-23T00:11:55.082944"),
      userReviewDTO: UserReview(
        id: 2,
        firstName: "Oss",
        lastName: "Sssss",
        email: "phuquy2823@gmail.com",
        totalSpend: 16713900,
        totalReview: 1,
      ),
      published: false,
    ),
    // Thêm dữ liệu mẫu khác ở đây
  ];

  String searchQuery = '';

  List<Review> get filteredReviews {
    if (searchQuery.isEmpty) {
      return reviews;
    }
    return reviews
        .where((review) =>
            review.description
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            review.userReviewDTO.email
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            '${review.userReviewDTO.firstName} ${review.userReviewDTO.lastName}'
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.reviews,
      ),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          SearchField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSizes.paddingNormal),
              itemCount: filteredReviews.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSizes.paddingSmall),
              itemBuilder: (context, index) {
                final review = filteredReviews[index];
                return ReviewCard(review: review);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () => _showReviewDetails(context),
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
                        '${review.userReviewDTO.firstName} ${review.userReviewDTO.lastName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tổng chi tiêu: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(review.userReviewDTO.totalSpend)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Đã đánh giá: ${review.userReviewDTO.totalReview}',
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
                      review.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd/MM/yyyy').format(review.createdAt),
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: review.published
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color:
                                  review.published ? Colors.green : Colors.red,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            review.published ? 'Đã xuất bản' : 'Chưa xuất bản',
                            style: TextStyle(
                              color:
                                  review.published ? Colors.green : Colors.red,
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
          index < review.rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }

  void _showReviewDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) {
          return SingleChildScrollView(
            controller: controller,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Chi tiết nhận xét',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem('Người dùng',
                      '${review.userReviewDTO.firstName} ${review.userReviewDTO.lastName}'),
                  _buildDetailItem('Email', review.userReviewDTO.email),
                  _buildDetailItem('Đánh giá', _buildRatingStars()),
                  _buildDetailItem('Nội dung', review.description),
                  _buildDetailItem('Ngày tạo',
                      DateFormat('dd/MM/yyyy HH:mm').format(review.createdAt)),
                  _buildDetailItem('Trạng thái',
                      review.published ? 'Đã xuất bản' : 'Chưa xuất bản'),
                  _buildDetailItem(
                      'Tổng chi tiêu',
                      NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                          .format(review.userReviewDTO.totalSpend)),
                  _buildDetailItem('Số lượng đánh giá',
                      review.userReviewDTO.totalReview.toString()),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Xử lý logic xuất bản/ẩn
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              review.published ? Colors.orange : Colors.green,
                        ),
                        child: Text(review.published ? 'Ẩn' : 'Xuất bản'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showDeleteConfirmationDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Xóa'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: value is Widget ? value : Text(value.toString()),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa nhận xét này?'),
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
                // Xử lý logic xóa ở đây
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
                  _showEditReviewDialog(context);
                },
              ),
              if (review.published)
                ListTile(
                  leading: const Icon(Icons.visibility_off),
                  title: const Text('Ẩn'),
                  onTap: () {
                    Navigator.pop(context);
                    // Xử lý logic ẩn review
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.visibility),
                  title: const Text('Xuất bản'),
                  onTap: () {
                    Navigator.pop(context);
                    // Xử lý logic xuất bản review
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Xóa', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditReviewDialog(BuildContext context) {
    // Implementation of _showEditReviewDialog method
  }
}
