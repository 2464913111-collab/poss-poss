import 'dart:ui';

class BodyAngles {
  final double leftShoulder;
  final double rightShoulder;
  final double leftElbow;
  final double rightElbow;
  final double leftHip;
  final double rightHip;
  final double leftKnee;
  final double rightKnee;
  final double spineTilt;
  final double headTilt;

  const BodyAngles({
    this.leftShoulder = 0,
    this.rightShoulder = 0,
    this.leftElbow = 180,
    this.rightElbow = 180,
    this.leftHip = 0,
    this.rightHip = 0,
    this.leftKnee = 180,
    this.rightKnee = 180,
    this.spineTilt = 0,
    this.headTilt = 0,
  });

  static const neutral = BodyAngles();

  Map<String, dynamic> toJson() => {
    'leftShoulder': leftShoulder, 'rightShoulder': rightShoulder,
    'leftElbow': leftElbow, 'rightElbow': rightElbow,
    'leftHip': leftHip, 'rightHip': rightHip,
    'leftKnee': leftKnee, 'rightKnee': rightKnee,
    'spineTilt': spineTilt, 'headTilt': headTilt,
  };

  factory BodyAngles.fromJson(Map<String, dynamic> json) => BodyAngles(
    leftShoulder: (json['leftShoulder'] as num?)?.toDouble() ?? 0,
    rightShoulder: (json['rightShoulder'] as num?)?.toDouble() ?? 0,
    leftElbow: (json['leftElbow'] as num?)?.toDouble() ?? 180,
    rightElbow: (json['rightElbow'] as num?)?.toDouble() ?? 180,
    leftHip: (json['leftHip'] as num?)?.toDouble() ?? 0,
    rightHip: (json['rightHip'] as num?)?.toDouble() ?? 0,
    leftKnee: (json['leftKnee'] as num?)?.toDouble() ?? 180,
    rightKnee: (json['rightKnee'] as num?)?.toDouble() ?? 180,
    spineTilt: (json['spineTilt'] as num?)?.toDouble() ?? 0,
    headTilt: (json['headTilt'] as num?)?.toDouble() ?? 0,
  );

  /// Calculate approximate joint positions for rendering.
  /// Returns a list of key points in relative coordinates (0-1).
  Offset headCenter(Size size) {
    return Offset(size.width / 2, size.height * 0.08);
  }

  double get headRadius => 0.07; // relative to height
}
