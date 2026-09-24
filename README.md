# EssayGrading｜申论批改官

一款 Flutter 练习应用：用手机拍照或选择图片，经中文 OCR 提取文字，再把答案与题目发送给用户配置的 AI 接口，展示结构化批改结果。适合演示图像识别、接口集成和本地记录的完整数据流；批改结果是模型反馈，不能视为官方评分。

## 代码中已实现的流程

- 拍照/相册选图、裁剪后调用 Google ML Kit 中文文字识别；识别失败会提示重新选择更清晰的图片。
- 按题型组织提示词，向 OpenAI 兼容聊天接口请求 JSON 批改结果；支持在设置页填写接口地址、模型和密钥，并调整批改严格度。
- 在本地 Hive 存储设置、自定义题目和批改历史；题库中另有静态练习条目，可按条件浏览。

实现入口在 [`lib/main.dart`](lib/main.dart)；核心逻辑可看 [`ocr_service.dart`](lib/data/services/ocr_service.dart)、[`ai_service.dart`](lib/data/services/ai_service.dart) 和 [`storage_service.dart`](lib/data/services/storage_service.dart)。仓库没有记录多人开发的职责分工，个人负责范围需作者确认。

## 面试可讲的技术点

1. **OCR 到批改的误差传递**：图片质量影响文字识别，识别文本再影响 AI 评价；演示时应展示中间文字并允许人工核对。
2. **接口与本地状态**：客户端配置可替换的模型端点，解析结构化 JSON 并保存历史；错误处理覆盖未配置密钥、超时和常见 HTTP 状态。

## 运行与体验

需要 Flutter 3.x、Android SDK 和模拟器或 Android 真机。仓库根目录执行：

```bash
flutter pub get
flutter run
```

首次打开后，在设置页填入**自己的**兼容接口地址、模型和 API Key，才能使用 AI 批改。OCR 依赖设备端运行环境。仓库未提供可验证的在线演示或公开截图。

## 边界与待验证项

- 静态题库是应用内练习素材，仓库未提供来源与真题逐条核验记录，不能当作官方真题库宣传。
- API Key 保存在应用本地 Hive 设置中；共享设备上请清除应用数据，不要把密钥写进仓库。
- 目前未看到与实际批改流程对应的自动化测试；仓库中的 `test/widget_test.dart` 仍为 Flutter 计数器模板。不同手写风格、模型输出格式和 Android 设备兼容性仍需实测。
