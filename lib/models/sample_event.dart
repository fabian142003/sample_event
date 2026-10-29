class SampleEvent {
  const SampleEvent({
    required this.id,
    required this.sampleId,
    required this.type,
    required this.createdAt,
  });

  final String id;
  final String sampleId;
  final String type;
  final DateTime createdAt;


  factory SampleEvent.fromJson(Map<String, dynamic> json) {
    return SampleEvent(
      id: json['id'] as String,
      sampleId: json['sampleId'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sampleId': sampleId,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
