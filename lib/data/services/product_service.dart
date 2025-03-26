import 'package:ezstore_flutter/data/models/product/req_product.dart';
import 'package:ezstore_flutter/data/services/api_service.dart';
import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/domain/models/product/product_response.dart';
import 'package:ezstore_flutter/data/models/paginated_response.dart';
import 'package:ezstore_flutter/data/models/api_response.dart';

class ProductService {
  final ApiService _api;

  ProductService(this._api);

  Future<ApiResponse<PaginatedResponse<ProductResponse>>> getAllProducts({
    int page = 0,
    int pageSize = 10,
    String? keyword,
  }) async {
    String path = '${ApiConstants.products}?page=$page&size=$pageSize';

    // Thêm bộ lọc tìm kiếm nếu có từ khóa
    if (keyword != null && keyword.isNotEmpty) {
      path += "&filter=name~'$keyword'";
    }

    return await _api.get(
      path: path,
      fromJson: (json) => PaginatedResponse<ProductResponse>.fromJson(
        json,
        (productJson) => ProductResponse.fromJson(productJson),
      ),
    );
  }

  Future<ApiResponse<ProductResponse>> createProduct(ReqProduct product) async {
    return await _api.post(
      path: ApiConstants.products,
      data: product.toJson(),
      fromJson: (json) => ProductResponse.fromJson(json),
    );
  }

  Future<ApiResponse<ProductResponse>> getProductById(int id) async {
    return await _api.get(
      path: '${ApiConstants.products}/ids/$id',
      fromJson: (json) => ProductResponse.fromJson(json),
    );
  }

  Future<ApiResponse<ProductResponse>> updateProduct(ReqProduct product) async {
    return await _api.put(
      path: ApiConstants.products,
      data: product.toJson(),
      fromJson: (json) => ProductResponse.fromJson(json),
    );
  }

  Future<ApiResponse<ProductResponse>> deleteProduct(int id) async {
    return await _api.delete(
      path: '${ApiConstants.products}/$id',
      fromJson: (json) => ProductResponse.fromJson(json),
    );
  }
}
