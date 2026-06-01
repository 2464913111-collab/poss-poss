# POSS POSS — 技术规范

## 运行环境

| 项 | 要求 |
|----|------|
| Flutter SDK | 3.29+ (stable) |
| Dart SDK | 3.7+ |
| Android min SDK | 21 (Android 5.0) |
| iOS min | 15.0 |
| 开发工具 | VS Code + Flutter 插件 或 Android Studio |

## 依赖包

```yaml
dependencies:
  flutter:
    sdk: flutter
  # 状态管理
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

  # 相机与图片
  camera: ^0.11.1
  image_picker: ^1.1.2
  image: ^4.5.3
  permission_handler: ^11.3.1

  # 本地存储
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.5

  # 网络
  http: ^1.2.2
  connectivity_plus: ^6.1.0

  # UI
  google_fonts: ^6.2.1
  cached_network_image: ^3.4.1

  # 工具
  uuid: ^4.5.1
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.13
  json_serializable: ^6.9.4
  riverpod_generator: ^2.6.3
  isar_generator: ^3.1.0+1
```

## 数据模型

### PersonPosition
```dart
class PersonPosition {
  final String id;        // UUID
  double x;               // 站位 X 比例 (0.0~1.0)
  double y;               // 站位 Y 比例 (0.0~1.0)
  final String poseName;  // 姿势名称
  final String poseDesc;  // 姿势描述
  final BodyAngles bodyAngles; // 关节角度
  final int priority;     // 前后排 (0=最前)
}
```

### BodyAngles
```dart
class BodyAngles {
  final double leftShoulder, rightShoulder;
  final double leftElbow, rightElbow;
  final double leftHip, rightHip;
  final double leftKnee, rightKnee;
  final double spineTilt, headTilt;
  // 单位：度 (°)
  // 0° = 自然下垂，90° = 水平，180° = 完全伸展
}
```

### PoseTemplate
```dart
class PoseTemplate {
  final String id;
  final String name;
  final int peopleCount;
  final List<String> ageGroups;
  final String style;        // formal/casual/creative
  final List<PersonPosition> positions;
  final String layoutDesc;
}
```

### SceneAnalysis
```dart
class SceneAnalysis {
  final String id;
  final String source;       // "template" / "ai"
  final List<PersonPosition> positions;
  final String? sceneDesc;
  final List<String>? suggestions;
  final DateTime createdAt;
}
```

## 状态管理架构（Riverpod）

```
                                    ┌─────────────────┐
                                    │   cameraProvider  │
                                    │  (相机状态+拍照)   │
                                    └────────┬────────┘
                                             │
                    ┌────────────────────────┼────────────────────────┐
                    │                        │                        │
          ┌────────▼────────┐    ┌──────────▼──────────┐    ┌───────▼───────┐
          │  poseProvider    │    │  parameterProvider   │    │ historyProvider│
          │ (姿势生成+调整)   │    │  (人数/年龄/风格)     │    │ (历史记录CRUD)  │
          └────────┬────────┘    └─────────────────────┘    └───────────────┘
                   │
       ┌───────────┼───────────┐
       │                       │
┌──────▼──────┐    ┌───────────▼──────┐
│ TemplateSvc │    │   DeepSeek API    │
│  (离线匹配)  │    │   (AI 分析)       │
└─────────────┘    └──────────────────┘
```

## 文件命名规范

- **文件**：snake_case（`camera_service.dart`）
- **类名**：PascalCase（`CameraService`）
- **变量/函数**：camelCase（`takePhoto()`）
- **常量**：camelCase（`primaryColor`）
- **目录**：snake_case（`daily_logs/`）

## 错误处理策略

- 网络请求失败 → 自动降级到模板模式
- 相机权限拒绝 → 显示引导页跳转系统设置
- 模板匹配失败 → 返回兜底模板
- 所有异常必须 catch，不允许 App 崩溃
