import 'package:flutter/material.dart';

/// Строка с одним полем профиля: иконка, подпись и значение.
/// Пустое значение отображается как «Не указано».
class ProfileInfoTile extends StatelessWidget {
  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = value.trim().isEmpty;

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        isEmpty ? 'Не указано' : value,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isEmpty
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onSurface,
          fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }
}
