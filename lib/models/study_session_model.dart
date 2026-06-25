class StudySessionModel {
  final String id;
  final String userId;
  final int duration;
  final DateTime date;

  StudySessionModel({
    required this.id,
    required this.userId,
    required this.duration,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'duration': duration,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory StudySessionModel.fromMap(Map<String, dynamic> map) {
    return StudySessionModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      duration: map['duration'] ?? 0,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
    );
  }
}
