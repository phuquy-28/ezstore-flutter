class ReqUpdateOrder {
  int? orderId;
  String? status;
  String? reason;

  ReqUpdateOrder({this.orderId, this.status, this.reason});

  ReqUpdateOrder.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    status = json['status'];
    reason = json['reason'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['orderId'] = this.orderId;
    data['status'] = this.status;
    data['reason'] = this.reason;
    return data;
  }
}
