import 'package:ezstore_flutter/ui/category/view_models/add_category_view_model.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_button.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_app_bar.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_text_field.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddCategoryScreen extends StatefulWidget {
  final AddCategoryViewModel viewModel;

  const AddCategoryScreen({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_viewModelListener);
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DetailAppBar(
        title: 'Thêm danh mục mới',
        onEditToggle: () {},
        isEditMode: false,
        showEditButton: false,
      ),
      body: widget.viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  if (widget.viewModel.isImageSelected) _buildImagePreview(),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DetailTextField(
                        controller: _nameController,
                        label: 'Tên danh mục',
                        enabled: true,
                        hintText: 'Nhập tên danh mục',
                        textColor: Colors.black,
                        fillColor: Colors.white,
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
                  const SizedBox(height: 12),
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
                  if (widget.viewModel.imageErrorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0, left: 12.0),
                      child: Text(
                        widget.viewModel.imageErrorText!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Thêm danh mục',
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _selectedImageFile != null
          ? Image.file(
              _selectedImageFile!,
              fit: BoxFit.contain,
            )
          : _buildImagePlaceholder(),
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

  Future<void> _selectImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _selectedImageFile = File(image.path);
        });

        widget.viewModel.updateImageSelected(true);

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

  void _handleSubmit() async {
    // Reset validation state
    widget.viewModel.resetValidation();

    // Validate and attempt to create category
    final success = await widget.viewModel.createCategory(
      _nameController.text,
      _selectedImageFile,
    );

    if (success) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thêm danh mục thành công'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Trả về true để refresh danh sách
    } else {
      if (!mounted) return;

      // If there's an error message, show it
      if (widget.viewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.viewModel.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
