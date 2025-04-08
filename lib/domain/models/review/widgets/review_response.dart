class ReviewResponse {
  int? reviewId;
  String? description;
  double? rating;
  String? createdAt;
  UserReviewDTO? userReviewDTO;
  bool? published;

  ReviewResponse(
      {this.reviewId,
      this.description,
      this.rating,
      this.createdAt,
      this.userReviewDTO,
      this.published});

  ReviewResponse.fromJson(Map<String, dynamic> json) {
    reviewId = json['reviewId'];
    description = json['description'];
    rating = json['rating'];
    createdAt = json['createdAt'];
    userReviewDTO = json['userReviewDTO'] != null
        ? new UserReviewDTO.fromJson(json['userReviewDTO'])
        : null;
    published = json['published'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['reviewId'] = this.reviewId;
    data['description'] = this.description;
    data['rating'] = this.rating;
    data['createdAt'] = this.createdAt;
    if (this.userReviewDTO != null) {
      data['userReviewDTO'] = this.userReviewDTO!.toJson();
    }
    data['published'] = this.published;
    return data;
  }
}

class UserReviewDTO {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  double? totalSpend;
  int? totalReview;

  UserReviewDTO(
      {this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.totalSpend,
      this.totalReview});

  UserReviewDTO.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    totalSpend = json['totalSpend'];
    totalReview = json['totalReview'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['email'] = this.email;
    data['totalSpend'] = this.totalSpend;
    data['totalReview'] = this.totalReview;
    return data;
  }
}
