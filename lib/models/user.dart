class User {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String city;
  final String password;
  final DateTime birthdate;
  final String gender;
  final List<String> hobbies;
  final bool isFavorite;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.password,
    required this.birthdate,
    required this.gender,
    required this.hobbies,
    required this.isFavorite,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'city': city,
      'password': password,
      'birthdate': birthdate.toIso8601String(),
      'gender': gender,
      'hobbies': hobbies.join(','),
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      city: map['city'],
      password: map['password'],
      birthdate: DateTime.parse(map['birthdate']),
      gender: map['gender'],
      hobbies: (map['hobbies'] as String).split(','),
      isFavorite: map['isFavorite'] == 1,
    );
  }

  // Create a new User with toggled favorite status
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    DateTime? birthdate,
    String? gender,
    String? city,
    List<String>? hobbies,
    bool? isFavorite,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      password: password ?? this.password,
      birthdate: birthdate ?? this.birthdate,
      gender: gender ?? this.gender,
      hobbies: hobbies ?? this.hobbies,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}