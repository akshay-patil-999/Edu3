class FeedbackModel {
  final String id;
  final String studentId;
  final String teacherId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  FeedbackModel({
    required this.id,
    required this.studentId,
    required this.teacherId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'teacherId': teacherId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      rating: map['rating'] ?? 0,
      comment: map['comment'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }
}
