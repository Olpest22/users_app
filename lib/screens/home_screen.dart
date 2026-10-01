import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';
import '../widgets/profile_info_tile.dart';
import 'login_screen.dart';
import 'profile_form_screen.dart';

/// Главный экран: показывает сохранённые данные пользователя.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserProfile _user;

  @override
  void initState() {
    super.initState();
    // Главный экран открывается только для вошедшего пользователя,
    // поэтому профиль здесь гарантированно существует.
    _user = widget.authService.currentUser!;
  }

  Future<void> _editProfile() async {
    final updatedUser = await Navigator.of(context).push<UserProfile>(
      MaterialPageRoute(
        builder: (_) => ProfileFormScreen(
          authService: widget.authService,
          initialProfile: _user,
        ),
      ),
    );
    if (updatedUser == null || !mounted) return;

    setState(() => _user = updatedUser);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Данные сохранены')),
    );
  }

  /// Выход с подтверждением. После выхода открывается экран входа,
  /// а история навигации очищается.
  Future<void> _logout() async {
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text(
          'Ваши данные останутся на устройстве, '
          'войти снова можно по email и паролю.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
    if (isConfirmed != true) return;

    await widget.authService.logout();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginScreen(authService: widget.authService),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой профиль'),
        actions: [
          IconButton(
            tooltip: 'Редактировать',
            icon: const Icon(Icons.edit_outlined),
            onPressed: _editProfile,
          ),
          IconButton(
            tooltip: 'Выйти',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ProfileHeader(user: _user),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  ProfileInfoTile(
                    icon: Icons.person_outline,
                    label: 'Имя',
                    value: _user.name,
                  ),
                  const Divider(height: 1, indent: 56),
                  ProfileInfoTile(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: _user.email,
                  ),
                  const Divider(height: 1, indent: 56),
                  ProfileInfoTile(
                    icon: Icons.phone_outlined,
                    label: 'Телефон',
                    value: _user.phone,
                  ),
                  const Divider(height: 1, indent: 56),
                  ProfileInfoTile(
                    icon: Icons.location_city_outlined,
                    label: 'Город',
                    value: _user.city,
                  ),
                  const Divider(height: 1, indent: 56),
                  ProfileInfoTile(
                    icon: Icons.event_outlined,
                    label: 'Дата регистрации',
                    value: formatDate(_user.registeredAt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _editProfile,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Редактировать данные'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _logout,
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Выйти из аккаунта'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Шапка профиля: аватар с инициалами, имя и email.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            user.initials,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Привет, ${user.name.split(' ').first}!',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
