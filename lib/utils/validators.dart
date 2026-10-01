/// Правила проверки полей форм. Каждый метод возвращает текст ошибки
/// или null, если значение корректно (формат, который ждёт TextFormField).
class Validators {
  Validators._();

  static final _emailRegExp = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final _phoneRegExp = RegExp(r'^\+?[0-9\s\-()]{7,20}$');

  static const minPasswordLength = 6;

  static String? name(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Введите имя';
    if (trimmed.length < 2) return 'Имя слишком короткое';
    return null;
  }

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Введите email';
    if (!_emailRegExp.hasMatch(trimmed)) return 'Некорректный email';
    return null;
  }

  /// Телефон необязателен, но если указан — должен быть похож на номер.
  static String? optionalPhone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    if (!_phoneRegExp.hasMatch(trimmed)) return 'Некорректный номер телефона';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Введите пароль';
    if (value.length < minPasswordLength) {
      return 'Минимум $minPasswordLength символов';
    }
    return null;
  }
}

/// Форматирует дату в вид «01.10.2026».
String formatDate(DateTime date) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  return '${twoDigits(date.day)}.${twoDigits(date.month)}.${date.year}';
}
