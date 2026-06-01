import 'person_position.dart';

class SceneAnalysis {
  final String id;
  final String source; // "template" or "ai"
  final List<PersonPosition> positions;
  final String? sceneDescription;
  final List<String> suggestions;
  final DateTime createdAt;

  const SceneAnalysis({
    required this.id,
    required this.source,
    required this.positions,
    this.sceneDescription,
    this.suggestions = const [],
    required this.createdAt,
  });
}
