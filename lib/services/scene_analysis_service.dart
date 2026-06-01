import 'package:uuid/uuid.dart';
import '../models/scene_analysis.dart';
import '../models/person_position.dart';
import 'pose_template_service.dart';

class SceneAnalysisService {
  final PoseTemplateService _templateService = PoseTemplateService();
  static final _uuid = Uuid();

  /// Template-based analysis (offline, always works).
  SceneAnalysis analyzeWithTemplate({
    required int peopleCount,
    required String ageGroup,
    String? style,
  }) {
    final template = _templateService.bestMatch(peopleCount, ageGroup, style);

    final positions = template?.positions ?? _fallbackPositions(peopleCount);

    return SceneAnalysis(
      id: _uuid.v4(),
      source: 'template',
      positions: positions,
      sceneDescription: template?.layoutDescription ?? '$peopleCount人自由站位',
      createdAt: DateTime.now(),
    );
  }

  /// Fallback: simple lineup if no template matches.
  List<PersonPosition> _fallbackPositions(int count) {
    return List.generate(count, (i) {
      return PersonPosition(
        id: _uuid.v4(),
        x: 0.2 + (0.6 * i / ((count - 1).clamp(1, 99))),
        y: 0.55,
        poseName: '自然站立',
        poseDescription: '自然放松站立',
        priority: 0,
      );
    });
  }
}
