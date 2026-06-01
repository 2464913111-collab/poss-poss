import 'body_angles.dart';

class PersonPosition {
  final String id;
  double x;
  double y;
  final String poseName;
  final String poseDescription;
  final BodyAngles bodyAngles;
  final String? referenceImageUrl;
  final int priority;

  PersonPosition({
    required this.id,
    required this.x,
    required this.y,
    required this.poseName,
    this.poseDescription = '',
    this.bodyAngles = BodyAngles.neutral,
    this.referenceImageUrl,
    this.priority = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'x': x, 'y': y,
    'poseName': poseName, 'poseDescription': poseDescription,
    'bodyAngles': bodyAngles.toJson(),
    'priority': priority,
  };

  factory PersonPosition.fromJson(Map<String, dynamic> json) => PersonPosition(
    id: json['id'] as String,
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    poseName: json['poseName'] as String? ?? '',
    poseDescription: json['poseDescription'] as String? ?? '',
    bodyAngles: json['bodyAngles'] != null
        ? BodyAngles.fromJson(json['bodyAngles'] as Map<String, dynamic>)
        : BodyAngles.neutral,
    priority: json['priority'] as int? ?? 0,
  );

  PersonPosition copyWith({double? x, double? y}) {
    return PersonPosition(
      id: id, x: x ?? this.x, y: y ?? this.y,
      poseName: poseName, poseDescription: poseDescription,
      bodyAngles: bodyAngles, priority: priority,
    );
  }
}
