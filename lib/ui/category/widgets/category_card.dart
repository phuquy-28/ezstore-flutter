import 'package:ezstore_flutter/domain/models/category/category.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'category_action_sheet.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onViewDetails;
  final Function(int) onDelete;
  final VoidCallback onEditSuccess;

  const CategoryCard({
    Key? key,
    required this.category,
    required this.onViewDetails,
    required this.onDelete,
    required this.onEditSuccess,
  }) : super(key: key);

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => CategoryActionSheet(
        category: category,
        onDeleteCategory: onDelete,
        onEditSuccess: onEditSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onViewDetails,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Category Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: category.imageUrl != null &&
                        category.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: category.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, url, error) =>
                            _buildImagePlaceholder(),
                      )
                    : _buildImagePlaceholder(),
              ),
              const SizedBox(width: 16),
              // Category Name
              Expanded(
                child: Text(
                  category.name ?? 'Không có tên',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Action Menu
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showActionSheet(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
}
