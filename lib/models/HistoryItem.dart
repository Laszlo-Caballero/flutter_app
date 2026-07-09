class HistoryItem {
  final int id;
  final String title;
  final String time;
  final String description;
  final List<String> tags;
  final String image;
  final String category;

  HistoryItem({
    required this.id,
    required this.title,
    required this.time,
    required this.description,
    required this.tags,
    required this.image,
    required this.category,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      time: json['time'] as String? ?? '',
      description: json['description'] as String? ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      image: json['image'] as String? ?? '',
      category: json['category'] as String? ?? '',
    );
  }
}
