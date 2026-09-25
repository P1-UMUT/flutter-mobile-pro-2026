// lib/core/utils/validators.dart
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta alanı zorunludur.';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Geçerli bir e-posta adresi girin.';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre alanı zorunludur.';
    }

    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır.';
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ad soyad alanı zorunludur.';
    }

    if (value.trim().length < 2) {
      return 'Ad soyad en az 2 karakter olmalıdır.';
    }

    return null;
  }
}
