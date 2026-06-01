# CLAUDE.md — POSS POSS 项目 AI 助手指引

## 项目简介

POSS POSS 是一款 Flutter 跨平台拍照姿势指导 App，帮助不懂摆姿势的用户拍出好看合照。主色淡蓝，UI 极简。

## 关键文件路径

| 用途 | 路径 |
|------|------|
| 📋 产品需求文档 | [docs/requirements.md](docs/requirements.md) |
| 🔧 技术规范 | [docs/tech-specs.md](docs/tech-specs.md) |
| 🎨 UI 设计规范 | [docs/design-standards.md](docs/design-standards.md) |
| 📝 开发执行步骤 | [docs/execution-steps.md](docs/execution-steps.md) |
| 🔗 API 对接设计 | [docs/api-design.md](docs/api-design.md) |
| 📅 每日开发日志 | [daily-logs/](daily-logs/)（文件名为 YYYY-MM-DD.md） |
| 📐 总体方案 | `C:\Users\Administrator\.claude\plans\apple-store-poss-poss-ui-replicated-castle.md` |

## 工作纪律（必须遵守）

1. **小步推进**：每次只做 2-3 个关联功能点，不要一口气写几千行代码
2. **先确认再执行**：涉及架构/方案变化的，先和用户沟通再动手
3. **每步可运行**：每次改动后 `flutter run -d chrome` 确认不报错
4. **写完记日志**：每天收工前更新 `daily-logs/YYYY-MM-DD.md`
5. **参考文档**：做 UI 先读 `design-standards.md`，做功能先读 `requirements.md`，做 API 先读 `api-design.md`
6. **不要重复造轮子**：修改前先搜索已有代码，能复用的不复写
7. **用户是小白的视角**：解释技术问题时用通俗语言，不拽术语

## 每日收工流程

```
1. flutter run -d chrome 确认无报错
2. 更新 daily-logs/YYYY-MM-DD.md（今日完成 + 问题 + 明日计划）
3. git add + git commit（如有改动）
```

## 常用命令

```bash
# 基础
flutter doctor                  # 检查环境
flutter pub get                 # 安装依赖
flutter run -d chrome           # Chrome 浏览器预览（最常用）
flutter run -d <device>         # 指定设备

# 代码生成
dart run build_runner build     # 生成 Riverpod/Isar 代码

# 构建
flutter build apk --debug       # Android 测试包
flutter build ios --release     # iOS 正式包（需 Mac）

# 清理
flutter clean                   # 清理构建缓存
```

## 项目目录速查

```
POSS-POSS/
├── docs/                        ← 📄 所有标准文档（需求/技术/设计/步骤/API）
├── daily-logs/                  ← 📅 每日开发日志
├── lib/                         ← 💻 所有 Dart 源代码
│   ├── main.dart                ← 入口
│   ├── app.dart                 ← MaterialApp + 主题
│   ├── models/                  ← 数据模型
│   ├── services/                ← 业务逻辑
│   ├── providers/               ← Riverpod 状态
│   ├── screens/                 ← 页面
│   ├── widgets/                 ← 可复用组件
│   ├── theme/                   ← 主题配置
│   └── utils/                   ← 工具函数
├── assets/                      ← 图片/JSON资源
└── Sources/                     ← （旧）Swift 代码参考，不参与 Flutter 构建
```

## 历史记录

- **2026-05-30**：初次沟通需求，确定功能、UI、定价
- **2026-05-31**：Swift → Flutter 技术栈切换，建立文档体系，创建 CLAUDE.md
