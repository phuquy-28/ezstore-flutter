import 'package:flutter/material.dart';
import '../../../ui/core/shared/custom_button.dart';
import '../../../ui/core/shared/detail_app_bar.dart';
import '../../../ui/core/shared/detail_text_field.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../view_models/add_category_view_model.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({Key? key}) : super(key: key);

  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  
  File? _selectedImageFile;
  bool _isImageSelected = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AddCategoryViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: DetailAppBar(
            title: 'Thêm danh mục mới',
            onEditToggle: () {},
            isEditMode: false,
            showEditButton: false,
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      if (_isImageSelected) _buildImagePreview(),

                      const SizedBox(height: 24),

                      DetailTextField(
                        controller: _nameController,
                        label: 'Tên danh mục',
                        enabled: true,
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
                        text: 'Thêm danh mục',
                        onPressed: () => _handleSubmit(viewModel),
                      ),
                    ],
                  ),
                ),
        );
      },
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
          _isImageSelected = true;
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

  void _handleSubmit(AddCategoryViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      if (!_isImageSelected || _selectedImageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn hình ảnh cho danh mục'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final success = await viewModel.createCategory(
        _nameController.text,
        _selectedImageFile!,
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
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? 'Thêm danh mục thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
