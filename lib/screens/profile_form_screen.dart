import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';
import 'home_screen.dart';

/// Экран ввода данных пользователя. Работает в двух режимах:
/// * регистрация ([initialProfile] == null) — с полями пароля;
/// * редактирование — поля заполнены текущими данными, пароль не меняется.
class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({
    super.key,
    required this.authService,
    this.initialProfile,
  });

  final AuthService authService;
  final UserProfile? initialProfile;

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _cityController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSaving = false;

  bool get _isEditing => widget.initialProfile != null;

  @override
  void initState() {
    super.initState();
    final profile = widget.initialProfile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
    _cityController = TextEditingController(text: profile?.city ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Сохраняет данные по нажатию кнопки «Сохранить».
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final profile = UserProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      city: _cityController.text.trim(),
      // При редактировании дата регистрации не меняется.
      registeredAt: widget.initialProfile?.registeredAt ?? DateTime.now(),
    );

    if (_isEditing) {
      await widget.authService.updateProfile(profile);
      if (!mounted) return;
      // Возвращаем обновлённый профиль на главный экран.
      Navigator.of(context).pop(profile);
    } else {
      await widget.authService.register(profile, _passwordController.text);
      if (!mounted) return;
      // После регистрации открываем главный экран и очищаем историю
      // навигации, чтобы кнопка «Назад» не вела на экран входа.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => HomeScreen(authService: widget.authService),
        ),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактирование' : 'Регистрация'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SectionTitle(
                      _isEditing ? 'Ваши данные' : 'Расскажите о себе',
                    ),
                    _buildField(
                      controller: _nameController,
                      label: 'Имя и фамилия',
                      icon: Icons.person_outline,
                      validator: Validators.name,
                      textCapitalization: TextCapitalization.words,
                    ),
                    _buildField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildField(
                      controller: _phoneController,
                      label: 'Телефон (необязательно)',
                      icon: Icons.phone_outlined,
                      validator: Validators.optionalPhone,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildField(
                      controller: _cityController,
                      label: 'Город (необязательно)',
                      icon: Icons.location_city_outlined,
                      textCapitalization: TextCapitalization.words,
                    ),
                    // Пароль задаётся только при регистрации.
                    if (!_isEditing) ...[
                      const SizedBox(height: 8),
                      const _SectionTitle('Пароль для входа'),
                      _buildField(
                        controller: _passwordController,
                        label: 'Пароль',
                        icon: Icons.lock_outline,
                        validator: Validators.password,
                        obscureText: true,
                      ),
                      _buildField(
                        controller: _confirmPasswordController,
                        label: 'Повторите пароль',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        validator: (value) =>
                            value != _passwordController.text
                                ? 'Пароли не совпадают'
                                : null,
                      ),
                    ],
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _save,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Сохранить'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Общий вид текстового поля, чтобы не повторять одинаковые настройки.
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        obscureText: obscureText,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
