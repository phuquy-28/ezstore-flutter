class OrderResponse {
  int? id;
  String? orderCode;
  String? orderDate;
  String? customerName;
  double? total;
  String? paymentStatus;
  String? orderStatus;
  int? numberOfItems;
  String? paymentMethod;
  String? deliveryMethod;

  OrderResponse(
      {this.id,
      this.orderCode,
      this.orderDate,
      this.customerName,
      this.total,
      this.paymentStatus,
      this.orderStatus,
      this.numberOfItems,
      this.paymentMethod,
      this.deliveryMethod});

  OrderResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderCode = json['orderCode'];
    orderDate = json['orderDate'];
    customerName = json['customerName'];
    total = json['total'];
    paymentStatus = json['paymentStatus'];
    orderStatus = json['orderStatus'];
    numberOfItems = json['numberOfItems'];
    paymentMethod = json['paymentMethod'];
    deliveryMethod = json['deliveryMethod'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['orderCode'] = this.orderCode;
    data['orderDate'] = this.orderDate;
    data['customerName'] = this.customerName;
    data['total'] = this.total;
    data['paymentStatus'] = this.paymentStatus;
    data['orderStatus'] = this.orderStatus;
    data['numberOfItems'] = this.numberOfItems;
    data['paymentMethod'] = this.paymentMethod;
    data['deliveryMethod'] = this.deliveryMethod;
    return data;
  }
}
