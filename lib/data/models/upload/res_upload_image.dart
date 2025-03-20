class ResUploadImage {
  final String? signedUrl;

  ResUploadImage({
    this.signedUrl,
  });

  factory ResUploadImage.fromJson(Map<String, dynamic> json) {
    return ResUploadImage(
      signedUrl: json['signedUrl'],
    );
  }

  Map<String, dynamic> fromJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['signedUrl'] = signedUrl;
    return data;
  }
}
