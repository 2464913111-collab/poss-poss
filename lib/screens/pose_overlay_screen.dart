import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/camera_provider.dart';
import '../providers/pose_provider.dart';
import '../models/person_position.dart';
import '../theme/app_theme.dart';
import '../widgets/pose_stick_figure.dart';
import 'result_screen.dart';

class PoseOverlayScreen extends ConsumerStatefulWidget {
  const PoseOverlayScreen({super.key});

  @override
  ConsumerState<PoseOverlayScreen> createState() => _PoseOverlayScreenState();
}

class _PoseOverlayScreenState extends ConsumerState<PoseOverlayScreen> {
  String? _draggingId;
  final Map<String, Offset> _tmpOffsets = {};
  ui.Image? _decodedImage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _decodeImage();
  }

  Future<void> _decodeImage() async {
    final bytes = ref.read(cameraProvider).imageBytes;
    if (bytes == null || _decodedImage != null) return;

    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    _decodedImage = frame.image;
    if (mounted) setState(() {});
  }

  /// Calculate the render rect of an image with BoxFit.contain inside a container.
  Rect _imageRenderRect(Size container) {
    if (_decodedImage == null) {
      return Offset.zero & container;
    }

    final imgW = _decodedImage!.width.toDouble();
    final imgH = _decodedImage!.height.toDouble();
    if (imgW == 0 || imgH == 0) return Offset.zero & container;

    final scale = (container.width / imgW).compareTo(container.height / imgH) < 0
        ? container.width / imgW   // image wider → constrained by width
        : container.height / imgH; // image taller → constrained by height

    final renderedW = imgW * scale;
    final renderedH = imgH * scale;
    final offsetX = (container.width - renderedW) / 2;
    final offsetY = (container.height - renderedH) / 2;

    return Rect.fromLTWH(offsetX, offsetY, renderedW, renderedH);
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraProvider);
    final poseState = ref.watch(poseProvider);
    final poseNotifier = ref.read(poseProvider.notifier);
    final bytes = cameraState.imageBytes;
    final positions = poseState.positions;

    if (bytes == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.pop(context));
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${positions.length}人 — 可拖拽调整站位',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
                    onPressed: () => poseNotifier.generatePoses(),
                    tooltip: '重新生成',
                  ),
                ],
              ),
            ),

            // Photo + overlays
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final containerSize = Size(constraints.maxWidth, constraints.maxHeight);
                  final imageRect = _imageRenderRect(containerSize);

                  // Person figure size proportional to the actual image height
                  final baseFigureH = imageRect.height * 0.14;

                  return GestureDetector(
                    onTap: () {},
                    child: Stack(
                      children: [
                        // Background image
                        Positioned.fill(
                          child: Image.memory(
                            bytes,
                            fit: BoxFit.contain,
                          ),
                        ),

                        // Pose overlays — positioned within imageRect
                        ...positions.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final pos = entry.value;
                          final isDragging = _draggingId == pos.id;

                          // pos.x / pos.y are 0..1 within the IMAGE, not the container
                          final screenX = imageRect.left + pos.x * imageRect.width;
                          final screenY = imageRect.top + pos.y * imageRect.height;

                          // Scale: larger for closer (higher y in image coords)
                          final scaleFromY = 0.7 + pos.y * 0.6;
                          final figureH = baseFigureH * scaleFromY;

                          return Positioned(
                            left: screenX - figureH * 0.33,
                            top: screenY - figureH * 0.55,
                            child: GestureDetector(
                              onPanStart: (_) {
                                setState(() => _draggingId = pos.id);
                              },
                              onPanUpdate: (details) {
                                setState(() {
                                  _tmpOffsets[pos.id] = (_tmpOffsets[pos.id] ?? Offset.zero) + details.delta;
                                });
                              },
                              onPanEnd: (_) {
                                final offset = _tmpOffsets[pos.id] ?? Offset.zero;
                                // Convert screen delta back to image-relative coordinates
                                final newX = pos.x + offset.dx / imageRect.width;
                                final newY = pos.y + offset.dy / imageRect.height;
                                poseNotifier.movePerson(pos.id, newX, newY);
                                _tmpOffsets.remove(pos.id);
                                setState(() => _draggingId = null);
                              },
                              child: _PoseWidget(
                                position: pos,
                                index: idx,
                                isDragging: isDragging,
                                tmpOffset: _tmpOffsets[pos.id] ?? Offset.zero,
                                figureH: figureH,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom: take photo button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  const Text('调整完毕后点击拍照',
                      style: TextStyle(color: Colors.white38, fontSize: 13)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultScreen(imageBytes: bytes),
                        ),
                      );
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: AppTheme.primary,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual pose widget.
class _PoseWidget extends StatelessWidget {
  final PersonPosition position;
  final int index;
  final bool isDragging;
  final Offset tmpOffset;
  final double figureH;

  const _PoseWidget({
    required this.position,
    required this.index,
    required this.isDragging,
    required this.tmpOffset,
    required this.figureH,
  });

  @override
  Widget build(BuildContext context) {
    // figureW is ~60% of height (normal human proportion)
    final figureW = figureH * 0.6;
    final fontSize = (figureH * 0.12).clamp(8.0, 16.0);
    final arrowSize = (figureH * 0.22).clamp(12.0, 28.0);

    return Transform.translate(
      offset: tmpOffset,
      child: AnimatedScale(
        scale: isDragging ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Arrow
            Icon(Icons.keyboard_arrow_down,
                color: const Color(0xFFA8D8EA), size: arrowSize),

            // Stick figure — sized proportionally to the image
            SizedBox(
              width: figureW,
              height: figureH,
              child: CustomPaint(
                painter: PoseStickFigurePainter(
                  angles: position.bodyAngles,
                  color: isDragging ? AppTheme.aiMode : AppTheme.primary,
                ),
              ),
            ),

            // Pose name tag
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: fontSize * 0.6, vertical: fontSize * 0.2),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(fontSize * 0.8),
              ),
              child: Text(
                '${index + 1}. ${position.poseName}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
