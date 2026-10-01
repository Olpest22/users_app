import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Хранилище читается до запуска интерфейса, чтобы сразу открыть
  // нужный экран без мелькания экрана входа.
  final authService = await AuthService.create();
  runApp(UsersApp(authService: authService));
}

class UsersApp extends StatelessWidget {
  const UsersApp({super.key, required this.authService});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);

    return MaterialApp(
      title: 'Мой профиль',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style:
              OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
      ),
      // Неавторизованный пользователь всегда попадает на экран входа.
      home: authService.isLoggedIn
          ? HomeScreen(authService: authService)
          : LoginScreen(authService: authService),
    );
  }
}
