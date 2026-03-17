class AppException implements Exception {
  final String message;
  final String title;

  AppException({required this.title, required this.message});

  @override
  String toString() {
    return 'AppException: $title $message';
  }
}
