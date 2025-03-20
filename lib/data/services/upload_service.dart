import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/data/models/api_response.dart';
import 'package:ezstore_flutter/data/models/upload/req_upload_image.dart';
import 'package:ezstore_flutter/data/models/upload/res_upload_image.dart';
import 'package:ezstore_flutter/data/services/api_service.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:developer' as dev;

class UploadService {
  final ApiService _api;
  late final Dio _dio;

  UploadService(this._api) {
    _dio = Dio();
  }

  Future<ApiResponse<ResUploadImage>> getUploadImageUrl(
      ReqUploadImage reqUploadImage) async {
    return await _api.post(
      path: ApiConstants.products + ApiConstants.uploadImage,
      data: reqUploadImage.toJson(),
      fromJson: (json) => ResUploadImage.fromJson(json),
    );
  }

  Future<String?> uploadFileToStorage(File file, String signedUrl) async {
    try {
      // Xác định MIME type của file
      final mimeTypeData = lookupMimeType(file.path)?.split('/');
      final contentType = mimeTypeData != null
          ? MediaType(mimeTypeData[0], mimeTypeData[1])
          : MediaType('image',
              'jpeg'); // Mặc định là image/jpeg nếu không xác định được

      // Đọc dữ liệu file
      final bytes = await file.readAsBytes();

      // Thiết lập options với Content-Type phù hợp
      final options = Options(
        headers: {
          'Content-Type': contentType.toString(),
        },
        contentType: contentType.toString(),
      );

      // Gửi yêu cầu PUT với dữ liệu file trực tiếp (không dùng FormData)
      final response = await _dio.put(
        signedUrl,
        data: Stream.fromIterable([bytes]),
        options: options,
      );

      dev.log('Phản hồi từ Google Storage: ${response.statusCode}');

      // Kiểm tra mã trạng thái phản hồi
      if (response.statusCode == 200) {
        // Lấy URL công khai từ signedUrl
        // Cắt bỏ phần query string (tất cả sau dấu ?)
        final publicUrl = signedUrl.split('?')[0];

        dev.log('URL công khai của hình ảnh: $publicUrl');

        return publicUrl;
      } else {
        return null;
      }
    } catch (e) {
      dev.log('Lỗi khi tải lên hình ảnh: $e');
      return null;
    }
  }
}
