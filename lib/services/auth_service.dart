import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

/// Отвечает за локальное хранение пользователя и состояние авторизации.
///
/// В shared_preferences хранятся три значения:
/// * профиль пользователя (JSON);
/// * хэш пароля (сам пароль в открытом виде не сохраняется);
/// * флаг «пользователь вошёл в аккаунт».
class AuthService {
  AuthService(this._prefs);

  /// Создаёт сервис, дождавшись инициализации хранилища.
  static Future<AuthService> create() async {
    return AuthService(await SharedPreferences.getInstance());
  }

  static const _profileKey = 'user_profile';
  static const _passwordHashKey = 'user_password_hash';
  static const _isLoggedInKey = 'is_logged_in';

  final SharedPreferences _prefs;

  /// Вошёл ли пользователь (флаг сохраняется между запусками приложения).
  bool get isLoggedIn =>
      (_prefs.getBool(_isLoggedInKey) ?? false) && currentUser != null;

  /// Есть ли на устройстве зарегистрированный аккаунт.
  bool get hasAccount => _prefs.containsKey(_profileKey);

  /// Сохранённый профиль или null, если аккаунта нет.
  UserProfile? get currentUser {
    final rawJson = _prefs.getString(_profileKey);
    if (rawJson == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(rawJson) as Map<String, dynamic>);
    } on FormatException {
      return null;
    }
  }

  /// Регистрация: сохраняет данные и пароль, после чего пользователь
  /// сразу считается вошедшим.
  Future<void> register(UserProfile profile, String password) async {
    await _saveProfile(profile);
    await _prefs.setString(_passwordHashKey, _hashPassword(password));
    await _prefs.setBool(_isLoggedInKey, true);
  }

  /// Обновляет данные профиля без изменения пароля.
  Future<void> updateProfile(UserProfile profile) => _saveProfile(profile);

  /// Проверяет email и пароль. Возвращает true при успешном входе.
  Future<bool> login(String email, String password) async {
    final user = currentUser;
    if (user == null) return false;

    final isEmailCorrect =
        user.email.toLowerCase() == email.trim().toLowerCase();
    final isPasswordCorrect =
        _prefs.getString(_passwordHashKey) == _hashPassword(password);

    if (!isEmailCorrect || !isPasswordCorrect) return false;

    await _prefs.setBool(_isLoggedInKey, true);
    return true;
  }

  /// Выход из аккаунта. Данные профиля остаются на устройстве,
  /// чтобы пользователь мог снова войти по email и паролю.
  Future<void> logout() => _prefs.setBool(_isLoggedInKey, false);

  Future<void> _saveProfile(UserProfile profile) {
    return _prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  static String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}
