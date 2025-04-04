class ReqPromotion {
  int? id;
  String? name;
  int? discountRate;
  String? description;
  String? startDate;
  String? endDate;
  List<int>? productIds;
  List<int>? categoryIds;

  ReqPromotion(
      {this.id,
      this.name,
      this.discountRate,
      this.description,
      this.startDate,
      this.endDate,
      this.productIds,
      this.categoryIds});

  ReqPromotion.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    discountRate = json['discountRate'];
    description = json['description'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    productIds = json['productIds'].cast<int>();
    categoryIds = json['categoryIds'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['discountRate'] = this.discountRate;
    data['description'] = this.description;
    data['startDate'] = this.startDate;
    data['endDate'] = this.endDate;
    data['productIds'] = this.productIds;
    data['categoryIds'] = this.categoryIds;
    return data;
  }
}
