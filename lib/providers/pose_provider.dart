import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scene_analysis.dart';
import '../models/person_position.dart';
import '../services/scene_analysis_service.dart';

/// Manages pose generation state.
class PoseNotifier extends StateNotifier<PoseState> {
  final SceneAnalysisService _service = SceneAnalysisService();

  PoseNotifier() : super(PoseState());

  int _peopleCount = 1;
  String _ageGroup = '青年';
  String _style = '休闲';

  int get peopleCount => _peopleCount;
  String get ageGroup => _ageGroup;
  String get style => _style;

  void setPeopleCount(int count) {
    _peopleCount = count.clamp(1, 20);
  }

  void setAgeGroup(String group) {
    _ageGroup = group;
  }

  void setStyle(String style) {
    _style = style;
  }

  void generatePoses() {
    final analysis = _service.analyzeWithTemplate(
      peopleCount: _peopleCount,
      ageGroup: _ageGroup,
      style: _style,
    );
    state = state.copyWith(
      analysis: analysis,
      positions: List.from(analysis.positions),
      isGenerating: false,
    );
  }

  void movePerson(String id, double newX, double newY) {
    final positions = state.positions.map((p) {
      if (p.id == id) {
        return p.copyWith(
          x: newX.clamp(0.02, 0.98),
          y: newY.clamp(0.05, 0.95),
        );
      }
      return p;
    }).toList();
    state = state.copyWith(positions: positions);
  }

  void reset() {
    state = PoseState();
  }
}

class PoseState {
  final SceneAnalysis? analysis;
  final List<PersonPosition> positions;
  final bool isGenerating;

  PoseState({
    this.analysis,
    this.positions = const [],
    this.isGenerating = false,
  });

  PoseState copyWith({
    SceneAnalysis? analysis,
    List<PersonPosition>? positions,
    bool? isGenerating,
  }) {
    return PoseState(
      analysis: analysis ?? this.analysis,
      positions: positions ?? this.positions,
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }
}

final poseProvider = StateNotifierProvider<PoseNotifier, PoseState>((ref) {
  return PoseNotifier();
});
