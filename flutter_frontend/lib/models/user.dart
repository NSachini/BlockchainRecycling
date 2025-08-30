class User {
  final String id;
  final String username;
  final String email;
  final String? qrCode;
  final int rewardPoints;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.qrCode,
    required this.rewardPoints,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      qrCode: json['qrCode'],
      rewardPoints: json['rewardPoints'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'qrCode': qrCode,
      'rewardPoints': rewardPoints,
    };
  }
}
