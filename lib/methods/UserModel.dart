class UserModel {
  final String name;
  final String email;
  final String photourl;
  final String role;
  final List inGroup;

  UserModel({
    required this.name,
    required this.email,
    required this.photourl,
    required this.role,
    required this.inGroup,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'photourl': photourl,
        'role': role,
        'inGroup' : inGroup,
      };

  static UserModel fromJson(Map<String, dynamic> json) => UserModel(
        name: json['name'],
        email: json['email'],
        photourl: json['photourl'],
        role: json['role'],
        inGroup: json['inGroup']
      );
}
