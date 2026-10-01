import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:users_app/models/user_profile.dart';
import 'package:users_app/services/auth_service.dart';

void main() {
  late AuthService authService;

  final testUser = UserProfile(
    name: 'Иван Петров',
    email: 'ivan@example.com',
    city: 'Москва',
    registeredAt: DateTime(2026, 10, 1),
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    authService = await AuthService.create();
  });

  test('без регистрации пользователь не авторизован', () {
    expect(authService.isLoggedIn, isFalse);
    expect(authService.currentUser, isNull);
  });

  test('регистрация сохраняет данные и авторизует', () async {
    await authService.register(testUser, 'secret123');

    expect(authService.isLoggedIn, isTrue);
    expect(authService.currentUser?.name, 'Иван Петров');
    expect(authService.currentUser?.initials, 'ИП');
  });

  test('пароль не хранится в открытом виде', () async {
    await authService.register(testUser, 'secret123');

    final prefs = await SharedPreferences.getInstance();
    final storedValues = prefs.getKeys().map((key) => '${prefs.get(key)}');
    expect(storedValues.any((value) => value.contains('secret123')), isFalse);
  });

  test('выход сбрасывает авторизацию, но сохраняет профиль', () async {
    await authService.register(testUser, 'secret123');
    await authService.logout();

    expect(authService.isLoggedIn, isFalse);
    expect(authService.hasAccount, isTrue);
  });

  test('вход проверяет email и пароль', () async {
    await authService.register(testUser, 'secret123');
    await authService.logout();

    expect(await authService.login('ivan@example.com', 'wrong'), isFalse);
    expect(await authService.login('IVAN@example.com', 'secret123'), isTrue);
    expect(authService.isLoggedIn, isTrue);
  });
}
