import 'package:flutter/material.dart';
import '../../../ui/core/shared/custom_button.dart';
import '../../../ui/core/shared/detail_app_bar.dart';
import '../../../ui/core/shared/detail_text_field.dart';
import '../../../domain/models/category/category.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../view_models/category_detail_view_model.dart';
import '../../../data/models/category/req_category.dart';

class CategoryDetailScreen extends StatefulWidget {
  final bool isEditMode;
  final int categoryId;

  const CategoryDetailScreen({
    Key? key,
    this.isEditMode = false,
    required this.categoryId,
  }) : super(key: key);

  @override
  _CategoryDetailScreenState createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late bool isEditMode;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  String? _selectedImageUrl;
  bool _isImageChanged = false;
  dynamic _selectedImageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    isEditMode = widget.isEditMode;
    Future.microtask(() {
      _loadCategoryData();
    });
  }

  Future<void> _loadCategoryData() async {
    if (!mounted) return;

    await Provider.of<CategoryDetailViewModel>(context, listen: false)
        .getCategoryById(widget.categoryId);

    if (!mounted) return;

    final category =
        Provider.of<CategoryDetailViewModel>(context, listen: false).category;
    if (category != null) {
      _updateFormWithCategoryData(category);
    }
  }

  void _updateFormWithCategoryData(Category category) {
    _nameController.text = category.name ?? '';
    _imageUrlController.text = category.imageUrl ?? '';
    _selectedImageUrl = category.imageUrl;
    _isImageChanged = false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryDetailViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading || _isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.errorMessage != null) {
          return Scaffold(
            appBar: DetailAppBar(
              title: 'Chi tiết danh mục',
              isEditMode: false,
              onEditToggle: () {},
            ),
            body: _buildErrorView(viewModel.errorMessage!),
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
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Hiển thị hình ảnh với tỉ lệ đúng
                if (_selectedImageUrl != null && _selectedImageUrl!.isNotEmpty)
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
                  ),
                ],
              ],
            ),
          ),
        );
      },
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
              _selectedImageFile as File,
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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã chọn hình ảnh mới'),
            backgroundColor: Colors.green,
          ),
        );
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

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Lấy thông tin danh mục hiện tại
      final category =
          Provider.of<CategoryDetailViewModel>(context, listen: false).category;
      if (category == null) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy thông tin danh mục'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Tạo đối tượng ReqCategory để cập nhật
      final reqCategory = ReqCategory(
        id: category.id,
        name: _nameController.text,
        // Giữ nguyên đường dẫn hình ảnh nếu không có hình ảnh mới
        imageUrl: _isImageChanged
            ? (_selectedImageFile as File).path
            : category.imageUrl, // Giữ nguyên đường dẫn hình ảnh cũ
      );

      // Gọi phương thức updateCategory từ ViewModel
      Provider.of<CategoryDetailViewModel>(context, listen: false)
          .updateCategory(
              reqCategory, _isImageChanged ? _selectedImageFile as File : null)
          .then((success) {
        setState(() {
          _isLoading = false;
          if (success) {
            // Chuyển về chế độ xem thay vì quay lại màn hình trước
            isEditMode = false;
            _isImageChanged = false;
            _selectedImageFile = null;

            // Tải lại dữ liệu danh mục để hiển thị thông tin mới nhất
            _loadCategoryData();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cập nhật thành công'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    Provider.of<CategoryDetailViewModel>(context, listen: false)
                            .errorMessage ??
                        'Cập nhật thất bại'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      });
    }
  }
}
