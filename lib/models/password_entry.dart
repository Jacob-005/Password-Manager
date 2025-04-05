class PasswordEntry {
  final String id;
  final String title;
  final String username;
  final String password;

  PasswordEntry({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'username': username,
      'password': password,
    };
  }

  factory PasswordEntry.fromMap(String id, Map<String, dynamic> data) {
    return PasswordEntry(
      id: id,
      title: data['title'] ?? '',
      username: data['username'] ?? '',
      password: data['password'] ?? '',
    );
  }
}
