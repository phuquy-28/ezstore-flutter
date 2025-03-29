import 'package:ezstore_flutter/domain/models/category/category.dart';
import 'package:ezstore_flutter/ui/category/view_models/category_detail_view_model.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_button.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_app_bar.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_text_field.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CategoryDetailScreen extends StatefulWidget {
  final bool isEditMode;
  final int categoryId;
  final CategoryDetailViewModel viewModel;

  const CategoryDetailScreen({
    Key? key,
    this.isEditMode = false,
    required this.categoryId,
    required this.viewModel,
  }) : super(key: key);

  @override
  _CategoryDetailScreenState createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late bool isEditMode;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  String? _selectedImageUrl;
  bool _isImageChanged = false;
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    isEditMode = widget.isEditMode;
    widget.viewModel.addListener(_viewModelListener);

    // Tải dữ liệu danh mục nếu có categoryId
    Future.microtask(() => _loadCategoryData());
  }

  @override
  void dispose() {
    _nameController.dispose();
    widget.viewModel.removeListener(_viewModelListener);
    super.dispose();
  }

  void _viewModelListener() {
    if (mounted) {
      setState(() {
        // Update UI when viewModel changes
        if (widget.viewModel.category != null && !widget.viewModel.isLoading) {
          _updateFormWithCategoryData(widget.viewModel.category!);
        }
      });
    }
  }

  Future<void> _loadCategoryData() async {
    try {
      await widget.viewModel.getCategoryById(widget.categoryId);
    } catch (e) {
      if (mounted) {
        widget.viewModel.showErrorMessage(context, e.toString());
      }
    }
  }

  void _updateFormWithCategoryData(Category category) {
    _nameController.text = category.name ?? '';
    _selectedImageUrl = category.imageUrl;
    _isImageChanged = false;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        widget.viewModel.isLoading || widget.viewModel.isSubmitting;

    if (isLoading && widget.viewModel.category == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.viewModel.errorMessage != null &&
        widget.viewModel.category == null) {
      return Scaffold(
        appBar: DetailAppBar(
          title: 'Chi tiết danh mục',
          isEditMode: false,
          onEditToggle: () {},
        ),
        body: _buildErrorView(widget.viewModel.errorMessage!),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DetailAppBar(
        title: isEditMode ? 'Chỉnh sửa danh mục' : 'Chi tiết danh mục',
        onEditToggle: () {
          setState(() {
            isEditMode = !isEditMode;
          });
        },
        isEditMode: isEditMode,
      ),
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Hiển thị hình ảnh với tỉ lệ đúng
                if (_selectedImageUrl != null &&
                        _selectedImageUrl!.isNotEmpty ||
                    _isImageChanged)
                  _buildImagePreview(),

                const SizedBox(height: 24),

                DetailTextField(
                  controller: _nameController,
                  label: 'Tên danh mục',
                  enabled: isEditMode,
                  hintText: 'Nhập tên danh mục',
                  textColor: Colors.black,
                  fillColor: Colors.white,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên danh mục';
                    }
                    return null;
                  },
                ),

                if (isEditMode) ...[
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: _selectImage,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, color: Colors.black),
                          SizedBox(width: 8),
                          Text(
                            'Chọn hình ảnh',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Cập nhật',
                    onPressed: _handleSubmit,
                    isLoading: widget.viewModel.isSubmitting,
                  ),
                ],
              ],
            ),
            if (widget.viewModel.isSubmitting)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget mới để hiển thị hình ảnh với tỉ lệ đúng
  Widget _buildImagePreview() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _isImageChanged && _selectedImageFile != null
          ? Image.file(
              _selectedImageFile!,
              fit: BoxFit.contain,
            )
          : _selectedImageUrl != null && _selectedImageUrl!.isNotEmpty
              ? Image.network(
                  _selectedImageUrl!,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImageErrorWidget();
                  },
                )
              : _buildImagePlaceholder(),
    );
  }

  Widget _buildImageErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text(
            'Không thể tải hình ảnh',
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, color: Colors.grey[400], size: 48),
          const SizedBox(height: 8),
          Text(
            'Chưa có hình ảnh',
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
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
            onPressed: _loadCategoryData,
            child: const Text("Thử lại"),
          ),
        ],
      ),
    );
  }

  Future<void> _selectImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _selectedImageFile = File(image.path);
          _selectedImageUrl = image.path;
          _isImageChanged = true;
        });

        widget.viewModel.showSuccessMessage(context, 'Đã chọn hình ảnh mới');
      }
    } catch (e) {
      widget.viewModel.showErrorMessage(context, 'Lỗi khi chọn hình ảnh: $e');
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.viewModel
          .updateCategory(
        _nameController.text,
        imageFile: _isImageChanged ? _selectedImageFile : null,
        currentImageUrl: !_isImageChanged ? _selectedImageUrl : null,
      )
          .then((success) {
        if (success) {
          // Chuyển về chế độ xem thay vì quay lại màn hình trước
          setState(() {
            isEditMode = false;
            _isImageChanged = false;
          });

          widget.viewModel.showSuccessMessage(context, 'Cập nhật thành công');
        } else {
          widget.viewModel.showErrorMessage(
              context, widget.viewModel.errorMessage ?? 'Cập nhật thất bại');
        }
      });
    }
  }
}
