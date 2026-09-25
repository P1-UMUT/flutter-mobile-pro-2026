import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;

  const UserModel({required this.id, required this.name, required this.email, this.photoUrl, required this.createdAt});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        photoUrl: json['photoUrl'] as String?,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, name, email, photoUrl, createdAt];
}
