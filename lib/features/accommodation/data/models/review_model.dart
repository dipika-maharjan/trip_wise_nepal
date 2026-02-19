class ReviewModel {
  final String id;
  final String userName;
  final String userEmail;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String userId;

  ReviewModel({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.userId,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'] as String,
      userName: json['user']?['name'] ?? '',
      userEmail: json['user']?['email'] ?? '',
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['user']?['_id'] ?? '',
    );
  }
}
