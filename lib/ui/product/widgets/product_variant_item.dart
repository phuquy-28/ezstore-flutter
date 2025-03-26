import 'dart:io';
import 'package:ezstore_flutter/config/translations.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_dropdown.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_text_field.dart';
import 'package:ezstore_flutter/ui/product/view_models/add_product_view_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Add a special property to VariantDetail for ID preservation
extension VariantDetailExt on VariantDetail {
  static final Map<VariantDetail, int?> _idMap = {};

  int? get storedId => _idMap[this];

  void storeId(int? id) {
    if (id != null) {
      _idMap[this] = id;
    }
  }
}

class ProductVariantItem extends StatelessWidget {
  final ProductVariant variant;
  final VoidCallback onDelete;
  final Function(ProductVariant) onVariantChanged;
  final int index;
  final bool requireVariantImage;
  final Map<String, String?>? fieldErrors;
  final Map<int, Map<String, String?>>? detailErrors;
  final bool shouldValidate;
  final Function(int) onAddSizeDetail;
  final Function(int, int) onRemoveSizeDetail;
  final String? initialNetworkImage;

  const ProductVariantItem({
    Key? key,
    required this.variant,
    required this.onDelete,
    required this.onVariantChanged,
    required this.index,
    required this.onAddSizeDetail,
    required this.onRemoveSizeDetail,
    this.requireVariantImage = false,
    this.fieldErrors,
    this.detailErrors,
    this.shouldValidate = false,
    this.initialNetworkImage,
  }) : super(key: key);

  // Danh sách màu sắc và kích thước mẫu
  static final List<String> colors = [
    'RED',
    'YELLOW',
    'BLUE',
    'GREEN',
    'PURPLE',
    'BROWN',
    'GRAY',
    'PINK',
    'ORANGE',
    'BLACK',
    'WHITE'
  ];
  static final List<String> sizes = ['S', 'M', 'L', 'XL', 'XXL'];

  // Hàm lấy màu tương ứng với tên màu
  static Color getColorFromName(String colorName) {
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

  // Xây dựng widget hiển thị màu
  Widget buildColorItem(String colorName) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: ProductVariantItem.getColorFromName(colorName),
            border: colorName.toUpperCase() == 'WHITE'
                ? Border.all(color: Colors.grey[300]!)
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 8),
        Text(ColorTranslations.getColorName(colorName)),
      ],
    );
  }

  // Widget hiển thị chi tiết kích thước
  Widget _buildSizeDetailItem(int detailIndex, VariantDetail detail) {
    final quantityController =
        TextEditingController(text: detail.quantity.toString());
    final priceDifferenceController =
        TextEditingController(text: detail.priceDifference.toString());

    // Make sure text controllers have up-to-date values
    quantityController.text = detail.quantity.toString();
    priceDifferenceController.text = detail.priceDifference.toString();

    final currentDetailErrors =
        detailErrors != null && detailErrors!.containsKey(detailIndex)
            ? detailErrors![detailIndex]
            : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(
          color: (currentDetailErrors != null && currentDetailErrors.isNotEmpty)
              ? Colors.red[100]!
              : Colors.grey[200]!,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kích thước ${detailIndex + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: () => onRemoveSizeDetail(index, detailIndex),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kích thước',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DetailDropdown(
                      value: detail.size,
                      items: sizes,
                      onChanged: (value) {
                        if (value != null) {
                          final updatedDetail = VariantDetail(
                            size: value,
                            quantity: detail.quantity,
                            priceDifference: detail.priceDifference,
                          );
                          _updateSizeDetail(detailIndex, updatedDetail);
                        }
                      },
                      customItemBuilder: (context, item) =>
                          Text(SizeTranslations.getSizeName(item)),
                    ),
                    if (currentDetailErrors != null &&
                        currentDetailErrors['size'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0, left: 12.0),
                        child: Text(
                          currentDetailErrors['size']!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailTextField(
                      controller: quantityController,
                      label: 'Số lượng',
                      hintText: 'Nhập số lượng',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (!shouldValidate) return null;
                        if (value == null || value.isEmpty) {
                          return ' ';
                        }
                        if (int.tryParse(value) == null) {
                          return ' ';
                        }
                        if (int.parse(value) <= 0) {
                          return ' ';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        // Do nothing on change to avoid rebuilding and losing focus
                      },
                      onEditingComplete: () {
                        final value = quantityController.text;
                        if (value.isNotEmpty && int.tryParse(value) != null) {
                          final updatedDetail = VariantDetail(
                            size: detail.size,
                            quantity: int.parse(value),
                            priceDifference: detail.priceDifference,
                          );
                          _updateSizeDetail(detailIndex, updatedDetail);
                        }
                      },
                      onTapOutside: (_) {
                        final value = quantityController.text;
                        if (value.isNotEmpty && int.tryParse(value) != null) {
                          final updatedDetail = VariantDetail(
                            size: detail.size,
                            quantity: int.parse(value),
                            priceDifference: detail.priceDifference,
                          );
                          _updateSizeDetail(detailIndex, updatedDetail);
                        }
                      },
                    ),
                    if (currentDetailErrors != null &&
                        currentDetailErrors['quantity'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0, left: 12.0),
                        child: Text(
                          currentDetailErrors['quantity']!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DetailTextField(
                  controller: priceDifferenceController,
                  label: 'Chênh lệch giá',
                  hintText: 'Nhập chênh lệch giá',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return null; // Cho phép để trống
                    }
                    if (double.tryParse(value) == null) {
                      return ' '; // Non-empty string that won't be visible
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Do nothing on change to avoid rebuilding and losing focus
                  },
                  onEditingComplete: () {
                    final value = priceDifferenceController.text;
                    double? price = 0;
                    if (value.isNotEmpty) {
                      price = double.tryParse(value);
                    }
                    if (price != null) {
                      final updatedDetail = VariantDetail(
                        size: detail.size,
                        quantity: detail.quantity,
                        priceDifference: price,
                      );
                      _updateSizeDetail(detailIndex, updatedDetail);
                    }
                  },
                  onTapOutside: (_) {
                    final value = priceDifferenceController.text;
                    double? price = 0;
                    if (value.isNotEmpty) {
                      price = double.tryParse(value);
                    }
                    if (price != null) {
                      final updatedDetail = VariantDetail(
                        size: detail.size,
                        quantity: detail.quantity,
                        priceDifference: price,
                      );
                      _updateSizeDetail(detailIndex, updatedDetail);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateSizeDetail(int detailIndex, VariantDetail updatedDetail) {
    final updatedDetails = List<VariantDetail>.from(variant.sizeDetails);

    // Get the existing detail
    final existingDetail = variant.sizeDetails[detailIndex];

    // Retrieve stored ID if available
    final existingId = VariantDetailExt._idMap[existingDetail];

    // Apply the update
    updatedDetails[detailIndex] = updatedDetail;

    // Store the ID in the updated detail if it exists
    if (existingId != null) {
      VariantDetailExt._idMap[updatedDetail] = existingId;
    }

    final updatedVariant = ProductVariant(
      color: variant.color,
      sizeDetails: updatedDetails,
      variantImage: variant.variantImage,
    );

    onVariantChanged(updatedVariant);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: (fieldErrors != null && fieldErrors!.isNotEmpty)
              ? Colors.red[100]!
              : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Biến thể ${index + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Phần chọn màu sắc
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Màu sắc',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              DetailDropdown(
                value: variant.color,
                items: colors,
                onChanged: (value) {
                  if (value != null) {
                    final updatedVariant = ProductVariant(
                      color: value,
                      sizeDetails: variant.sizeDetails,
                      variantImage: variant.variantImage,
                    );
                    onVariantChanged(updatedVariant);
                  }
                },
                customItemBuilder: (context, item) => buildColorItem(item),
              ),
              if (fieldErrors != null && fieldErrors!['color'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, left: 12.0),
                  child: Text(
                    fieldErrors!['color']!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),

          // Phần chọn ảnh biến thể
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Ảnh biến thể',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (requireVariantImage)
                const Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: fieldErrors != null && fieldErrors!['image'] != null
                        ? Colors.red
                        : Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: variant.variantImage != null
                    ? Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Image.file(
                                variant.variantImage!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                final updatedVariant = ProductVariant(
                                  color: variant.color,
                                  sizeDetails: variant.sizeDetails,
                                  variantImage: null,
                                );
                                onVariantChanged(updatedVariant);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 20,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : initialNetworkImage != null
                        ? Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: CachedNetworkImage(
                                    imageUrl: initialNetworkImage!,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.error_outline,
                                              color: Colors.red[300], size: 24),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Lỗi tải ảnh',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.red[300]),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => _selectVariantImage(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    final updatedVariant = ProductVariant(
                                      color: variant.color,
                                      sizeDetails: variant.sizeDetails,
                                      variantImage: null,
                                    );
                                    onVariantChanged(updatedVariant);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : InkWell(
                            onTap: () => _selectVariantImage(context),
                            borderRadius: BorderRadius.circular(7),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate,
                                      color: fieldErrors != null &&
                                              fieldErrors!['image'] != null
                                          ? Colors.red[300]
                                          : Colors.grey[400],
                                      size: 48),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tải lên hình ảnh biến thể',
                                    style: TextStyle(
                                        color: fieldErrors != null &&
                                                fieldErrors!['image'] != null
                                            ? Colors.red[300]
                                            : Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                          ),
              ),
              if (fieldErrors != null && fieldErrors!['image'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, left: 12.0),
                  child: Text(
                    fieldErrors!['image']!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),

          // Phần chi tiết kích thước
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Chi tiết kích thước',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => onAddSizeDetail(index),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm kích thước'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (fieldErrors != null && fieldErrors!['sizeDetails'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                fieldErrors!['sizeDetails']!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          ...List.generate(
            variant.sizeDetails.length,
            (detailIndex) => _buildSizeDetailItem(
              detailIndex,
              variant.sizeDetails[detailIndex],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectVariantImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // When selecting a new local image, we need to ensure any original network image
        // association is removed to prevent confusion in the view model
        final updatedVariant = ProductVariant(
          color: variant.color,
          sizeDetails: variant.sizeDetails,
          variantImage: File(image.path),
          // Don't pass initialNetworkImage to ensure it's cleared
        );
        onVariantChanged(updatedVariant);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi chọn hình ảnh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
