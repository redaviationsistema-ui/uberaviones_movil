class SessionStore {
  SessionStore._();

  static final SessionStore instance = SessionStore._();

  String? _token;

  String? get token => _token;

  void setToken(String token) {
    _token = token;
  }

  void clear() {
    _token = null;
  }
}
