class ReqCategory {
  final int? id;
  final String name;
  final String? imageUrl;

  ReqCategory({
    this.id,
    required this.name,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    data['name'] = name;
    if (imageUrl != null) data['imageUrl'] = imageUrl;
    return data;
  }
} 