import 'package:ezstore_flutter/data/models/paginated_response.dart';
import 'package:ezstore_flutter/domain/models/product/product_response.dart'
    hide Variants;
import 'package:ezstore_flutter/data/services/product_service.dart';
import 'package:ezstore_flutter/data/services/upload_service.dart';
import 'package:ezstore_flutter/data/models/upload/req_upload_image.dart';
import 'package:ezstore_flutter/data/models/product/req_product.dart';
import 'dart:developer' as dev;
import 'dart:io';

class ProductRepository {
  final ProductService _productService;
  final UploadService _uploadService;

  ProductRepository(this._productService, this._uploadService);

  Future<PaginatedResponse<ProductResponse>?> getAllProducts({
    int page = 0,
    int pageSize = 10,
    String? keyword,
  }) async {
    try {
      final response = await _productService.getAllProducts(
        page: page,
        pageSize: pageSize,
        keyword: keyword,
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi lấy danh sách sản phẩm: $e');
      rethrow;
    }
  }

  // Phương thức riêng để tải lên một hình ảnh
  Future<String?> _uploadImage(File imageFile, String fileName) async {
    try {
      // Tạo tên file với timestamp để tránh trùng lặp
      final originalFileName = imageFile.path.split('/').last;
      final extension = originalFileName.split('.').last;
      final timestampedFileName =
          '${fileName.replaceAll(' ', '-')}-${DateTime.now().millisecondsSinceEpoch}.$extension';

      // Tạo yêu cầu để lấy URL đã ký
      final reqUploadImage = ReqUploadImage(fileName: timestampedFileName);

      // Lấy URL đã ký để tải lên
      final uploadUrlResponse =
          await _uploadService.getUploadImageUrl(reqUploadImage);

      if (uploadUrlResponse.statusCode != 201 ||
          uploadUrlResponse.data == null) {
        throw Exception('Không thể lấy URL để tải lên hình ảnh');
      }

      // Lấy URL đã ký từ phản hồi
      final signedUrl = uploadUrlResponse.data!.signedUrl!;

      // Tải hình ảnh lên Google Storage
      final uploadResult =
          await _uploadService.uploadFileToStorage(imageFile, signedUrl);

      if (uploadResult == null) {
        throw Exception('Không thể tải lên hình ảnh');
      }

      // Trả về URL công khai của hình ảnh
      return uploadResult;
    } catch (e) {
      dev.log('Exception khi tải lên hình ảnh: $e');
      rethrow;
    }
  }

  // Phương thức để tải lên nhiều hình ảnh
  Future<List<String>> _uploadMultipleImages(
      List<File> imageFiles, String baseName) async {
    final List<String> uploadedImageUrls = [];

    for (int i = 0; i < imageFiles.length; i++) {
      try {
        final imageFile = imageFiles[i];
        final fileName = '${baseName}_${i + 1}';
        final imageUrl = await _uploadImage(imageFile, fileName);

        if (imageUrl != null) {
          uploadedImageUrls.add(imageUrl);
        }
      } catch (e) {
        dev.log('Lỗi khi tải lên hình ảnh thứ ${i + 1}: $e');
        // Tiếp tục với hình ảnh tiếp theo thay vì dừng lại hoàn toàn
      }
    }

    return uploadedImageUrls;
  }

  // Phương thức để tạo sản phẩm mới với hình ảnh
  Future<ProductResponse?> createProduct({
    required String name,
    required String description,
    required double price,
    required int categoryId,
    required bool isFeatured,
    required List<File> productImages,
    required List<Map<String, dynamic>> variants,
  }) async {
    try {
      // 1. Tải lên hình ảnh sản phẩm chính
      final List<String> uploadedProductImageUrls = await _uploadMultipleImages(
          productImages, 'product_${name.toLowerCase().replaceAll(' ', '_')}');

      if (uploadedProductImageUrls.isEmpty) {
        throw Exception('Không thể tải lên hình ảnh sản phẩm');
      }

      // 2. Tạo danh sách biến thể với hình ảnh đã tải lên
      final List<Variants> reqVariants = [];

      // Map để lưu trữ URL hình ảnh theo màu
      // Key: Tên màu, Value: List URL hình ảnh
      final Map<String, List<String>> colorImageUrlsMap = {};

      // Tạo một map để nhóm các biến thể theo màu sắc
      final Map<String, List<Map<String, dynamic>>> colorVariantsMap = {};
      for (final variantMap in variants) {
        final String color = variantMap['color'] as String;
        if (!colorVariantsMap.containsKey(color)) {
          colorVariantsMap[color] = [];
        }
        colorVariantsMap[color]!.add(variantMap);
      }

      // Đầu tiên, tải lên hình ảnh cho mỗi màu sắc (chỉ một lần)
      for (final color in colorVariantsMap.keys) {
        // Chỉ lấy biến thể đầu tiên của mỗi màu để lấy hình ảnh
        final firstVariantWithColor = colorVariantsMap[color]!.first;
        final File? variantImage =
            firstVariantWithColor['variantImage'] as File?;

        if (variantImage != null) {
          final String variantBaseName =
              'product_${name.toLowerCase().replaceAll(' ', '_')}_${color.toLowerCase()}';
          final imageUrl = await _uploadImage(variantImage, variantBaseName);

          if (imageUrl != null) {
            colorImageUrlsMap[color] = [imageUrl];
          } else {
            colorImageUrlsMap[color] = [];
          }
        }
      }

      // Sau đó, tạo các đối tượng biến thể và sử dụng URL hình ảnh đã tải lên theo màu
      for (final variantMap in variants) {
        final String color = variantMap['color'] as String;
        final String size = variantMap['size'] as String;
        final int quantity = variantMap['quantity'] as int;
        final double priceDifference = variantMap['priceDifference'] as double;

        // Lấy URL hình ảnh đã tải lên cho màu này
        final List<String> variantImageUrls = colorImageUrlsMap[color] ?? [];

        // Tạo đối tượng biến thể
        final newVariant = Variants(
          color: color,
          size: size,
          quantity: quantity,
          differencePrice: priceDifference,
          images: variantImageUrls,
        );

        reqVariants.add(newVariant);
      }

      // 3. Tạo đối tượng ReqProduct
      final reqProduct = ReqProduct(
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        isFeatured: isFeatured,
        images: uploadedProductImageUrls,
        variants: reqVariants,
      );

      // 4. Gọi API để tạo sản phẩm
      final response = await _productService.createProduct(reqProduct);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi tạo sản phẩm: $e');
      rethrow;
    }
  }

  // Phương thức để lấy thông tin chi tiết sản phẩm
  Future<ProductResponse?> getProductById(int productId) async {
    try {
      final response = await _productService.getProductById(productId);

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi lấy thông tin sản phẩm: $e');
      rethrow;
    }
  }

  // Phương thức để cập nhật sản phẩm
  Future<ProductResponse?> updateProduct({
    required ReqProduct reqProduct,
    List<File>? newProductImages,
    Map<String, File?>? newVariantImages,
    List<Map<String, dynamic>>? productImageOperations,
  }) async {
    try {
      // Process product images - existing logic stays the same
      List<String> productImageUrls = [];

      // Nếu có operations được chỉ định, xử lý theo operations
      if (productImageOperations != null && productImageOperations.isNotEmpty) {
        // Bắt đầu với danh sách hình ảnh gốc (nếu có)
        productImageUrls = reqProduct.images ?? [];

        for (final operation in productImageOperations) {
          final String type = operation['type'];

          switch (type) {
            case 'add':
              // Thêm hình ảnh mới vào cuối danh sách
              final File imageFile = operation['file'];
              final baseName =
                  'product_${reqProduct.name!.toLowerCase().replaceAll(' ', '_')}_add';
              final String? uploadedUrl =
                  await _uploadImage(imageFile, baseName);
              if (uploadedUrl != null) {
                // Ensure we're adding to the end of the list
                productImageUrls.add(uploadedUrl);
              }
              break;

            case 'replace':
              // Thay thế hình ảnh tại vị trí cụ thể
              final int index = operation['index'];
              final File imageFile = operation['file'];
              final baseName =
                  'product_${reqProduct.name!.toLowerCase().replaceAll(' ', '_')}_replace';
              final String? uploadedUrl =
                  await _uploadImage(imageFile, baseName);

              if (uploadedUrl != null &&
                  index >= 0 &&
                  index < productImageUrls.length) {
                productImageUrls[index] = uploadedUrl;
              }
              break;

            case 'remove':
              // Xóa hình ảnh tại vị trí cụ thể
              final int index = operation['index'];
              if (index >= 0 && index < productImageUrls.length) {
                productImageUrls.removeAt(index);
              }
              break;
          }
        }
      }
      // Nếu không có operations và không có hình ảnh mới, giữ nguyên hình ảnh gốc
      else if ((reqProduct.images?.isNotEmpty ?? false) &&
          newProductImages == null) {
        productImageUrls = reqProduct.images!;
      }
      // Nếu không có operations nhưng có hình ảnh mới (trường hợp replace hoàn toàn - backwards compatibility)
      else if (newProductImages != null && newProductImages.isNotEmpty) {
        final baseName =
            'product_${reqProduct.name!.toLowerCase().replaceAll(' ', '_')}';
        final List<String> uploadedImageUrls =
            await _uploadMultipleImages(newProductImages, baseName);

        if (uploadedImageUrls.isNotEmpty) {
          productImageUrls = uploadedImageUrls;
        }
      }

      // Cập nhật danh sách hình ảnh trong đối tượng reqProduct
      reqProduct.images = productImageUrls;

      // Process variant images and ensure we preserve variant IDs for existing variants
      final Map<String, List<String>> colorToImagesMap = {};

      if (reqProduct.variants != null && reqProduct.variants!.isNotEmpty) {
        // Group variants by color
        final Map<String, List<Variants>> variantsByColor = {};
        for (final variant in reqProduct.variants!) {
          final color = variant.color!;
          if (!variantsByColor.containsKey(color)) {
            variantsByColor[color] = [];
          }
          variantsByColor[color]!.add(variant);
        }

        // Process the variant images
        if (newVariantImages != null && newVariantImages.isNotEmpty) {
          // Upload and update images for colors with new images
          for (final entry in newVariantImages.entries) {
            final String color = entry.key;
            final File? variantImage = entry.value;

            if (variantImage != null) {
              final String variantBaseName =
                  'product_${reqProduct.name!.toLowerCase().replaceAll(' ', '_')}_${color.toLowerCase()}';
              final imageUrl =
                  await _uploadImage(variantImage, variantBaseName);

              if (imageUrl != null) {
                colorToImagesMap[color] = [imageUrl];
              }
            } else {
              // If File is null but in the map, user has deleted the image
              // Set empty array for this color
              colorToImagesMap[color] = [];
            }
          }
        }

        // Update image URLs for variants of the same color
        for (final color in variantsByColor.keys) {
          // If this color has new images (changed or deleted)
          if (colorToImagesMap.containsKey(color)) {
            final imageUrls = colorToImagesMap[color]!;
            for (final variant in variantsByColor[color]!) {
              variant.images = imageUrls;
            }
          }
          // Otherwise, keep existing image if available
          else if (variantsByColor[color]!.isNotEmpty &&
              variantsByColor[color]!.first.images != null &&
              variantsByColor[color]!.first.images!.isNotEmpty) {
            final existingImageUrl = variantsByColor[color]!.first.images!;
            for (final variant in variantsByColor[color]!) {
              variant.images = existingImageUrl;
            }
          }
        }
      }

      // Call the API to update the product
      final response = await _productService.updateProduct(reqProduct);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Update the returned product with the new image URLs
        if (response.data != null) {
          // Update main product images if they were changed
          if (productImageUrls.isNotEmpty) {
            response.data!.images = productImageUrls;
          }

          // Update variant images if they were changed
          if (response.data!.variants != null && colorToImagesMap.isNotEmpty) {
            for (final variant in response.data!.variants!) {
              final String? color = variant.color;
              if (color != null && colorToImagesMap.containsKey(color)) {
                variant.images = colorToImagesMap[color];
              }
            }
          }
        }
        return response.data;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi cập nhật sản phẩm: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      final response = await _productService.deleteProduct(productId);
      if (response.statusCode == 200) {
        return;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi xóa sản phẩm: $e');
      rethrow;
    }
  }
}
