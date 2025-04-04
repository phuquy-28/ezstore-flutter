import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ezstore_flutter/domain/models/category/category.dart' as models;

/// Widget hiển thị chọn danh mục có thể sử dụng lại ở nhiều màn hình
class CategorySelectorWidget extends StatefulWidget {
  /// Danh sách các danh mục
  final List<models.Category> categories;

  /// Danh sách ID của các danh mục đã chọn
  final List<int> selectedCategoryIds;

  /// Callback khi chọn/bỏ chọn một danh mục
  final Function(int) onToggleSelection;

  /// Callback khi cần load thêm danh mục (phân trang)
  final Function() onLoadMore;

  /// Trạng thái đang tải danh mục
  final bool isLoading;

  /// Kiểm tra xem có thể tải thêm danh mục không
  final bool hasMoreItems;

  /// Tiêu đề hiển thị của selector
  final String title;

  const CategorySelectorWidget({
    Key? key,
    required this.categories,
    required this.selectedCategoryIds,
    required this.onToggleSelection,
    required this.onLoadMore,
    required this.isLoading,
    required this.hasMoreItems,
    this.title = 'Danh mục sản phẩm',
  }) : super(key: key);

  @override
  State<CategorySelectorWidget> createState() => _CategorySelectorWidgetState();
}

class _CategorySelectorWidgetState extends State<CategorySelectorWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Card để hiển thị và ẩn/hiện phần chọn danh mục
        _buildSelectionCard(
          title: widget.title,
          subtitle: widget.selectedCategoryIds.isEmpty
              ? 'Chưa chọn danh mục nào'
              : '${widget.selectedCategoryIds.length} danh mục được chọn',
          icon: Icons.category_outlined,
          onTap: () {
            setState(() {
              _expanded = !_expanded; // Toggle trạng thái mở rộng/thu gọn
            });
          },
          isSelected: _expanded,
        ),

        // Hiển thị phần chọn danh mục nếu đang mở rộng
        if (_expanded) ...[
          const SizedBox(height: 16),
          _buildCategorySelector(),
        ],
      ],
    );
  }

  // Card để hiển thị tựa đề và trạng thái của selector
  Widget _buildSelectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[700],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  // Widget cho phần chọn danh mục có phân trang
  Widget _buildCategorySelector() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Expanded(
            child: widget.isLoading && widget.categories.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : widget.categories.isEmpty
                    ? const Center(child: Text('Không có danh mục nào'))
                    : NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (scrollInfo.metrics.pixels ==
                                  scrollInfo.metrics.maxScrollExtent &&
                              widget.hasMoreItems &&
                              !widget.isLoading) {
                            widget.onLoadMore();
                          }
                          return true;
                        },
                        child: ListView.builder(
                          itemCount: widget.categories.length +
                              (widget.isLoading && widget.categories.isNotEmpty
                                  ? 1
                                  : 0),
                          itemBuilder: (context, index) {
                            if (index == widget.categories.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            }

                            final category = widget.categories[index];
                            final isSelected = widget.selectedCategoryIds
                                .contains(category.id);

                            return CheckboxListTile(
                              title: Text(
                                category.name ?? 'Danh mục không tên',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              secondary: category.imageUrl != null &&
                                      category.imageUrl!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: CachedNetworkImage(
                                        imageUrl: category.imageUrl!,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.grey),
                                              ),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.error,
                                              size: 20, color: Colors.grey),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 40,
                                      height: 40,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.category,
                                          color: Colors.grey),
                                    ),
                              value: isSelected,
                              activeColor: Colors.black,
                              onChanged: (bool? value) {
                                if (value != null && category.id != null) {
                                  widget.onToggleSelection(category.id!);
                                  setState(
                                      () {}); // Cập nhật UI sau khi chọn/bỏ chọn
                                }
                              },
                              controlAffinity: ListTileControlAffinity.trailing,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
