class ReqUser {
  int? id;
  String? email;
  String? password;
  String? firstName;
  String? lastName;
  String? birthDate;
  String? phone;
  String? gender;
  int? roleId;

  ReqUser(
      {this.id,
      this.email,
      this.password,
      this.firstName,
      this.lastName,
      this.birthDate,
      this.phone,
      this.gender,
      this.roleId});

  ReqUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    password = json['password'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    birthDate = json['birthDate'];
    phone = json['phone'];
    gender = json['gender'];
    roleId = json['roleId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['password'] = this.password;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['birthDate'] = this.birthDate;
    data['phone'] = this.phone;
    data['gender'] = this.gender;
    data['roleId'] = this.roleId;
    return data;
  }
}
