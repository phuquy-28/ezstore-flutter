class ReqProduct {
  int? id;
  String? name;
  String? description;
  double? price;
  int? categoryId;
  bool? isFeatured;
  List<String>? images;
  List<Variants>? variants;

  ReqProduct(
      {this.id,
      this.name,
      this.description,
      this.price,
      this.categoryId,
      this.isFeatured,
      this.images,
      this.variants});

  ReqProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    categoryId = json['categoryId'];
    isFeatured = json['isFeatured'];
    images = json['images'].cast<String>();
    if (json['variants'] != null) {
      variants = <Variants>[];
      json['variants'].forEach((v) {
        variants!.add(new Variants.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['price'] = this.price;
    data['categoryId'] = this.categoryId;
    data['isFeatured'] = this.isFeatured;
    data['images'] = this.images;
    if (this.variants != null) {
      data['variants'] = this.variants!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Variants {
  int? id;
  String? color;
  String? size;
  int? quantity;
  double? differencePrice;
  List<String>? images;

  Variants(
      {this.id,
      this.color,
      this.size,
      this.quantity,
      this.differencePrice,
      this.images});

  Variants.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    color = json['color'];
    size = json['size'];
    quantity = json['quantity'];
    differencePrice = json['differencePrice'];
    images = json['images'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['color'] = this.color;
    data['size'] = this.size;
    data['quantity'] = this.quantity;
    data['differencePrice'] = this.differencePrice;
    data['images'] = this.images;
    return data;
  }
}
