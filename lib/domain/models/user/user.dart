class Role {
  final int id;
  final String name;

  Role({required this.id, required this.name});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
    );
  }
}

class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? fullName;
  final String? birthDate;
  final String? phoneNumber;
  final String? gender;
  final Role role;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.fullName,
    this.birthDate,
    this.phoneNumber,
    this.gender,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      fullName: json['fullName'],
      birthDate: json['birthDate'],
      phoneNumber: json['phoneNumber'],
      gender: json['gender'],
      role: Role.fromJson(json['role']),
    );
  }
}
