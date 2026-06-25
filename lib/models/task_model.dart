class TaskModel {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String tuitionId;
  final String createdBy;
  final DateTime deadline;
  final String attachmentUrl;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.subject,
    required this.tuitionId,
    required this.createdBy,
    required this.deadline,
    this.attachmentUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'tuitionId': tuitionId,
      'createdBy': createdBy,
      'deadline': deadline.millisecondsSinceEpoch,
      'attachmentUrl': attachmentUrl,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? '',
      tuitionId: map['tuitionId'] ?? '',
      createdBy: map['createdBy'] ?? '',
      deadline: DateTime.fromMillisecondsSinceEpoch(map['deadline'] ?? 0),
      attachmentUrl: map['attachmentUrl'] ?? '',
    );
  }
}
