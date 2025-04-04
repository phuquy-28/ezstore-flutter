import 'package:ezstore_flutter/domain/models/promotion/promotion_response.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_app_bar.dart';
import 'package:ezstore_flutter/ui/promotion/view_models/promotion_detail_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PromotionDetailScreen extends StatefulWidget {
  final int? promotionId;
  final PromotionDetailViewModel viewModel;

  const PromotionDetailScreen({
    Key? key,
    this.promotionId,
    required this.viewModel,
  }) : super(key: key);

  @override
  State<PromotionDetailScreen> createState() => _PromotionDetailScreenState();
}

class _PromotionDetailScreenState extends State<PromotionDetailScreen> {
  final _scrollController = ScrollController();
  late final ScaffoldMessengerState _scaffoldMessenger;
  bool _disposed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lưu tham chiếu đến scaffold messenger để sử dụng an toàn sau này
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_viewModelListener);

    // Tải thông tin khuyến mãi khi màn hình được tạo
    if (widget.promotionId != null) {
      Future.microtask(() => _loadPromotionData());
    }
  }

  @override
  void dispose() {
    _disposed = true;
    widget.viewModel.removeListener(_viewModelListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _viewModelListener() {
    if (mounted && !_disposed) {
      setState(() {
        // Cập nhật UI khi viewModel thay đổi
      });
    }
  }

  Future<void> _loadPromotionData() async {
    try {
      await widget.viewModel.getPromotionById(widget.promotionId!);
    } catch (e) {
      if (mounted) {
        _scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị loading khi đang tải dữ liệu
    if (widget.viewModel.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Hiển thị thông báo lỗi nếu có
    if (widget.viewModel.errorMessage != null) {
      return Scaffold(
        appBar: DetailAppBar(
          title: 'Chi tiết khuyến mãi',
          isEditMode: false,
          onEditToggle: () {},
          showEditButton: false,
        ),
        body: _buildErrorView(),
      );
    }

    // Kiểm tra khuyến mãi có tồn tại không
    final promotion = widget.viewModel.promotion;
    if (promotion == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy khuyến mãi')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DetailAppBar(
        title: 'Chi tiết khuyến mãi',
        onEditToggle: () {
          if (promotion.id != null) {
            widget.viewModel.navigateToEditScreen(context, promotion.id!);
          }
        },
        isEditMode: false, // Luôn ở chế độ xem
        showEditButton: true,
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. Tên khuyến mãi
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tên khuyến mãi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  promotion.name ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 2. Mức giảm giá
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mức giảm giá',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.red.withOpacity(0.1),
                ),
                child: Row(
                  children: [
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
                    const SizedBox(width: 8),
                    Text(
                      'Giảm ${promotion.discountRate?.toInt() ?? 0}% giá sản phẩm',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 3. Mô tả khuyến mãi
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mô tả',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  promotion.description ?? 'Không có mô tả',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 4. Thời gian khuyến mãi
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thời gian khuyến mãi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Bắt đầu: ${promotion.startDate != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(promotion.startDate!)) : 'Chưa thiết lập'}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Kết thúc: ${promotion.endDate != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(promotion.endDate!)) : 'Chưa thiết lập'}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 5. Trạng thái
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Trạng thái',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.viewModel.getStatusColor().withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: widget.viewModel.getStatusColor().withOpacity(0.1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: widget.viewModel.getStatusColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.viewModel.getStatusText(),
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.viewModel.getStatusColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 6. Danh mục áp dụng
          if (promotion.categories != null &&
              promotion.categories!.isNotEmpty) ...[
            const Text(
              'Danh mục áp dụng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildCategoriesList(promotion.categories!),
            const SizedBox(height: 24),
          ],

          // 7. Sản phẩm áp dụng
          if (promotion.products != null && promotion.products!.isNotEmpty) ...[
            const Text(
              'Sản phẩm áp dụng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildProductsList(promotion.products!),
          ],
        ],
      ),
    );
  }

  // Hiển thị danh sách danh mục
  Widget _buildCategoriesList(List<Categories> categories) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            category.name ?? 'Danh mục không tên',
            style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Hiển thị danh sách sản phẩm
  Widget _buildProductsList(List<Products> products) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hình ảnh sản phẩm
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.images != null && product.images!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product.images!.first,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, error, stackTrace) =>
                              Container(
                            color: Colors.grey[200],
                            width: 80,
                            height: 80,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                // Thông tin sản phẩm
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name ?? 'Sản phẩm không tên',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      if (product.categoryName != null) ...[
                        Text(
                          'Danh mục: ${product.categoryName}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Row(
                        children: [
                          if (product.price != null) ...[
                            Text(
                              'Giá gốc: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(product.price)}',
                              style: TextStyle(
                                color: Colors.grey[700],
                                decoration: TextDecoration.lineThrough,
                                fontSize: 14,
                              ),
                            ),
                          ],
                          Spacer(),
                          if (product.priceWithDiscount != null) ...[
                            Text(
                              '${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(product.priceWithDiscount)}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget hiển thị lỗi
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            "Đã xảy ra lỗi",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              widget.viewModel.errorMessage ??
                  "Không thể tải thông tin khuyến mãi",
              style: TextStyle(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPromotionData,
            child: const Text("Thử lại"),
          ),
        ],
      ),
    );
  }
}
