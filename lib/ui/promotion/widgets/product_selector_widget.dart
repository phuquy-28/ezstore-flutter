import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ezstore_flutter/domain/models/product/product_response.dart';
import 'package:intl/intl.dart';

/// Widget hiển thị chọn sản phẩm có thể sử dụng lại ở nhiều màn hình
class ProductSelectorWidget extends StatefulWidget {
  /// Danh sách các sản phẩm
  final List<ProductResponse> products;

  /// Danh sách ID của các sản phẩm đã chọn
  final List<int> selectedProductIds;

  /// Callback khi chọn/bỏ chọn một sản phẩm
  final Function(int) onToggleSelection;

  /// Callback khi cần load thêm sản phẩm (phân trang)
  final Function() onLoadMore;

  /// Callback khi tìm kiếm sản phẩm
  final Function(String) onSearch;

  /// Callback khi clear tìm kiếm
  final Function() onClearSearch;

  /// Trạng thái đang tải sản phẩm
  final bool isLoading;

  /// Kiểm tra xem có thể tải thêm sản phẩm không
  final bool hasMoreItems;

  /// Tiêu đề hiển thị của selector
  final String title;

  const ProductSelectorWidget({
    Key? key,
    required this.products,
    required this.selectedProductIds,
    required this.onToggleSelection,
    required this.onLoadMore,
    required this.onSearch,
    required this.onClearSearch,
    required this.isLoading,
    required this.hasMoreItems,
    this.title = 'Sản phẩm cụ thể',
  }) : super(key: key);

  @override
  State<ProductSelectorWidget> createState() => _ProductSelectorWidgetState();
}

class _ProductSelectorWidgetState extends State<ProductSelectorWidget> {
  bool _expanded = false;
  final TextEditingController _productSearchController =
      TextEditingController();

  @override
  void dispose() {
    _productSearchController.dispose();
    super.dispose();
  }

  void _handleProductSearch(String keyword) {
    widget.onSearch(keyword);
  }

  void _clearSearch() {
    _productSearchController.clear();
    widget.onClearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Card để hiển thị và ẩn/hiện phần chọn sản phẩm
        _buildSelectionCard(
          title: widget.title,
          subtitle: widget.selectedProductIds.isEmpty
              ? 'Chưa chọn sản phẩm nào'
              : '${widget.selectedProductIds.length} sản phẩm được chọn',
          icon: Icons.shopping_bag_outlined,
          onTap: () {
            setState(() {
              _expanded = !_expanded; // Toggle trạng thái mở rộng/thu gọn
            });
          },
          isSelected: _expanded,
        ),

        // Hiển thị phần chọn sản phẩm nếu đang mở rộng
        if (_expanded) ...[
          const SizedBox(height: 16),
          _buildProductSelector(),
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

  // Widget cho phần chọn sản phẩm có phân trang và tìm kiếm
  Widget _buildProductSelector() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 350),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Phần tìm kiếm sản phẩm
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _productSearchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: _handleProductSearch,
              textInputAction: TextInputAction.search,
            ),
          ),

          // Danh sách sản phẩm có phân trang
          Expanded(
            child: widget.isLoading && widget.products.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : widget.products.isEmpty
                    ? const Center(child: Text('Không có sản phẩm nào'))
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
                          itemCount: widget.products.length +
                              (widget.isLoading && widget.products.isNotEmpty
                                  ? 1
                                  : 0),
                          itemBuilder: (context, index) {
                            if (index == widget.products.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            }

                            final product = widget.products[index];
                            final isSelected =
                                widget.selectedProductIds.contains(product.id);

                            return CheckboxListTile(
                              title: Text(
                                product.name ?? 'Sản phẩm không tên',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                '${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(product.price ?? 0)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              secondary: product.images != null &&
                                      product.images!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: CachedNetworkImage(
                                        imageUrl: product.images!.first,
                                        width: 50,
                                        height: 50,
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
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[200],
                                      child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey),
                                    ),
                              value: isSelected,
                              activeColor: Colors.black,
                              onChanged: (bool? value) {
                                if (value != null && product.id != null) {
                                  widget.onToggleSelection(product.id!);
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
