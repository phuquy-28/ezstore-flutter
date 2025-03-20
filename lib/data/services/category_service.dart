import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/data/models/api_response.dart';
import 'package:ezstore_flutter/data/models/category/req_category.dart';
import 'package:ezstore_flutter/data/models/paginated_response.dart';
import 'package:ezstore_flutter/data/services/api_service.dart';
import 'package:ezstore_flutter/domain/models/category/category.dart';

class CategoryService {
  final ApiService _api;

  CategoryService(this._api);

  Future<ApiResponse<PaginatedResponse<Category>>> getAllCategories({
    int page = 0,
    int pageSize = 10,
    String? keyword,
  }) async {
    String path = '${ApiConstants.categories}?page=$page&size=$pageSize';

    if (keyword != null && keyword.isNotEmpty) {
      path += "&filter=name~'$keyword'";
    }

    return await _api.get(
      path: path,
      fromJson: (json) => PaginatedResponse<Category>.fromJson(
        json,
        (categoryJson) => Category.fromJson(categoryJson),
      ),
    );
  }

  Future<ApiResponse<Category>> getCategoryById(int categoryId) async {
    return await _api.get(
      path: '${ApiConstants.categories}/$categoryId',
      fromJson: (json) => Category.fromJson(json),
    );
  }

  Future<ApiResponse<Category>> updateCategory(ReqCategory category) async {
    return await _api.put(
      path: ApiConstants.categories,
      data: category.toJson(),
      fromJson: (json) => Category.fromJson(json),
    );
  }

  Future<ApiResponse<Category>> createCategory(ReqCategory category) async {
    return await _api.post(
      path: ApiConstants.categories,
      data: category.toJson(),
      fromJson: (json) => Category.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deleteCategory(int categoryId) async {
    return await _api.delete(
      path: '${ApiConstants.categories}/$categoryId',
      fromJson: (json) => null,
    );
  }
}
