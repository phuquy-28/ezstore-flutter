import 'package:ezstore_flutter/ui/core/shared/custom_button.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_switch_tile.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_dropdown.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_text_field.dart';
import 'package:ezstore_flutter/ui/core/shared/multi_image_picker.dart';
import 'package:ezstore_flutter/ui/product/view_models/edit_product_view_model.dart';
import 'package:ezstore_flutter/ui/product/view_models/add_product_view_model.dart'
    as add_product_model;
import 'package:ezstore_flutter/ui/product/widgets/product_variant_item.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class EditProductScreen extends StatefulWidget {
  final int productId;
  final EditProductViewModel viewModel;

  const EditProductScreen({
    Key? key,
    required this.productId,
    required this.viewModel,
  }) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _selectedCategory = '';
  bool _isFeatured = false;
  List<File> _selectedImages = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize the viewModel and load product data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (mounted) {
          // Reset state and load product
          widget.viewModel.resetState();
          widget.viewModel.loadProduct(widget.productId);

          // Load categories list
          widget.viewModel.loadCategories();

          // Add listener to the view model
          widget.viewModel.addListener(_viewModelListener);
        }
      } catch (e) {
        print('Error initializing view model state: $e');
      }
    });
  }

  void _viewModelListener() {
    if (mounted) {
      if (!widget.viewModel.isLoading &&
          widget.viewModel.productId != null &&
          !_initialized) {
        _updateControllers(widget.viewModel);
        setState(() {
          _initialized = true;
        });
      }
      // Force UI to update whenever viewModel changes
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.viewModel.productId != null &&
        !_initialized &&
        !widget.viewModel.isLoading) {
      _updateControllers(widget.viewModel);
      _initialized = true;
    }
  }

  void _updateControllers(EditProductViewModel viewModel) {
    // Cập nhật Controllers mà không dùng setState
    if (_nameController.text.isEmpty && viewModel.name.isNotEmpty) {
      _nameController.text = viewModel.name;
    }

    if (_descriptionController.text.isEmpty &&
        viewModel.description.isNotEmpty) {
      _descriptionController.text = viewModel.description;
    }

    if (_priceController.text.isEmpty && viewModel.price > 0) {
      _priceController.text = viewModel.price.toString();
    }

    // Cập nhật các biến state khác mà không gây ra setState trong quá trình build
    _selectedCategory = viewModel.categoryName.isNotEmpty
        ? viewModel.categoryName
        : _selectedCategory;
    _isFeatured = viewModel.featured;
  }

  @override
  void dispose() {
    // First dispose the controllers
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();

    // Remove listener from view model
    widget.viewModel.removeListener(_viewModelListener);

    // Then reset the view model state when leaving the screen
    try {
      widget.viewModel.resetState();
    } catch (e) {
      print('Error resetting view model state: $e');
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    // Theo dõi trạng thái sản phẩm đã được tải và cập nhật các controller nếu cần
    if (viewModel.productId != null && !_initialized && !viewModel.isLoading) {
      // Sử dụng Future.microtask để đảm bảo rằng chúng ta không cập nhật state trong quá trình build
      Future.microtask(() {
        if (mounted) {
          setState(() {
            _updateControllers(viewModel);
            _initialized = true;
          });
        }
      });
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              'Chỉnh sửa sản phẩm',
              style: const TextStyle(color: Colors.black, fontSize: 18),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: viewModel.isLoading && viewModel.productId == null
              ? const Center(child: CircularProgressIndicator())
              : Form(
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
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.black),
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
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.0),
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
                                          ? (viewModel.categories.isNotEmpty &&
                                                  viewModel.categories.first
                                                          .name !=
                                                      null
                                              ? viewModel.categories.first.name!
                                              : '')
                                          : _selectedCategory,
                                      items: viewModel.categories
                                          .map(
                                              (category) => category.name ?? '')
                                          .where((name) => name.isNotEmpty)
                                          .toList()
                                          .cast<String>(),
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
                          const SizedBox(height: 8),
                          MultiImagePicker(
                            selectedImages: _selectedImages,
                            initialNetworkImages:
                                viewModel.originalProductImages,
                            onImagesSelected: (images) {
                              setState(() {
                                _selectedImages = images;
                              });
                              viewModel.updateProductImages(images);
                            },
                            onNetworkImagesRemoved: (remainingImages) {
                              viewModel
                                  .updateOriginalProductImages(remainingImages);
                            },
                            onReplaceNetworkImage: (index, newImage) {
                              viewModel.replaceProductImage(index, newImage);
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

                        // Create a compatible ProductVariant for the widget
                        final widgetVariant = add_product_model.ProductVariant(
                          color: variant.color,
                          sizeDetails: variant.sizeDetails
                              .map((detail) => add_product_model.VariantDetail(
                                  size: detail.size,
                                  quantity: detail.quantity,
                                  priceDifference: detail.priceDifference))
                              .toList(),
                          variantImage: variant.variantImage,
                        );

                        return ProductVariantItem(
                          variant: widgetVariant,
                          index: index,
                          initialNetworkImage: variant.originalImageUrl,
                          onDelete: () => viewModel.removeVariant(index),
                          onVariantChanged: (updatedVariant) {
                            // Xử lý trường hợp cập nhật hoặc xóa hình ảnh biến thể
                            String? newOriginalImageUrl =
                                variant.originalImageUrl;

                            // Nếu đã chọn hình ảnh mới, đặt originalImageUrl = null
                            // để đánh dấu rằng hình ảnh cũ sẽ bị thay thế
                            if (updatedVariant.variantImage != null) {
                              newOriginalImageUrl = null;
                            }

                            // Create variant details, preserving existing IDs
                            List<VariantDetail> updatedDetails = [];

                            // Map each size detail, preserving original IDs where possible
                            // This ensures existing variant records are updated rather than creating new ones
                            for (final newDetail
                                in updatedVariant.sizeDetails) {
                              // Try to find the matching original detail by size
                              int? originalId;
                              for (final origDetail in variant.sizeDetails) {
                                if (origDetail.size == newDetail.size) {
                                  originalId = origDetail.id;
                                  break;
                                }
                              }

                              updatedDetails.add(VariantDetail(
                                id: originalId, // Preserve ID if found
                                size: newDetail.size,
                                quantity: newDetail.quantity,
                                priceDifference: newDetail.priceDifference,
                              ));
                            }

                            viewModel.updateVariant(
                              index,
                              ProductVariant(
                                color: updatedVariant.color,
                                sizeDetails: updatedDetails,
                                variantImage: updatedVariant.variantImage,
                                originalImageUrl: newOriginalImageUrl,
                              ),
                            );
                          },
                          onAddSizeDetail: (variantIndex) {
                            viewModel.addSizeDetail(variantIndex);
                          },
                          onRemoveSizeDetail: (variantIndex, detailIndex) {
                            viewModel.removeSizeDetail(
                                variantIndex, detailIndex);
                          },
                          requireVariantImage: true,
                          shouldValidate: viewModel.shouldValidateVariants,
                          fieldErrors: viewModel.variantErrors[index],
                          detailErrors: viewModel.variantDetailErrors[index],
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
                            border: Border.all(color: Colors.black!),
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

                      // Nút lưu với trạng thái disabled nếu không có thay đổi
                      CustomButton(
                        text: 'Lưu thay đổi',
                        onPressed: viewModel.hasChanges
                            ? () => _handleSubmit(viewModel)
                            : null,
                        isLoading: false,
                      ),
                    ],
                  ),
                ),
        ),
        // Show loading overlay when isLoading is true during save operation
        if (viewModel.isLoading && viewModel.productId != null)
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

  void _handleSubmit(EditProductViewModel viewModel) async {
    // Reset validation state
    viewModel.resetValidation();

    // Update all values in the view model
    viewModel.updateName(_nameController.text);
    viewModel.updateDescription(_descriptionController.text);
    viewModel.updatePrice(_priceController.text);
    viewModel.updateCategory(_selectedCategory);
    viewModel.updateFeatured(_isFeatured);

    // Đảm bảo cập nhật danh sách hình ảnh mới được chọn
    viewModel.updateProductImages(_selectedImages);

    // Kiểm tra danh sách ảnh sản phẩm
    if (viewModel.originalProductImages.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng tải lên ít nhất một hình ảnh sản phẩm'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Kiểm tra xem biến thể có hình ảnh không
    bool hasVariantMissingImage = false;
    for (var variant in viewModel.variants) {
      if (variant.variantImage == null && variant.originalImageUrl == null) {
        hasVariantMissingImage = true;
        break;
      }
    }

    if (hasVariantMissingImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Vui lòng tải lên hình ảnh cho tất cả các biến thể màu sắc'),
          backgroundColor: Colors.red,
        ),
      );
      // Cuộn đến phần biến thể để người dùng dễ dàng nhìn thấy lỗi
      _scrollController.animateTo(
        600, // Vị trí ước lượng của phần biến thể
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    // Kiểm tra trùng lặp kích thước cho cùng một màu sắc
    final Map<String, Set<String>> colorSizesMap = {};
    bool hasDuplicateSizes = false;
    String? colorWithDuplicate;
    String? duplicateSize;

    // Kiểm tra tất cả các biến thể để tìm kích thước trùng lặp
    for (final variant in viewModel.variants) {
      final color = variant.color;

      if (!colorSizesMap.containsKey(color)) {
        colorSizesMap[color] = {};
      }

      for (final detail in variant.sizeDetails) {
        if (colorSizesMap[color]!.contains(detail.size)) {
          hasDuplicateSizes = true;
          colorWithDuplicate = color;
          duplicateSize = detail.size;
          break;
        }
        colorSizesMap[color]!.add(detail.size);
      }

      if (hasDuplicateSizes) {
        break;
      }
    }

    if (hasDuplicateSizes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Kích thước $duplicateSize đã được sử dụng cho màu $colorWithDuplicate. '
              'Vui lòng sửa trước khi lưu sản phẩm.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      // Trigger variant validation to show errors in UI
      viewModel.validateAllVariants();
      // Scroll to variants section
      _scrollController.animateTo(
        600,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    // Validate all fields
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
      } else if (viewModel.variantErrors.isNotEmpty) {
        // Scroll đến khu vực biến thể nếu có lỗi ở đó
        _scrollController.animateTo(600,
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

    // All validation passed, attempt to update product
    final success = await viewModel.updateProduct();

    if (success) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật sản phẩm thành công'),
          backgroundColor: Colors.green,
        ),
      );

      // Return to previous screen (detail screen)
      Navigator.pop(context, true); // Return true to refresh the product detail
    } else {
      if (!mounted) return;

      // Show a detailed error message
      final errorMessage = viewModel.errorMessage ??
          'Cập nhật sản phẩm thất bại. Vui lòng kiểm tra lại thông tin.';
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
