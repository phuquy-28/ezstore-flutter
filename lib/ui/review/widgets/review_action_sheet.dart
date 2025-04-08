import 'package:ezstore_flutter/domain/models/review/widgets/review_response.dart';
import 'package:flutter/material.dart';

class ReviewActionSheet extends StatelessWidget {
  final ReviewResponse review;
  final VoidCallback onTogglePublished;
  final VoidCallback onDelete;

  const ReviewActionSheet({
    Key? key,
    required this.review,
    required this.onTogglePublished,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(
              review.published ?? false
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            title: Text(
              review.published ?? false ? 'Ẩn' : 'Công khai',
            ),
            onTap: () {
              Navigator.pop(context);
              onTogglePublished();
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
                Navigator.of(context).pop();
                onDelete();
              },
            ),
          ],
        );
      },
    );
  }
}
