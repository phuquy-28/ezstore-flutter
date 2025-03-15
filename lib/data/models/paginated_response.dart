class PaginationMeta {
  final int page;
  final int pageSize;
  final int pages;
  final int total;

  PaginationMeta({
    required this.page,
    required this.pageSize,
    required this.pages,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'],
      pageSize: json['pageSize'],
      pages: json['pages'],
      total: json['total'],
    );
  }
}

class PaginatedResponse<T> {
  final PaginationMeta meta;
  final List<T> data;

  PaginatedResponse({
    required this.meta,
    required this.data,
  });

  factory PaginatedResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return PaginatedResponse(
      meta: PaginationMeta.fromJson(json['meta']),
      data: (json['data'] as List).map((item) => fromJson(item)).toList(),
    );
  }
}
