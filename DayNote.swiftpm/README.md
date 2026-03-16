# DayNote 📝

DayNote 是一款基于 SwiftUI 和 SwiftData 构建的极简主义、对话式纯文本日记与笔记应用。它打破了传统日记本的沉闷排版，采用类似聊天软件的信息流界面，让记录日常想法像发微信一样轻松自然。同时，DayNote 采用了最新的 Apple Design System 设计规范，提供原生的现代 iOS 视觉体验。

## ✨ 核心特性

- 💬 **对话式记录体验**：以聊天气泡的形式记录每日点滴，轻量快捷，减轻写作压力。
- 🎨 **极致原生 UI**：全面采用毛玻璃效果（Ultra Thin Material）、丝滑的过渡动画与圆角卡片设计，完美的现代 iOS 风格。
- ☁️ **iCloud 无缝同步**：基于 SwiftData，数据在你的所有 Apple 设备间自动云端同步（需在设置中开启）。
- ⏰ **每日习惯提醒**：自定义每日推送提醒时间，帮助你养成坚持记录的好习惯。
- 🤖 **智能 AI 摘要**：内置强大的「摘要」生成功能。你可以配置自己的 AI API Key 生成智能摘要，或在未配置时使用本地基础摘要总结你的一天。
- 🔍 **全局快速搜索**：优雅的独立搜索界面，支持通过关键词迅速定位过往记忆。
- 📅 **历史时间线**：通过「浏览」模块，按时间线回顾过往每一天的心路历程。

## 🛠 技术栈

完全采用 Apple 原生现代化技术栈开发：
- **UI 框架**: SwiftUI
- **数据存储**: SwiftData (自带 iCloud 自动同步能力)
- **依赖管理**: Swift Package Manager (Playgrounds `.swiftpm` 格式，可在 iPad Playgrounds 或 Mac Xcode 直接打开运行)
- **系统要求**: iOS 17.0+ / macOS 14.0+ 

## 🚀 快速运行

本项目打包为 `.swiftpm` 格式，对轻量级开发者极为友好。

1. **方式一：iPad / Mac Playgrounds**
   - 直接双击 `DayNote.swiftpm` 文件夹，或使用 Apple 的 Swift Playgrounds App 打开该项目。
   - 点击运行即可在设备上直接体验。

2. **方式二：Xcode**
   - 使用 Xcode 15+ 打开 `DayNote.swiftpm` 文件夹。
   - 选择任意 iOS 模拟器或真机，点击 `Run`。

## ⚙️ 个性化配置 (配置 AI 摘要)

DayNote 支持接入大语言模型为每日笔记生成智能总结：
1. 打开 App，点击底部导航栏进入 **「设置」** 页面。
2. 找到 **「智能摘要」** 卡块。
3. 开启 AI 摘要选项，并在下方填入你专属的 API Key。
4. 回到「今天」页面，点击顶部右上角的 ✨ **摘要** 按钮，即可体验 AI 生成的当日总结！

## 🤝 贡献与反馈

欢迎提交 Issue 报告 Bug 或者提出令人激动的新功能建议！如果你有代码改进，也欢迎直接提交 Pull Request。

---

*Made with ❤️ by Agseanic*
