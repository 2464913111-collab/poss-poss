import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Manages camera / image picking state.
class CameraNotifier extends StateNotifier<CameraState> {
  final ImagePicker _picker = ImagePicker();

  CameraNotifier() : super(CameraState());

  Future<void> pickFromCamera() async {
    final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 90);
    if (file != null) {
      final bytes = await file.readAsBytes();
      state = state.copyWith(imageBytes: bytes, isReady: true);
    }
  }

  Future<void> pickFromGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (file != null) {
      final bytes = await file.readAsBytes();
      state = state.copyWith(imageBytes: bytes, isReady: true);
    }
  }

  void reset() {
    state = CameraState();
  }
}

class CameraState {
  final Uint8List? imageBytes;
  final bool isReady;

  CameraState({this.imageBytes, this.isReady = false});

  CameraState copyWith({Uint8List? imageBytes, bool? isReady}) {
    return CameraState(
      imageBytes: imageBytes ?? this.imageBytes,
      isReady: isReady ?? this.isReady,
    );
  }
}

final cameraProvider = StateNotifierProvider<CameraNotifier, CameraState>((ref) {
  return CameraNotifier();
});
