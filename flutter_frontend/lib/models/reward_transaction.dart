class RewardTransaction {
  final String id;
  final String userId;
  final String type;
  final int points;
  final String description;
  final DateTime date;

  RewardTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.points,
    required this.description,
    required this.date,
  });

  factory RewardTransaction.fromJson(Map<String, dynamic> json) {
    return RewardTransaction(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      points: json['points'] ?? 0,
      description: json['description'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'points': points,
      'description': description,
      'date': date.toIso8601String(),
    };
  }
}
