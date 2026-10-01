/// Данные пользователя, которые он вводит при регистрации
/// и может изменить позже на главном экране.
class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.registeredAt,
    this.phone = '',
    this.city = '',
  });

  final String name;
  final String email;
  final String phone;
  final String city;
  final DateTime registeredAt;

  /// Инициалы для аватара: «Иван Петров» → «ИП».
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'city': city,
        'registeredAt': registeredAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      city: json['city'] as String? ?? '',
      registeredAt: DateTime.parse(json['registeredAt'] as String),
    );
  }
}
