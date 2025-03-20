class ReqUploadImage {
  final String? fileName;

  ReqUploadImage({this.fileName});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fileName'] = fileName;
    return data;
  }
}
