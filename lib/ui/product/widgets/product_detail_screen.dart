import 'package:ezstore_flutter/config/translations.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_app_bar.dart';
import 'package:ezstore_flutter/ui/product/view_models/product_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ezstore_flutter/ui/product/widgets/edit_product_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _scrollController = ScrollController();
  // Map to group variants by color
  final Map<String, List<dynamic>> _groupedVariants = {};

  @override
  void initState() {
    super.initState();

    // Tải thông tin sản phẩm khi màn hình được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final viewModel =
            Provider.of<ProductDetailViewModel>(context, listen: false);
        viewModel.getProductById(widget.productId);
      }
    });
  }

  // Group variants by color
  void _groupVariantsByColor(List<dynamic>? variants) {
    if (variants == null || variants.isEmpty) return;

    _groupedVariants.clear();
    for (var variant in variants) {
      final color = variant.color ?? '';
      if (!_groupedVariants.containsKey(color)) {
        _groupedVariants[color] = [];
      }
      _groupedVariants[color]!.add(variant);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductDetailViewModel>(
      builder: (context, viewModel, child) {
        // Hiển thị loading khi đang tải dữ liệu
        if (viewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Hiển thị thông báo lỗi nếu có
        if (viewModel.errorMessage != null) {
          return Scaffold(
            appBar: DetailAppBar(
              title: 'Chi tiết sản phẩm',
              isEditMode: false,
              onEditToggle: () {},
              showEditButton: false,
            ),
            body: _buildErrorView(viewModel.errorMessage!),
          );
        }

        // Kiểm tra sản phẩm có tồn tại không
        final product = viewModel.product;
        if (product == null) {
          return const Scaffold(
            body: Center(child: Text('Không tìm thấy sản phẩm')),
          );
        }

        // Group variants by color for display
        _groupVariantsByColor(product.variants);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: DetailAppBar(
            title: 'Chi tiết sản phẩm',
            onEditToggle: () => _navigateToEditScreen(context, product.id ?? 0),
            isEditMode: false, // Luôn ở chế độ xem
            showEditButton: true,
          ),
          body: ListView(
            controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              children: [
              // 1. Tên sản phẩm
              Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                    'Tên sản phẩm',
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
                      product.name ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
                  ),

                const SizedBox(height: 16),

              // 2. Mô tả sản phẩm
              Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                    'Mô tả sản phẩm',
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
                      product.description ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
                  ),

                const SizedBox(height: 16),

              // 3. Giá sản phẩm
              Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                    'Giá sản phẩm',
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
                      '${product.price}',
                          style: const TextStyle(
                            fontSize: 16,
                        color: Colors.black,
                        ),
                    ),
                  ),
                ],
                  ),

                const SizedBox(height: 16),

              // 4. Danh mục
              Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                    'Danh mục',
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
                      product.categoryName ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 5. Nổi bật toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nổi bật',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                      product.featured == true ? 'Có' : 'Không',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

              // 6. Hình ảnh sản phẩm
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hình ảnh sản phẩm',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildProductImagesGallery(product.images),
                ],
              ),

              const SizedBox(height: 24),

              // 7. Biến thể sản phẩm
              const Text(
                'Biến thể sản phẩm',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Hiển thị danh sách biến thể theo màu sắc
              if (_groupedVariants.isNotEmpty)
                ...List.generate(_groupedVariants.keys.length, (index) {
                  final color = _groupedVariants.keys.elementAt(index);
                  final colorVariants = _groupedVariants[color]!;
                  return _buildVariantColorGroup(color, colorVariants);
                })
              else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('Không có biến thể nào'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // Widget hiển thị nhóm biến thể theo màu sắc
  Widget _buildVariantColorGroup(String color, List<dynamic> variants) {
    // Collect all unique images for this color
    final List<String> colorImages = [];
    for (final variant in variants) {
      if (variant.images != null && variant.images!.isNotEmpty) {
        for (final image in variant.images!) {
          if (!colorImages.contains(image)) {
            colorImages.add(image);
          }
        }
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display color and image section using similar layout to ProductVariantItem
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getColorFromName(color),
                    border: color.toUpperCase() == 'WHITE'
                        ? Border.all(color: Colors.grey[300]!)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Màu: ${ColorTranslations.getColorName(color)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            // Display variant images in grid
            if (colorImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hình ảnh biến thể:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildVariantImagesGrid(colorImages),
                  ],
                ),
              ),

            // Display size details
            const SizedBox(height: 16),
            const Text(
              'Chi tiết kích thước:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Display each size variant
            ...List.generate(variants.length, (index) {
              final variant = variants[index];
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kích thước: ${SizeTranslations.getSizeName(variant.size ?? '')}',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Số lượng: ${variant.quantity}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (variant.differencePrice != null &&
                        variant.differencePrice != 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Chênh lệch giá: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(variant.differencePrice)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị lưới các hình ảnh biến thể
  Widget _buildVariantImagesGrid(List<String> images) {
    if (images.isEmpty) {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported,
                  color: Colors.grey[400], size: 48),
              const SizedBox(height: 8),
              Text('Không có hình ảnh',
                  style: TextStyle(color: Colors.grey[500])),
            ],
          ),
        ),
      );
    }

    // Calculate grid layout based on image count
    int crossAxisCount = images.length == 1 ? 1 : 2;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: images.length,
          padding: const EdgeInsets.all(4),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                _showFullScreenImage(context, images, index);
              },
              child: RepaintBoundary(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CachedNetworkImage(
                      imageUrl: images[index],
              fit: BoxFit.contain,
                      placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                        ),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red[300], size: 24),
                            const SizedBox(height: 4),
                            Text(
                              'Lỗi',
                              style: TextStyle(
                                  color: Colors.red[300], fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      fadeInDuration: const Duration(milliseconds: 200),
                      memCacheWidth: 260,
                    ),
                  ),
                ),
                      ),
                    );
                  },
        ),
      ),
    );
  }

  // Local helper function to get color from name
  Color _getColorFromName(String colorName) {
    switch (colorName.toUpperCase()) {
      case 'RED':
        return Colors.red;
      case 'YELLOW':
        return Colors.yellow;
      case 'BLUE':
        return Colors.blue;
      case 'GREEN':
        return Colors.green;
      case 'PURPLE':
        return Colors.purple;
      case 'BROWN':
        return Colors.brown;
      case 'GRAY':
        return Colors.grey;
      case 'PINK':
        return Colors.pink;
      case 'ORANGE':
        return Colors.orange;
      case 'BLACK':
        return Colors.black;
      case 'WHITE':
        return Colors.white;
      default:
        return Colors.black;
    }
  }

  // Widget hiển thị gallery hình ảnh sản phẩm
  Widget _buildProductImagesGallery(List<String>? images) {
    if (images == null || images.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
              Icon(Icons.image_not_supported,
                  size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
                'Không có hình ảnh',
                style: TextStyle(color: Colors.grey[500]),
          ),
        ],
          ),
      ),
    );
  }

    // Calculate the optimal grid layout based on number of images
    int crossAxisCount = 1;
    double aspectRatio = 1.0;

    if (images.length == 1) {
      crossAxisCount = 1;
      aspectRatio = 1.5; // Wider single image
    } else if (images.length == 2) {
      crossAxisCount = 2;
      aspectRatio = 1.0;
    } else if (images.length <= 4) {
      crossAxisCount = 2;
      aspectRatio = 1.0;
    } else {
      crossAxisCount = 3;
      aspectRatio = 1.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: aspectRatio,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: images.length,
              padding: const EdgeInsets.all(4),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Adding the ability to view images in full screen when tapped
                    _showFullScreenImage(context, images, index);
                  },
                  child: RepaintBoundary(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: images[index],
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.grey[400]!),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.red[300], size: 36),
          const SizedBox(height: 8),
          Text(
                                    'Không thể tải hình ảnh',
                                    style: TextStyle(
                                        color: Colors.red[300], fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          fadeInDuration: const Duration(milliseconds: 200),
                          memCacheWidth: 400,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              'Nhấn vào ảnh để xem chi tiết',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  // Hiển thị ảnh toàn màn hình khi nhấn vào
  void _showFullScreenImage(
      BuildContext context, List<String> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Hình ảnh sản phẩm',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: PageView.builder(
              itemCount: images.length,
              controller: PageController(initialPage: initialIndex),
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      errorWidget: (context, url, error) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không thể tải hình ảnh',
                            style: TextStyle(color: Colors.red[300]),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(String errorMessage) {
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
              errorMessage,
              style: TextStyle(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final viewModel =
                  Provider.of<ProductDetailViewModel>(context, listen: false);
              viewModel.getProductById(widget.productId);
            },
            child: const Text("Thử lại"),
          ),
        ],
      ),
    );
  }

  // Phương thức chuyển đến màn hình chỉnh sửa sản phẩm
  void _navigateToEditScreen(BuildContext context, int productId) async {
    // Sử dụng MaterialPageRoute trực tiếp thay vì pushNamed để tránh vấn đề với routing
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(productId: productId),
      ),
    );

    // Nếu có thay đổi và quay lại, refresh lại dữ liệu sản phẩm
    if (result == true && mounted) {
      final viewModel =
          Provider.of<ProductDetailViewModel>(context, listen: false);
      viewModel.getProductById(productId);
    }
  }
}
