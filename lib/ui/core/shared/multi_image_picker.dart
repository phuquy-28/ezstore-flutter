import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MultiImagePicker extends StatefulWidget {
  final List<File> selectedImages;
  final List<String>? initialNetworkImages;
  final Function(List<File>) onImagesSelected;
  final Function(List<String>)? onNetworkImagesRemoved;
  final Function(int, File)? onReplaceNetworkImage;

  const MultiImagePicker({
    Key? key,
    required this.selectedImages,
    this.initialNetworkImages,
    required this.onImagesSelected,
    this.onNetworkImagesRemoved,
    this.onReplaceNetworkImage,
  }) : super(key: key);

  @override
  _MultiImagePickerState createState() => _MultiImagePickerState();
}

class _MultiImagePickerState extends State<MultiImagePicker> {
  List<String> _remainingNetworkImages = [];

  @override
  void initState() {
    super.initState();
    _remainingNetworkImages = widget.initialNetworkImages?.toList() ?? [];
  }

  @override
  void didUpdateWidget(MultiImagePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialNetworkImages != oldWidget.initialNetworkImages) {
      _remainingNetworkImages = widget.initialNetworkImages?.toList() ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasImages =
        widget.selectedImages.isNotEmpty || _remainingNetworkImages.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hình ảnh',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              if (!hasImages)
                Container(
                  height: 200,
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, color: Colors.grey[400], size: 48),
                        const SizedBox(height: 8),
                        Text(
                          'Chưa có hình ảnh nào được chọn',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: _remainingNetworkImages.length +
                      widget.selectedImages.length,
                  itemBuilder: (context, index) {
                    // First show network images, then local images
                    if (index < _remainingNetworkImages.length) {
                      return _buildNetworkImageItem(index);
                    } else {
                      final localIndex = index - _remainingNetworkImages.length;
                      return _buildLocalImageItem(localIndex);
                    }
                  },
                ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton(
                  onPressed: _selectImages,
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
                        Icon(Icons.add_photo_alternate, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'Thêm hình ảnh',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocalImageItem(int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(widget.selectedImages[index]),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => _removeLocalImage(index),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
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
                size: 16,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkImageItem(int networkIndex) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: CachedNetworkImage(
              imageUrl: _remainingNetworkImages[networkIndex],
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.grey[400]),
              ),
              errorWidget: (context, url, error) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[300], size: 24),
                    const SizedBox(height: 4),
                    Text(
                      'Lỗi tải ảnh',
                      style: TextStyle(fontSize: 10, color: Colors.red[300]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              memCacheHeight: 300,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => _removeNetworkImage(networkIndex),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
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
                size: 16,
                color: Colors.red,
              ),
            ),
          ),
        ),
        if (widget.onReplaceNetworkImage != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _replaceNetworkImage(networkIndex),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit,
                  size: 14,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _selectImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        // Add new images to the end of the list
        final List<File> files = [...widget.selectedImages];
        for (var image in images) {
          files.add(File(image.path));
        }

        widget.onImagesSelected(files);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã chọn ${images.length} hình ảnh mới'),
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

  void _removeLocalImage(int index) {
    final List<File> files = [...widget.selectedImages];
    files.removeAt(index);
    widget.onImagesSelected(files);
  }

  void _removeNetworkImage(int networkIndex) {
    // Get the URL being removed for potential logging
    // final String removedUrl = _remainingNetworkImages[networkIndex];

    setState(() {
      _remainingNetworkImages.removeAt(networkIndex);
    });

    if (widget.onNetworkImagesRemoved != null) {
      // Always notify the parent about the update
      widget.onNetworkImagesRemoved!(_remainingNetworkImages);
    }
  }

  Future<void> _replaceNetworkImage(int networkIndex) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null && widget.onReplaceNetworkImage != null) {
        final File imageFile = File(image.path);

        // Call the parent's replace method
        widget.onReplaceNetworkImage!(networkIndex, imageFile);

        // Update UI by removing the network image
        setState(() {
          // final String removedUrl = _remainingNetworkImages[networkIndex];
          _remainingNetworkImages.removeAt(networkIndex);
        });

        // Notify parent about network image removal
        if (widget.onNetworkImagesRemoved != null) {
          widget.onNetworkImagesRemoved!(_remainingNetworkImages);
        }

        // Add the new local image to the selected images list (at the end)
        final List<File> updatedImages = [...widget.selectedImages, imageFile];
        widget.onImagesSelected(updatedImages);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thay thế hình ảnh'),
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
}
