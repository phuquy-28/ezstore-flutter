class ResetPasswordReq {
  String? email;
  String? resetCode;
  String? newPassword;
  String? confirmPassword;

  ResetPasswordReq(
      {this.email, this.resetCode, this.newPassword, this.confirmPassword});

  ResetPasswordReq.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    resetCode = json['resetCode'];
    newPassword = json['newPassword'];
    confirmPassword = json['confirmPassword'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['resetCode'] = this.resetCode;
    data['newPassword'] = this.newPassword;
    data['confirmPassword'] = this.confirmPassword;
    return data;
  }
}
