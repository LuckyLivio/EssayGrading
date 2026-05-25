# 申论批改官

一款基于 AI 的申论智能批改应用，支持拍照识别手写作文、历年真题练习、自定义题目录入等功能。

## 功能特性

### 📷 拍照批改
- 拍照或从相册选择手写作文图片
- 自动识别图片中的文字（OCR）
- AI 智能评分，给出详细的批改反馈
- 支持要点覆盖分析、改进建议和范文示例

### 📚 题库中心
- 内置 **150+ 道** 涵盖 2020-2024 年国考及各省真题
- 支持按**题型**（归纳概括、公文写作、大作文）筛选
- 支持按**年份**和**来源省份**精准筛选
- 可联网搜索更多题目资源

### ➕ 自定义题目
- 支持上传个人收集的题目
- 题目自动保存本地，重启 App 后仍在
- 可左滑删除不需要的自定义题目

### 📜 批改历史
- 自动保存每次批改记录
- 可随时回顾历史批改结果
- 支持删除单条记录

### ⚙️ 设置
- 支持配置 **DeepSeek / OpenAI / 任意 OpenAI 兼容接口**
- 可调整批改严格度（1-3档）
- API 地址示例已内置，填写更方便

## 环境要求

- **Flutter SDK**: 3.x 及以上
- **Android**: 最低支持 Android 5.0（API 21）
- 推荐使用 **真机** 调试（部分功能模拟器可能受限）

## 快速开始

### 1. 安装依赖

```bash
flutter pub get
```

### 2. 配置 API Key

> 首次使用需要配置 AI 接口才能进行批改。
> 进入 App → 底部导航"设置"，填写以下信息：

| 字段 | 说明 | 示例 |
|------|------|------|
| **API 地址** | 完整接口地址，需精确到 `/v1/chat/completions` | `https://api.deepseek.com/v1/chat/completions` |
| **API Key** | 你从服务商获取的密钥 | `sk-xxxxxxxx` |
| **模型名称** | 使用的模型名称 | `deepseek-chat` / `gpt-4o` |

> 推荐使用 **DeepSeek**（性价比高，对中文理解好）：
> - API 地址: `https://api.deepseek.com/v1/chat/completions`
> - 模型: `deepseek-chat`

### 3. 运行应用

```bash
# Debug 模式
flutter run

# Release 模式（性能更优）
flutter build apk --release
```

## 项目结构

```
lib/
├── main.dart                      # 应用入口
├── core/
│   ├── constants/
│   │   ├── app_constants.dart    # 全局常量（Storage Key 等）
│   │   └── prompts.dart          # AI 批改提示词
│   └── theme/
│       └── app_theme.dart        # 全局主题配置
├── data/
│   ├── models/
│   │   ├── history_record.dart   # 批改记录数据模型
│   │   └── question.dart         # 题目数据模型（含内置题库）
│   ├── providers/
│   │   └── app_providers.dart    # Riverpod 状态管理
│   └── services/
│       ├── ai_service.dart       # AI 批改服务（调用大模型）
│       ├── ocr_service.dart     # 文字识别服务（Google ML Kit）
│       └── storage_service.dart  # 本地存储服务（Hive）
└── ui/
    └── screens/
        ├── grading_screen.dart   # 批改主页面
        ├── history_screen.dart   # 历史记录页面
        ├── main_screen.dart      # 主框架（底部导航）
        ├── question_bank_screen.dart  # 题库页面
        ├── result_screen.dart   # 批改结果页面
        └── settings_screen.dart  # 设置页面
```

## 核心技术

| 技术 | 用途 |
|------|------|
| **Riverpod** | 状态管理 |
| **Google ML Kit** | 手写文字识别（OCR） |
| **Dio** | HTTP 网络请求（调用 AI 接口） |
| **Hive** | 本地数据持久化 |
| **url_launcher** | 联网搜索题目 |

## 常见问题

### Q: 批改时提示"网络请求失败 404"
**A:** 这是因为 API 地址填写不完整。请确保填写的是完整的聊天补全地址（包含 `/v1/chat/completions`），而不是仅填域名。

### Q: 拍照后闪退
**A:** 请确保在手机上允许了摄像头和存储权限。另外部分机型的系统裁剪界面与本 App 不兼容，已做规避处理。

### Q: OCR 识别不准确
**A:** 拍照时请确保：
- 光线充足
- 字迹清晰无遮挡
- 尽量平整放置纸张

### Q: 如何添加更多题目？
**A:** 有两种方式：
1. 在题库页面点击右上角 **"+"** 按钮，手动上传
2. 使用题库页右上角 **放大镜图标**，联网搜索后参考复制

## 更新日志

### v1.1.0
- 新增内置 150+ 道国考及各省历年真题
- 题库支持按题型/年份/来源省份筛选
- 支持自定义题目的上传、存储和删除
- 新增联网搜索题目功能
- UI 全面优化（环形分数、卡片布局、空状态提示）
- 完善错误处理与用户提示

### v1.0.x
- 初始版本，支持拍照 OCR + AI 批改核心流程

## 免责声明

本应用中的内置题库题目均来源于互联网公开资源，仅供学习交流使用，不以任何形式盈利。如有侵权请联系删除。
