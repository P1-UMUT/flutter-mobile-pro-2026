// lib/core/utils/extensions.dart
extension StringExtensions on String {
  String get trimmed => trim();
  bool get isValidEmail {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(trim());
  }
}

extension DateTimeExtensions on DateTime {
  String get formattedDate => '${day.toString().padLeft(2, '0')}.${month.toString().padLeft(2, '0')}.$year';
}
