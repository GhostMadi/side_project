/// Ник в списках чата и заголовках — без ведущего `@`.
String chatDisplayUsername(String? raw) {
  final s = raw?.trim();
  if (s == null || s.isEmpty) return '';
  return s.replaceFirst(RegExp(r'^@+'), '').trim();
}
