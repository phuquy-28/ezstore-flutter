import 'package:ezstore_flutter/ui/core/shared/custom_button.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_switch_tile.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_app_bar.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_dropdown.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_text_field.dart';
import 'package:ezstore_flutter/ui/core/shared/multi_image_picker.dart';
import 'package:ezstore_flutter/ui/product/view_models/add_product_view_model.dart';
import 'package:ezstore_flutter/ui/product/widgets/product_variant_item.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class AddProductScreen extends StatefulWidget {
  final AddProductViewModel viewModel;

  const AddProductScreen({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _selectedCategory = '';
  bool _isFeatured = false;
  List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_viewModelListener);

    // Start with one default variant and reset any previous state
    widget.viewModel.resetState();

    // Tải danh sách danh mục
    widget.viewModel.loadCategories();
  }

  @override
  void dispose() {
    // First dispose the controllers
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();

    // Remove listener
    widget.viewModel.removeListener(_viewModelListener);

    // Reset the view model state when leaving the screen
    widget.viewModel.resetState();

    super.dispose();
  }

  void _viewModelListener() {
    if (mounted) {
      setState(() {
        // Update UI when viewModel changes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: DetailAppBar(
            title: 'Thêm sản phẩm mới',
            onEditToggle: () {},
            isEditMode: false,
            showEditButton: false,
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              children: [
                // 1. Tên sản phẩm
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailTextField(
                      controller: _nameController,
                      label: 'Tên sản phẩm',
                      enabled: true,
                      hintText: 'Nhập tên sản phẩm',
                      textColor: Colors.black,
                      fillColor: Colors.white,
                      onChanged: (value) {
                        widget.viewModel.updateName(value);
                      },
                    ),
                    if (widget.viewModel.nameErrorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0, left: 12.0),
                        child: Text(
                          widget.viewModel.nameErrorText!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
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
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Nhập mô tả chi tiết về sản phẩm',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                      ),
                      onChanged: (value) {
                        widget.viewModel.updateDescription(value);
                      },
                    ),
                    if (widget.viewModel.descriptionErrorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0, left: 12.0),
                        child: Text(
                          widget.viewModel.descriptionErrorText!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
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
                    DetailTextField(
                      controller: _priceController,
                      label: 'Giá sản phẩm',
                      enabled: true,
                      hintText: 'Nhập giá sản phẩm',
                      textColor: Colors.black,
                      fillColor: Colors.white,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        widget.viewModel.updatePrice(value);
                      },
                    ),
                    if (widget.viewModel.priceErrorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0, left: 12.0),
                        child: Text(
                          widget.viewModel.priceErrorText!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
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
                    widget.viewModel.isLoadingCategories
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : widget.viewModel.categories.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Không có danh mục nào',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : DetailDropdown(
                                value: _selectedCategory.isEmpty
                                    ? (widget.viewModel.categories.isNotEmpty
                                        ? widget.viewModel.categories.first
                                                .name ??
                                            ''
                                        : '')
                                    : _selectedCategory,
                                items: widget.viewModel.categories
                                    .map((category) => category.name ?? '')
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedCategory = value;
                                    });
                                    widget.viewModel.updateCategory(value);
                                  }
                                },
                              ),
                    if (widget.viewModel.categoryErrorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0, left: 12.0),
                        child: Text(
                          widget.viewModel.categoryErrorText!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // 5. Nổi bật toggle
                CustomSwitchTile(
                  title: 'Nổi bật',
                  subtitle: 'Sản phẩm sẽ được hiển thị nổi bật trên ứng dụng',
                  value: _isFeatured,
                  onChanged: (value) {
                    setState(() {
                      _isFeatured = value;
                    });
                    widget.viewModel.updateFeatured(value);
                  },
                ),

                const SizedBox(height: 24),

                // 6. Hình ảnh sản phẩm
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MultiImagePicker(
                      selectedImages: _selectedImages,
                      onImagesSelected: (images) {
                        setState(() {
                          _selectedImages = images;
                        });
                        widget.viewModel.updateProductImages(images);
                      },
                    ),
                    if (widget.viewModel.imagesErrorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0, left: 12.0),
                        child: Text(
                          widget.viewModel.imagesErrorText!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
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

                // Variants list
                ...widget.viewModel.variants.asMap().entries.map((entry) {
                  final index = entry.key;
                  final variant = entry.value;

                  return ProductVariantItem(
                    variant: variant,
                    index: index,
                    onDelete: () => widget.viewModel.removeVariant(index),
                    onVariantChanged: (updatedVariant) {
                      widget.viewModel.updateVariant(index, updatedVariant);
                    },
                    onAddSizeDetail: (variantIndex) {
                      widget.viewModel.addSizeDetail(variantIndex);
                    },
                    onRemoveSizeDetail: (variantIndex, detailIndex) {
                      widget.viewModel
                          .removeSizeDetail(variantIndex, detailIndex);
                    },
                    requireVariantImage: true,
                    shouldValidate: widget.viewModel.shouldValidateVariants,
                    fieldErrors: widget.viewModel.variantErrors[index],
                    detailErrors: widget.viewModel.variantDetailErrors[index],
                  );
                }).toList(),

                // Nút thêm biến thể ở dưới
                InkWell(
                  onTap: () => widget.viewModel.addVariant(),
                  borderRadius: BorderRadius.circular(8),
                  splashColor: Colors.grey[300],
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: Colors.black,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Thêm biến thể mới',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                CustomButton(
                  text: 'Thêm sản phẩm',
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
        // Show loading overlay when isLoading is true
        if (widget.viewModel.isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _handleSubmit() async {
    // Reset validation state
    widget.viewModel.resetValidation();

    // Update all values in the view model
    widget.viewModel.updateName(_nameController.text);
    widget.viewModel.updateDescription(_descriptionController.text);
    widget.viewModel.updatePrice(_priceController.text);
    widget.viewModel.updateCategory(_selectedCategory);
    widget.viewModel.updateFeatured(_isFeatured);
    widget.viewModel.updateProductImages(_selectedImages);

    // Check if there are validation errors
    bool hasErrors = widget.viewModel.nameErrorText != null ||
        widget.viewModel.descriptionErrorText != null ||
        widget.viewModel.priceErrorText != null ||
        widget.viewModel.imagesErrorText != null ||
        widget.viewModel.categoryErrorText != null ||
        widget.viewModel.variantErrors.isNotEmpty;

    if (hasErrors) {
      // Scroll to the first error field
      if (widget.viewModel.nameErrorText != null) {
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      } else if (widget.viewModel.descriptionErrorText != null) {
        _scrollController.animateTo(100,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      } else if (widget.viewModel.imagesErrorText != null) {
        _scrollController.animateTo(400,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin sản phẩm'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // All validation passed, attempt to create product
    final success = await widget.viewModel.createProduct();

    if (success) {
      if (!mounted) return;

      // Reset the view model state after successful creation
      widget.viewModel.resetState();

      // Clear form fields
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      setState(() {
        _selectedImages = [];
        _isFeatured = false;
        _selectedCategory = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thêm sản phẩm thành công'),
          backgroundColor: Colors.green,
        ),
      );

      // Return to previous screen
      Navigator.pop(context, true); // Return true to refresh the list
    } else {
      if (!mounted) return;

      // Show a detailed error message
      final errorMessage = widget.viewModel.errorMessage ??
          'Thêm sản phẩm thất bại. Vui lòng kiểm tra lại thông tin.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Đóng',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }
}
