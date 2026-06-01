# POSS POSS — DeepSeek API 对接设计

## 接口信息

| 项 | 值 |
|----|-----|
| Base URL | `https://api.deepseek.com/v1` |
| 端点 | `POST /chat/completions` |
| 模型 | `deepseek-chat` |
| 鉴权 | `Authorization: Bearer <API_KEY>` |
| Content-Type | `application/json` |
| Vision 支持 | 需要确认当前模型是否支持图片输入 |

## 请求格式

```json
{
  "model": "deepseek-chat",
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "<PROMPT>"
        },
        {
          "type": "image_url",
          "image_url": {
            "url": "data:image/jpeg;base64,<BASE64_IMAGE>"
          }
        }
      ]
    }
  ],
  "response_format": { "type": "json_object" }
}
```

> ⚠ 如果 deepseek-chat 不支持 vision/image_url，则改为：
> - 仅发送图片的场景描述文本（需额外做图片分析）
> - 或换用支持 vision 的模型

## Prompt 设计

```
你是一个专业的人像摄影姿势指导。请分析这张场景照片，为 {N} 个人（年龄段：{AGE}）设计合影站位和姿势。

要求：
- 返回严格 JSON（不要 markdown 标记）
- x/y 是相对于照片的比例值（0.0~1.0）
- 根据场景空间安排合理站位
- 姿势多样化，避免重复
- 左右以被拍者为准

返回格式：
{
  "sceneDescription": "...",
  "suggestions": ["...", "..."],
  "positions": [
    {
      "id": "...",
      "x": 0.5, "y": 0.7,
      "poseName": "...",
      "poseDescription": "...",
      "bodyAngles": {
        "leftShoulder": 0, "rightShoulder": 0,
        "leftElbow": 180, "rightElbow": 180,
        "leftHip": 0, "rightHip": 0,
        "leftKnee": 180, "rightKnee": 180,
        "spineTilt": 0, "headTilt": 0
      },
      "priority": 0
    }
  ]
}
```

## 响应格式

```dart
// 成功响应解析路径：
// response.choices[0].message.content → JSON String → AIPoseResponse

class AIPoseResponse {
  final String sceneDescription;
  final List<String> suggestions;
  final List<PersonPosition> positions;
}
```

## 错误处理

| 错误类型 | 处理方式 |
|----------|----------|
| 无网络 | 自动切换模板模式，提示"当前无网络，使用模板模式" |
| API Key 无效 | 提示"API Key 无效，请检查设置" |
| 请求超时（>30s） | 自动降级模板 |
| 返回 JSON 解析失败 | 重试一次，仍失败则降级模板 |
| 并发限制 | 排队提示"AI 忙线中，请稍后重试" |

## 降级策略

```
AI 请求
  ├→ 成功 → 渲染 AI 结果
  ├→ 失败 → 自动 fallback 模板模式
  │         └→ Toast 提示失败原因
  │         └→ 使用模板结果继续流程
  └→ 超时 → 同上
```

用户始终能看到姿势指引，不会因为 AI 不可用而卡住。

## API Key 管理

- 存储位置：SharedPreferences（本地）
- 设置入口：App 内"设置 → AI 配置"
- 默认无 Key：新用户首次用 AI 需填入 Key
- Key 验证：调用前先小小测试（发送简短请求验证）

## 费用控制

- 每次 AI 调用预估 token 消耗：~2000-5000 tokens
- 画面描述 + 姿势详细参数产生较多输出
- 建议内购定价：10次/$0.99，50次/$2.99，无限/月$4.99
