class TaskModel {
  const TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int userId;
  final String title;
  final String description;
  final String priority;
  final DateTime dueDate;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      priority: json['priority'] as String,
      dueDate: DateTime.parse(json['due_date'] as String),
      status: json['status'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      'due_date': dueDate.toIso8601String().split('T').first,
      'status': status,
    };
  }

  TaskModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    String? priority,
    DateTime? dueDate,
    String? status,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static const priorities = ['Low', 'Medium', 'High'];
  static const statuses = ['Pending', 'In Progress', 'Completed'];
}
