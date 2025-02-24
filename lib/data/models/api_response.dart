class ApiResponse<T> {
  final int statusCode;
  final String? error;
  final String message;
  final T? data;

  ApiResponse({
    required this.statusCode,
    this.error,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponse(
      statusCode: json['statusCode'],
      error: json['error'],
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}
