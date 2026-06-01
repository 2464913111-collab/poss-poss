import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/camera_provider.dart';
import '../theme/app_theme.dart';
import 'parameter_screen.dart';

class CameraScreen extends ConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraState = ref.watch(cameraProvider);
    final cameraNotifier = ref.read(cameraProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: cameraState.imageBytes != null
            ? _buildPreview(context, cameraState.imageBytes!, cameraNotifier)
            : _buildPicker(context, cameraNotifier),
      ),
    );
  }

  Widget _buildPicker(BuildContext context, CameraNotifier notifier) {
    return Column(
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 16, top: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
            ],
          ),
        ),

        const Spacer(),

        // Center instruction
        const Icon(Icons.camera_alt_outlined, size: 80, color: Colors.white38),
        const SizedBox(height: 16),
        const Text(
          '拍一张场景照片',
          style: TextStyle(color: Colors.white54, fontSize: 18),
        ),
        const Text(
          '或从相册选择已有照片',
          style: TextStyle(color: Colors.white30, fontSize: 14),
        ),

        const Spacer(),

        // Bottom buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Row(
            children: [
              // Gallery
              Expanded(
                child: GestureDetector(
                  onTap: () => notifier.pickFromGallery(),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library_outlined, color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text('相册', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Camera
              Expanded(
                child: GestureDetector(
                  onTap: () => notifier.pickFromCamera(),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text('拍照', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreview(BuildContext context, Uint8List bytes, CameraNotifier notifier) {
    return Stack(
      children: [
        // Image
        Center(
          child: Image.memory(bytes, fit: BoxFit.contain),
        ),

        // Top bar
        Positioned(
          top: 8, left: 8,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black38,
            ),
          ),
        ),

        // Bottom bar
        Positioned(
          bottom: 40, left: 0, right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Retake
              GestureDetector(
                onTap: () => notifier.reset(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text('重拍', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              ),

              const SizedBox(width: 24),

              // Use photo
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ParameterScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text('使用照片', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
