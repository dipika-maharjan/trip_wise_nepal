import 'package:trip_wise_nepal/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel{
  final String? id;
  final String fullName;
  final String email;
  final String username;
  final String? password;
  final String? profilePicture;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.username,
    this.password,
    this.profilePicture,
  });

  //toJson - For registration
  Map<String, dynamic> toJson() {
    return {
      'name': fullName,
      'email': email,
      'password': password,
      'confirmPassword': password,
    };
  }

  //toJsonWithUsername
  Map<String, dynamic> toJsonWithUsername() {
    return {
      'name': fullName,
      'email': email,
      'username': username,
      'password': password,
      'profilePicture': profilePicture,
    };
  }

  //fromJson
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'] as String?,
      fullName: json['name'] as String,
      email: json['email'] as String,
      username: json['username'] as String? ?? '',
      profilePicture: json['profilePicture'],
    );
  }

//toEntity
AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      fullName: fullName,
      email: email,
      username: username,
      profilePicture: profilePicture,
    );
  }

  //fromEntity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      fullName: entity.fullName,
      email: entity.email,
      username: entity.username,
      password: entity.password,
      profilePicture: entity.profilePicture,
    );
  }

  //toEntityList
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
 
}