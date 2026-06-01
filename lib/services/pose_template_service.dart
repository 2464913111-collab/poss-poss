import 'package:uuid/uuid.dart';
import '../models/pose_template.dart';
import '../models/person_position.dart';
import '../models/body_angles.dart';

class PoseTemplateService {
  static final _uuid = Uuid();
  List<PoseTemplate> _templates = [];

  PoseTemplateService() {
    _templates = _generateAllTemplates();
  }

  /// Match templates by people count, age group, and style.
  List<PoseTemplate> match(int peopleCount, String ageGroup, String? style) {
    var candidates = _templates.where((t) => t.peopleCount == peopleCount).toList();

    if (candidates.isEmpty) {
      // Fallback: closest count
      candidates = _templates
          .where((t) => (t.peopleCount - peopleCount).abs() <= 2)
          .toList();
    }
    if (candidates.isEmpty) candidates = _templates;

    if (style != null) {
      final styled = candidates.where((t) => t.style == style).toList();
      if (styled.isNotEmpty) candidates = styled;
    }

    return candidates;
  }

  /// Generate a SceneAnalysis from the best matching template.
  PoseTemplate? bestMatch(int peopleCount, String ageGroup, String? style) {
    final matches = match(peopleCount, ageGroup, style);
    return matches.isNotEmpty ? matches.first : null;
  }

  // ============================================================
  // Template Generation
  // ============================================================

  static List<PoseTemplate> _generateAllTemplates() {
    final templates = <PoseTemplate>[];
    for (int n = 1; n <= 20; n++) {
      for (final style in ['formal', 'casual', 'creative']) {
        templates.add(_generateTemplate(n, style));
      }
    }
    return templates;
  }

  static PoseTemplate _generateTemplate(int count, String style) {
    final positions = _generatePositions(count, style);
    return PoseTemplate(
      id: 'tpl_${count}_$style',
      name: '${count}人${_styleName(style)}合照',
      peopleCount: count,
      ageGroups: _ageGroupsForStyle(style),
      style: style,
      positions: positions,
      layoutDescription: _describeLayout(count, style),
    );
  }

  static String _styleName(String style) {
    switch (style) {
      case 'formal': return '正式';
      case 'creative': return '创意';
      default: return '休闲';
    }
  }

  static List<String> _ageGroupsForStyle(String style) {
    switch (style) {
      case 'formal': return ['中年', '青年', '混合'];
      case 'creative': return ['青少年', '青年'];
      default: return ['儿童', '青少年', '青年', '中年', '老年', '混合'];
    }
  }

  // --------------- Layout engine ---------------

  static List<int> _rowsFor(int count) {
    if (count == 1) return [1];
    if (count == 2) return [2];
    if (count == 3) return [3];
    if (count == 4) return [2, 2];
    if (count == 5) return [3, 2];
    if (count == 6) return [3, 3];
    if (count <= 8) return [3, count - 3];
    if (count <= 12) {
      final front = count ~/ 2;
      return [front, count - front];
    }
    if (count <= 15) {
      final front = (count / 3 * 2).ceil();
      return [count - front, front - (count - front), count - front];
    }
    // 16-20: 3 rows
    final perRow = count ~/ 3;
    final remainder = count % 3;
    if (remainder == 0) return [perRow, perRow, perRow];
    if (remainder == 1) return [perRow, perRow + 1, perRow];
    return [perRow + 1, perRow, perRow + 1];
  }

  static int _rowFor(int index, List<int> rows) {
    int remaining = index;
    for (int i = 0; i < rows.length; i++) {
      if (remaining < rows[i]) return i;
      remaining -= rows[i];
    }
    return rows.length - 1;
  }

  static double _xPosition(int colIndex, int totalCols) {
    if (totalCols <= 1) return 0.5;
    final spacing = 0.65 / (totalCols - 1);
    final start = 0.5 - spacing * (totalCols - 1) / 2;
    return (start + spacing * colIndex).clamp(0.05, 0.95);
  }

  static double _yPosition(int row, int totalRows) {
    // Ground area: keep all people in the lower 30% of the photo
    // Front row near bottom, back row slightly higher
    if (totalRows == 1) return 0.75;
    if (totalRows == 2) {
      // 2 rows: front at 0.80, back at 0.62
      return row == 0 ? 0.80 : 0.62;
    }
    // 3 rows: front at 0.82, middle at 0.68, back at 0.55
    final startY = 0.82; // front (closest to camera)
    final endY = 0.55;   // back (furthest)
    return (startY - (startY - endY) * row / (totalRows - 1)).clamp(0.50, 0.88);
  }

  static List<PersonPosition> _generatePositions(int count, String style) {
    final rows = _rowsFor(count);
    final positions = <PersonPosition>[];
    final totalRows = rows.length;

    // Pose sets for variety
    const poses = [
      ('自然站立', '双脚与肩同宽，双手自然下垂', BodyAngles(
        leftShoulder: 0, rightShoulder: 0,
        leftElbow: 175, rightElbow: 175,
        leftHip: 0, rightHip: 0,
        leftKnee: 175, rightKnee: 175,
      )),
      ('双手抱胸', '双手交叉抱于胸前，挺胸收腹', BodyAngles(
        leftShoulder: 30, rightShoulder: 30,
        leftElbow: 120, rightElbow: 120,
        leftHip: 0, rightHip: 0,
        leftKnee: 175, rightKnee: 175,
        spineTilt: 5, headTilt: -3,
      )),
      ('单手插兜', '一只手插入裤袋，肩膀微侧', BodyAngles(
        leftShoulder: 15, rightShoulder: 0,
        leftElbow: 155, rightElbow: 175,
        leftHip: 3, rightHip: -3,
        leftKnee: 170, rightKnee: 170,
        spineTilt: 8, headTilt: 5,
      )),
      ('双手背后', '双手交握于背后，气质优雅', BodyAngles(
        leftShoulder: -10, rightShoulder: -10,
        leftElbow: 160, rightElbow: 160,
        leftHip: 0, rightHip: 0,
        leftKnee: 175, rightKnee: 175,
        spineTilt: -5, headTilt: 3,
      )),
      ('侧身站立', '身体微侧30°，脸正对镜头', BodyAngles(
        leftShoulder: 10, rightShoulder: 10,
        leftElbow: 170, rightElbow: 170,
        leftHip: 10, rightHip: 10,
        leftKnee: 170, rightKnee: 165,
        spineTilt: 15, headTilt: -10,
      )),
      ('叉腰站立', '双手叉腰，展现自信', BodyAngles(
        leftShoulder: 25, rightShoulder: 25,
        leftElbow: 60, rightElbow: 60,
        leftHip: 5, rightHip: -5,
        leftKnee: 170, rightKnee: 175,
        spineTilt: 3, headTilt: 5,
      )),
      ('蹲姿前排', '前排蹲下，一手自然撑膝', BodyAngles(
        leftShoulder: 0, rightShoulder: 0,
        leftElbow: 170, rightElbow: 160,
        leftHip: 40, rightHip: 40,
        leftKnee: 80, rightKnee: 90,
        spineTilt: 8, headTilt: -10,
      )),
      ('单膝点地', '单膝跪地，双手叠放膝上', BodyAngles(
        leftShoulder: 0, rightShoulder: 0,
        leftElbow: 175, rightElbow: 175,
        leftHip: 30, rightHip: 30,
        leftKnee: 90, rightKnee: 90,
        spineTilt: 10, headTilt: -5,
      )),
      ('比耶手势', '一只手做出V字手势', BodyAngles(
        leftShoulder: -160, rightShoulder: 0,
        leftElbow: 150, rightElbow: 175,
        leftHip: 0, rightHip: 0,
        leftKnee: 175, rightKnee: 175,
        spineTilt: -5, headTilt: 5,
      )),
      ('挥手致意', '一只手举起，手掌向前', BodyAngles(
        leftShoulder: -170, rightShoulder: 0,
        leftElbow: 120, rightElbow: 175,
        leftHip: 5, rightHip: 5,
        leftKnee: 175, rightKnee: 175,
        spineTilt: -3, headTilt: 10,
      )),
      ('手搭肩膀', '轻搭旁边人的肩膀', BodyAngles(
        leftShoulder: 80, rightShoulder: 0,
        leftElbow: 100, rightElbow: 175,
        leftHip: 0, rightHip: 0,
        leftKnee: 175, rightKnee: 175,
        spineTilt: 10, headTilt: -5,
      )),
      ('跳跃瞬间', '双脚离地，双手向上伸展', BodyAngles(
        leftShoulder: -170, rightShoulder: 170,
        leftElbow: 140, rightElbow: 140,
        leftHip: -20, rightHip: -20,
        leftKnee: 140, rightKnee: 140,
        spineTilt: 0, headTilt: -15,
      )),
    ];

    for (int i = 0; i < count; i++) {
      final row = _rowFor(i, rows);
      final colsInRow = rows[row];
      final colIndex = () {
        int remaining = i;
        for (int r = 0; r < row; r++) {
          remaining -= rows[r];
        }
        return remaining;
      }();

      final isFrontRow = row == 0;
      final poseIdx = isFrontRow && totalRows >= 2
          ? (6 + colIndex % 2)  // front row: squat/kneel
          : (i + style.hashCode.abs()) % poses.length;

      final pose = poses[poseIdx];

      positions.add(PersonPosition(
        id: _uuid.v4(),
        x: _xPosition(colIndex, colsInRow),
        y: _yPosition(row, totalRows),
        poseName: pose.$1,
        poseDescription: pose.$2,
        bodyAngles: pose.$3,
        priority: row,
      ));
    }

    return positions;
  }

  static String _describeLayout(int count, String style) {
    final rows = _rowsFor(count);
    final styleText = _styleName(style);
    if (rows.length == 1) return '$styleText排版，$count人并排站立';
    if (rows.length == 2) return '$styleText排版，前排${rows[0]}人蹲姿，后排${rows[1]}人站立';
    return '$styleText排版，三排错落分布（前${rows[0]}/中${rows[1]}/后${rows[2]}）';
  }
}
