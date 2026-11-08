class HistoryItem {
  final String id;
  final String expression;
  final String result;
  final DateTime timestamp;
  final String category;

  HistoryItem({
    required this.id,
    required this.expression,
    required this.result,
    required this.timestamp,
    this.category = 'Scientific',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'expression': expression,
        'result': result,
        'timestamp': timestamp.toIso8601String(),
        'category': category,
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        id: json['id'] as String,
        expression: json['expression'] as String,
        result: json['result'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        category: json['category'] as String? ?? 'Scientific',
      );
}

