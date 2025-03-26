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
import 'package:provider/provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

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

    // Initialize the viewModel with an initial variant
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (mounted) {
          final viewModel =
              Provider.of<AddProductViewModel>(context, listen: false);
          // Start with one default variant and reset any previous state
          viewModel.resetState();

          // Tải danh sách danh mục
          viewModel.loadCategories();
        }
      } catch (e) {
        print('Error initializing view model state: $e');
      }
    });
  }

  @override
  void dispose() {
    // First dispose the controllers
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();

    // Then reset the view model state when leaving the screen
    // Use a try-catch to prevent errors if context is no longer valid
    try {
      if (mounted) {
        final viewModel =
            Provider.of<AddProductViewModel>(context, listen: false);
        viewModel.resetState();
      }
    } catch (e) {
      print('Error resetting view model state: $e');
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddProductViewModel>(
      builder: (context, viewModel, child) {
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
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Vui lòng nhập tên sản phẩm';
                          //   }
                          //   if (value.length < 3) {
                          //     return 'Tên sản phẩm quá ngắn (tối thiểu 3 ký tự)';
                          //   }
                          //   if (value.length > 100) {
                          //     return 'Tên sản phẩm quá dài (tối đa 100 ký tự)';
                          //   }
                          //   return null;
                          // },
                          onChanged: (value) {
                            viewModel.updateName(value);
                          },
                        ),
                        if (viewModel.nameErrorText != null)
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 6.0, left: 12.0),
                            child: Text(
                              viewModel.nameErrorText!,
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
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Vui lòng nhập mô tả sản phẩm';
                          //   }
                          //   if (value.length < 10) {
                          //     return 'Mô tả sản phẩm quá ngắn (tối thiểu 10 ký tự)';
                          //   }
                          //   if (value.length > 1000) {
                          //     return 'Mô tả sản phẩm quá dài (tối đa 1000 ký tự)';
                          //   }
                          //   return null;
                          // },
                          onChanged: (value) {
                            viewModel.updateDescription(value);
                          },
                        ),
                        if (viewModel.descriptionErrorText != null)
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 6.0, left: 12.0),
                            child: Text(
                              viewModel.descriptionErrorText!,
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
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Vui lòng nhập giá sản phẩm';
                          //   }

                          //   final price = double.tryParse(value);
                          //   if (price == null) {
                          //     return 'Giá sản phẩm phải là số';
                          //   }

                          //   if (price <= 0) {
                          //     return 'Giá sản phẩm phải lớn hơn 0';
                          //   }

                          //   if (price > 1000000000) {
                          //     return 'Giá sản phẩm quá cao';
                          //   }

                          //   return null;
                          // },
                          onChanged: (value) {
                            viewModel.updatePrice(value);
                          },
                        ),
                        if (viewModel.priceErrorText != null)
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 6.0, left: 12.0),
                            child: Text(
                              viewModel.priceErrorText!,
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
                        viewModel.isLoadingCategories
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : viewModel.categories.isEmpty
                                ? const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.0),
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
                                        ? (viewModel.categories.isNotEmpty
                                            ? viewModel.categories.first.name ??
                                                ''
                                            : '')
                                        : _selectedCategory,
                                    items: viewModel.categories
                                        .map((category) => category.name ?? '')
                                        .toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _selectedCategory = value;
                                        });
                                        viewModel.updateCategory(value);
                                      }
                                    },
                                  ),
                        if (viewModel.categoryErrorText != null)
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 6.0, left: 12.0),
                            child: Text(
                              viewModel.categoryErrorText!,
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
                      subtitle:
                          'Sản phẩm sẽ được hiển thị nổi bật trên ứng dụng',
                      value: _isFeatured,
                      onChanged: (value) {
                        setState(() {
                          _isFeatured = value;
                        });
                        viewModel.updateFeatured(value);
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
                            viewModel.updateProductImages(images);
                          },
                        ),
                        if (viewModel.imagesErrorText != null)
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 6.0, left: 12.0),
                            child: Text(
                              viewModel.imagesErrorText!,
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
                    ...viewModel.variants.asMap().entries.map((entry) {
                      final index = entry.key;
                      final variant = entry.value;

                      return ProductVariantItem(
                        variant: variant,
                        index: index,
                        onDelete: () => viewModel.removeVariant(index),
                        onVariantChanged: (updatedVariant) {
                          viewModel.updateVariant(index, updatedVariant);
                        },
                        onAddSizeDetail: (variantIndex) {
                          viewModel.addSizeDetail(variantIndex);
                        },
                        onRemoveSizeDetail: (variantIndex, detailIndex) {
                          viewModel.removeSizeDetail(variantIndex, detailIndex);
                        },
                        requireVariantImage: true,
                        shouldValidate: viewModel.shouldValidateVariants,
                        fieldErrors: viewModel.variantErrors[index],
                        detailErrors: viewModel.variantDetailErrors[index],
                      );
                    }).toList(),

                    const SizedBox(height: 16),

                    // Nút thêm biến thể ở dưới
                    InkWell(
                      onTap: () => viewModel.addVariant(),
                      borderRadius: BorderRadius.circular(8),
                      splashColor: Colors.grey[300],
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Thêm biến thể mới',
                              style: TextStyle(
                                color: Colors.white,
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
                      onPressed: () => _handleSubmit(viewModel),
                    ),
                  ],
                ),
              ),
            ),
            // Show loading overlay when isLoading is true
            if (viewModel.isLoading)
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
      },
    );
  }

  void _handleSubmit(AddProductViewModel viewModel) async {
    // Reset validation state
    viewModel.resetValidation();

    // Update all values in the view model
    viewModel.updateName(_nameController.text);
    viewModel.updateDescription(_descriptionController.text);
    viewModel.updatePrice(_priceController.text);
    viewModel.updateCategory(_selectedCategory);
    viewModel.updateFeatured(_isFeatured);
    viewModel.updateProductImages(_selectedImages);

    // Explicitly validate required fields
    viewModel.validateName();
    viewModel.validateDescription();
    viewModel.validatePrice();
    viewModel.validateProductImages();
    viewModel.validateCategory();
    viewModel.validateAllVariants();

    // Check if there are validation errors
    bool hasErrors = viewModel.nameErrorText != null ||
        viewModel.descriptionErrorText != null ||
        viewModel.priceErrorText != null ||
        viewModel.imagesErrorText != null ||
        viewModel.categoryErrorText != null ||
        viewModel.variantErrors.isNotEmpty;

    if (hasErrors) {
      // Scroll to the first error field
      if (viewModel.nameErrorText != null) {
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      } else if (viewModel.descriptionErrorText != null) {
        _scrollController.animateTo(100,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      } else if (viewModel.imagesErrorText != null) {
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
    final success = await viewModel.createProduct();

    if (success) {
      if (!mounted) return;

      // Reset the view model state after successful creation
      viewModel.resetState();

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
      final errorMessage = viewModel.errorMessage ??
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
