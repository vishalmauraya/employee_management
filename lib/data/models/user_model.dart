class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.isAdmin = false,
  });

  final int id;
  final String name;
  final String email;
  final bool isAdmin;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      isAdmin: json['is_admin'] as bool? ?? false,
    );
  }
}
