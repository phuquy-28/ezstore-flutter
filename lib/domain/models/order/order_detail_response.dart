class OrderDetailResponse {
  int? id;
  String? code;
  String? orderDate;
  String? status;
  String? paymentMethod;
  String? paymentStatus;
  String? paymentDate;
  List<LineItem>? lineItems;
  double? total;
  double? shippingFee;
  double? discount;
  double? pointDiscount;
  double? finalTotal;
  bool? canReview;
  bool? isReviewed;
  String? cancelReason;
  ShippingProfile? shippingProfile;

  OrderDetailResponse({
    this.id,
    this.code,
    this.orderDate,
    this.status,
    this.paymentMethod,
    this.paymentStatus,
    this.paymentDate,
    this.lineItems,
    this.total,
    this.shippingFee,
    this.discount,
    this.pointDiscount,
    this.finalTotal,
    this.canReview,
    this.isReviewed,
    this.cancelReason,
    this.shippingProfile,
  });

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) =>
      OrderDetailResponse(
        id: json['id'],
        code: json['code'],
        orderDate: json['orderDate'],
        status: json['status'],
        paymentMethod: json['paymentMethod'],
        paymentStatus: json['paymentStatus'],
        paymentDate: json['paymentDate'],
        lineItems: json['lineItems'] != null
            ? (json['lineItems'] as List)
                .map((e) => LineItem.fromJson(e))
                .toList()
            : null,
        total: json['total'],
        shippingFee: json['shippingFee'],
        discount: json['discount'],
        pointDiscount: json['pointDiscount'],
        finalTotal: json['finalTotal'],
        canReview: json['canReview'],
        isReviewed: json['isReviewed'],
        cancelReason: json['cancelReason'],
        shippingProfile: json['shippingProfile'] != null
            ? ShippingProfile.fromJson(json['shippingProfile'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'orderDate': orderDate,
        'status': status,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        'paymentDate': paymentDate,
        'lineItems': lineItems?.map((e) => e.toJson()).toList(),
        'total': total,
        'shippingFee': shippingFee,
        'discount': discount,
        'pointDiscount': pointDiscount,
        'finalTotal': finalTotal,
        'canReview': canReview,
        'isReviewed': isReviewed,
        'cancelReason': cancelReason,
        'shippingProfile': shippingProfile?.toJson(),
      };
}

class LineItem {
  int? id;
  String? productName;
  String? color;
  String? size;
  String? variantImage;
  int? quantity;
  double? unitPrice;
  double? discount;

  LineItem({
    this.id,
    this.productName,
    this.color,
    this.size,
    this.variantImage,
    this.quantity,
    this.unitPrice,
    this.discount,
  });

  factory LineItem.fromJson(Map<String, dynamic> json) => LineItem(
        id: json['id'],
        productName: json['productName'],
        color: json['color'],
        size: json['size'],
        variantImage: json['variantImage'],
        quantity: json['quantity'],
        unitPrice: json['unitPrice'],
        discount: json['discount'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'productName': productName,
        'color': color,
        'size': size,
        'variantImage': variantImage,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'discount': discount,
      };
}

class ShippingProfile {
  int? id;
  String? firstName;
  String? lastName;
  String? phoneNumber;
  String? address;
  int? wardId;
  String? ward;
  int? districtId;
  String? district;
  int? provinceId;
  String? province;
  bool? isDefault;

  ShippingProfile({
    this.id,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.address,
    this.wardId,
    this.ward,
    this.districtId,
    this.district,
    this.provinceId,
    this.province,
    this.isDefault,
  });

  factory ShippingProfile.fromJson(Map<String, dynamic> json) =>
      ShippingProfile(
        id: json['id'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        phoneNumber: json['phoneNumber'],
        address: json['address'],
        wardId: json['wardId'],
        ward: json['ward'],
        districtId: json['districtId'],
        district: json['district'],
        provinceId: json['provinceId'],
        province: json['province'],
        isDefault: json['default'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'address': address,
        'wardId': wardId,
        'ward': ward,
        'districtId': districtId,
        'district': district,
        'provinceId': provinceId,
        'province': province,
        'default': isDefault,
      };
}
