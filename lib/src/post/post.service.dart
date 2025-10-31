class PostService {
  static PostService? _instance;
  static PostService get instance {
    _instance ??= PostService._();
    return _instance!;
  }

  PostService._();

  void initialize() {
    /// initialized
  }
}
