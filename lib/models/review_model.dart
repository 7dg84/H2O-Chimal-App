class ReviewModel {
  final String id;
  final String user;
  final String? report;
  final String? tramite;
  final int value;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.user,
    this.report,
    this.tramite,
    required this.value,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      user: json['user'],
      report: json['report'],
      tramite: json['tramite'],
      value: json['value'].toInt(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}