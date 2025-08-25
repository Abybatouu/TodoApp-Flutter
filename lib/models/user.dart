class User {
  final int accountId;
  final String email;

  User({required this.accountId, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      accountId: int.parse(json['account_id'].toString()),
      email: json['email'] ?? '',
    );
  }
}
