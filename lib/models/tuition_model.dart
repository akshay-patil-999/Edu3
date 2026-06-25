class TuitionModel {
  final String id;
  final String name;
  final String subject;
  final String timing;
  final String tuitionCode;
  final String teacherId;
  final String teacherName;
  final List<Map<String, dynamic>> students;
  final List<String> studentIds;
  final DateTime createdAt;

  TuitionModel({
    required this.id,
    required this.name,
    required this.subject,
    required this.timing,
    required this.tuitionCode,
    required this.teacherId,
    required this.teacherName,
    this.students = const [],
    this.studentIds = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'subject': subject,
      'timing': timing,
      'tuitionCode': tuitionCode,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'students': students,
      'studentIds': studentIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TuitionModel.fromMap(Map<String, dynamic> map) {
    return TuitionModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      subject: map['subject'] ?? '',
      timing: map['timing'] ?? '',
      tuitionCode: map['tuitionCode'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      students: (map['students'] as List<dynamic>?)
              ?.map((student) => Map<String, dynamic>.from(student))
              .toList() ??
          [],
      studentIds: List<String>.from(map['studentIds'] ?? []),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  TuitionModel copyWith({
    String? id,
    String? name,
    String? subject,
    String? timing,
    String? tuitionCode,
    String? teacherId,
    String? teacherName,
    List<Map<String, dynamic>>? students,
    List<String>? studentIds,
    DateTime? createdAt,
  }) {
    return TuitionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      timing: timing ?? this.timing,
      tuitionCode: tuitionCode ?? this.tuitionCode,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      students: students ?? this.students,
      studentIds: studentIds ?? this.studentIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
