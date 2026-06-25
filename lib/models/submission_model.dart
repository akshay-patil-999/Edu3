class SubmissionModel {
  final String id;
  final String taskId;
  final String studentId;
  final String studentName;
  final String submissionText;
  final DateTime submittedAt;
  final List<String> attachments;
  final String? grade;
  final String? feedback;
  final bool isGraded;

  SubmissionModel({
    required this.id,
    required this.taskId,
    required this.studentId,
    required this.studentName,
    required this.submissionText,
    required this.submittedAt,
    this.attachments = const [],
    this.grade,
    this.feedback,
    this.isGraded = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'studentId': studentId,
      'studentName': studentName,
      'submissionText': submissionText,
      'submittedAt': submittedAt.toIso8601String(),
      'attachments': attachments,
      'grade': grade,
      'feedback': feedback,
      'isGraded': isGraded,
    };
  }

  factory SubmissionModel.fromMap(Map<String, dynamic> map) {
    return SubmissionModel(
      id: map['id'] ?? '',
      taskId: map['taskId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      submissionText: map['submissionText'] ?? '',
      submittedAt: DateTime.parse(map['submittedAt'] ?? DateTime.now().toIso8601String()),
      attachments: List<String>.from(map['attachments'] ?? []),
      grade: map['grade'],
      feedback: map['feedback'],
      isGraded: map['isGraded'] ?? false,
    );
  }
}
