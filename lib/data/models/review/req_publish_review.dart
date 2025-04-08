class ReqPublishReview {
  int? reviewId;
  bool? published;

  ReqPublishReview({this.reviewId, this.published});

  ReqPublishReview.fromJson(Map<String, dynamic> json) {
    reviewId = json['reviewId'];
    published = json['published'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['reviewId'] = this.reviewId;
    data['published'] = this.published;
    return data;
  }
}
