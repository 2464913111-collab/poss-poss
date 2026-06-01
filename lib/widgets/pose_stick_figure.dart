import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/body_angles.dart';

/// Paints a translucent stick figure based on body joint angles.
/// The pose data encodes real angles — different poses look genuinely different.
class PoseStickFigurePainter extends CustomPainter {
  final BodyAngles angles;
  final Color color;

  PoseStickFigurePainter({required this.angles, this.color = const Color(0xFFA8D8EA)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.90)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final jointPaint = Paint()
      ..color = color.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.16);

    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    // --- Body proportions (relative to widget size) ---
    final headR = w * 0.15;
    final headY = h * 0.08 + headR;
    final neckY = headY + headR;
    final shoulderY = neckY + h * 0.03;
    final hipY = h * 0.53;
    final kneeY = h * 0.76;
    final footY = h * 0.94;

    final shoulderLen = w * 0.24;
    final upperArmLen = h * 0.16;
    final lowerArmLen = h * 0.13;
    final spineLen = hipY - shoulderY;
    final upperLegLen = kneeY - hipY;
    final lowerLegLen = footY - kneeY;

    // --- Background card ---
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - w * 0.38, headY - headR - 6, w * 0.76, footY - headY + headR + 16),
      Radius.circular(w * 0.15),
    );
    canvas.drawRRect(bgRect, bgPaint);

    // --- Head ---
    canvas.drawCircle(Offset(cx, headY), headR, paint);

    // --- Neck ---
    canvas.drawLine(Offset(cx, neckY), Offset(cx, shoulderY - 2), paint);

    // --- Spine with tilt ---
    final spineRad = _rad(angles.spineTilt);
    final hipDx = math.sin(spineRad) * spineLen * 0.4;
    final hipX = cx + hipDx;
    canvas.drawLine(Offset(cx, shoulderY), Offset(hipX, hipY), paint);

    // --- Shoulder line (tilted with spine) ---
    final shoulderDy = math.sin(spineRad) * shoulderLen * 0.25;
    final leftShoulder = Offset(cx - shoulderLen, shoulderY - shoulderDy);
    final rightShoulder = Offset(cx + shoulderLen, shoulderY + shoulderDy);
    canvas.drawLine(leftShoulder, rightShoulder, paint);
    canvas.drawCircle(leftShoulder, 3, jointPaint);
    canvas.drawCircle(rightShoulder, 3, jointPaint);

    // --- Arms ---
    _drawLimb(canvas, paint, jointPaint,
      origin: leftShoulder,
      angle1: _rad(angles.leftShoulder), len1: upperArmLen,
      angle2: _rad(angles.leftElbow), len2: lowerArmLen,
      flipX: true,
    );
    _drawLimb(canvas, paint, jointPaint,
      origin: rightShoulder,
      angle1: _rad(angles.rightShoulder), len1: upperArmLen,
      angle2: _rad(angles.rightElbow), len2: lowerArmLen,
      flipX: false,
    );

    // --- Hips ---
    final leftHip = Offset(hipX - 8, hipY);
    final rightHip = Offset(hipX + 8, hipY);
    canvas.drawLine(leftHip, rightHip, paint);

    // --- Legs ---
    _drawLimb(canvas, paint, jointPaint,
      origin: leftHip,
      angle1: _rad(angles.leftHip), len1: upperLegLen,
      angle2: _rad(angles.leftKnee), len2: lowerLegLen,
      flipX: true, isLeg: true,
    );
    _drawLimb(canvas, paint, jointPaint,
      origin: rightHip,
      angle1: _rad(angles.rightHip), len1: upperLegLen,
      angle2: _rad(angles.rightKnee), len2: lowerLegLen,
      flipX: false, isLeg: true,
    );

    // --- Feet ---
    // Painted as part of leg drawing above.
  }

  void _drawLimb(Canvas canvas, Paint linePaint, Paint dotPaint, {
    required Offset origin,
    required double angle1, required double len1,
    required double angle2, required double len2,
    required bool flipX, bool isLeg = false,
  }) {
    final double dir = flipX ? -1.0 : 1.0;

    // Segment 1 (upper arm / upper leg)
    final dx1 = dir * math.sin(angle1) * len1 * 0.7;
    final dy1 = math.cos(angle1) * len1;
    final elbow = Offset(origin.dx + dx1, origin.dy + dy1);
    canvas.drawLine(origin, elbow, linePaint);
    canvas.drawCircle(elbow, 2.5, dotPaint);

    // Segment 2 (forearm / lower leg)
    final dx2 = dir * math.sin(angle2) * len2 * 0.6;
    final dy2 = math.cos(angle2) * len2;
    final wrist = Offset(elbow.dx + dx2, elbow.dy + dy2);
    canvas.drawLine(elbow, wrist, linePaint);
    canvas.drawCircle(wrist, 2, dotPaint);
  }

  double _rad(double degrees) => degrees * 3.14159 / 180;

  @override
  bool shouldRepaint(covariant PoseStickFigurePainter oldDelegate) {
    return oldDelegate.angles != angles || oldDelegate.color != color;
  }
}
