class PromotionResponse {
  int? id;
  String? name;
  double? discountRate;
  String? startDate;
  String? endDate;
  String? description;
  List<Products>? products;
  List<Categories>? categories;

  PromotionResponse(
      {this.id,
      this.name,
      this.discountRate,
      this.startDate,
      this.endDate,
      this.description,
      this.products,
      this.categories});

  PromotionResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    discountRate = json['discountRate'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    description = json['description'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(new Products.fromJson(v));
      });
    }
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(new Categories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['discountRate'] = this.discountRate;
    data['startDate'] = this.startDate;
    data['endDate'] = this.endDate;
    data['description'] = this.description;
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    if (this.categories != null) {
      data['categories'] = this.categories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Products {
  int? id;
  String? name;
  String? description;
  double? price;
  double? minPrice;
  double? maxPrice;
  double? priceWithDiscount;
  double? minPriceWithDiscount;
  double? maxPriceWithDiscount;
  int? categoryId;
  String? categoryName;
  double? discountRate;
  double? averageRating;
  int? numberOfReviews;
  int? numberOfSold;
  String? slug;
  String? colorDefault;
  List<String>? images;
  List<Variants>? variants;
  bool? featured;

  Products(
      {this.id,
      this.name,
      this.description,
      this.price,
      this.minPrice,
      this.maxPrice,
      this.priceWithDiscount,
      this.minPriceWithDiscount,
      this.maxPriceWithDiscount,
      this.categoryId,
      this.categoryName,
      this.discountRate,
      this.averageRating,
      this.numberOfReviews,
      this.numberOfSold,
      this.slug,
      this.colorDefault,
      this.images,
      this.variants,
      this.featured});

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    minPrice = json['minPrice'];
    maxPrice = json['maxPrice'];
    priceWithDiscount = json['priceWithDiscount'];
    minPriceWithDiscount = json['minPriceWithDiscount'];
    maxPriceWithDiscount = json['maxPriceWithDiscount'];
    categoryId = json['categoryId'];
    categoryName = json['categoryName'];
    discountRate = json['discountRate'];
    averageRating = json['averageRating'];
    numberOfReviews = json['numberOfReviews'];
    numberOfSold = json['numberOfSold'];
    slug = json['slug'];
    colorDefault = json['colorDefault'];
    images = json['images'].cast<String>();
    if (json['variants'] != null) {
      variants = <Variants>[];
      json['variants'].forEach((v) {
        variants!.add(new Variants.fromJson(v));
      });
    }
    featured = json['featured'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['price'] = this.price;
    data['minPrice'] = this.minPrice;
    data['maxPrice'] = this.maxPrice;
    data['priceWithDiscount'] = this.priceWithDiscount;
    data['minPriceWithDiscount'] = this.minPriceWithDiscount;
    data['maxPriceWithDiscount'] = this.maxPriceWithDiscount;
    data['categoryId'] = this.categoryId;
    data['categoryName'] = this.categoryName;
    data['discountRate'] = this.discountRate;
    data['averageRating'] = this.averageRating;
    data['numberOfReviews'] = this.numberOfReviews;
    data['numberOfSold'] = this.numberOfSold;
    data['slug'] = this.slug;
    data['colorDefault'] = this.colorDefault;
    data['images'] = this.images;
    if (this.variants != null) {
      data['variants'] = this.variants!.map((v) => v.toJson()).toList();
    }
    data['featured'] = this.featured;
    return data;
  }
}

class Variants {
  int? id;
  String? color;
  String? size;
  int? quantity;
  int? currentUserCartQuantity;
  double? differencePrice;
  List<String>? images;

  Variants(
      {this.id,
      this.color,
      this.size,
      this.quantity,
      this.currentUserCartQuantity,
      this.differencePrice,
      this.images});

  Variants.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    color = json['color'];
    size = json['size'];
    quantity = json['quantity'];
    currentUserCartQuantity = json['currentUserCartQuantity'];
    differencePrice = json['differencePrice'];
    images = json['images'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['color'] = this.color;
    data['size'] = this.size;
    data['quantity'] = this.quantity;
    data['currentUserCartQuantity'] = this.currentUserCartQuantity;
    data['differencePrice'] = this.differencePrice;
    data['images'] = this.images;
    return data;
  }
}

class Categories {
  int? id;
  String? name;
  String? imageUrl;

  Categories({this.id, this.name, this.imageUrl});

  Categories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['imageUrl'] = this.imageUrl;
    return data;
  }
}
