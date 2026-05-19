---
icon: material/home
---

# CJForm

!!! tip "温馨提示"

    CJForm 是仓颉语言的 Windows 原生 UI 库，全部控件自绘，Clone 即用。

    - [x] 您可以通过按下 ++left++ 和 ++right++ 来快速跳转到上一页和下一页！
    - [x] 您可以通过点击页面顶部搜索栏或按下快捷键 <kbd>/</kbd> 来快速查找想要的内容！
    - [x] 您可以通过点击页面顶部主题按钮来切换网站主题，不同主题带来不同的心情！

    最后，祝您阅读愉快！ :heart:

## 简介

CJForm 是**仓颉语言（Cangjie）**的 Windows 原生 UI 库。通过 C++ 桥接层调用 Win32 API / GDI+，全部控件自绘，不依赖任何第三方 UI 框架。

提供 Dark / Light 双主题、声明式 StyleSheet 系统、完整的布局引擎和动画系统，覆盖 25+ 种常用控件。

## 核心功能

=== "自绘控件"

    25+ 种常用控件全部自绘，不依赖 Windows 原生控件，外观统一可控。

=== "双主题"

    内置 Dark / Light 主题，支持运行时一键切换，所有控件颜色自动响应。

=== "声明式样式"

    StyleSheet 系统类似 CSS class，定义一次，多处复用，减少重复参数。

=== "布局引擎"

    VBox / HBox 弹性布局，支持 LayoutFrame 精确控制，适配窗口缩放。

=== "动画系统"

    缓动函数 + 颜色插值，悬停、点击动画平滑流畅。

=== "数据视图"

    ListView / TreeView / TableView / TabView 完整数据展示能力。

## 快速链接

<div class="grid cards" markdown>

-   :fontawesome-solid-rocket: **快速开始**

    ---

    Clone 即用，10 分钟跑起第一个 CJForm 应用

    [:octicons-arrow-right-24: 开始使用](getting-started.md)

-   :fontawesome-brands-github: **GitHub 仓库**

    ---

    查看源代码，提交 Issue 或 PR

    [:octicons-arrow-right-24: 前往仓库](https://github.com/Sunse666/CjForm)

-   :material-widgets: **控件参考**

    ---

    25+ 种控件的完整 API 和示例代码

    [:octicons-arrow-right-24: 查看控件](controls.md)

-   :material-palette: **主题系统**

    ---

    Dark / Light 主题配置和自定义

    [:octicons-arrow-right-24: 查看主题](theme.md)

</div>

## 系统要求

- 操作系统：**Windows 10 / 11 64 位**
- 工具链：**仓颉工具链（cjc >= 1.0.5）**
- 无需额外配置，Clone 即用

## 开始使用

```bash
git clone https://github.com/Sunse666/CjForm.git MyApp
cd MyApp
cjpm run
```

<div align="center" markdown>
[快速开始](getting-started.md){ .md-button }
[基本使用](basics.md){ .md-button }
[控件参考](controls.md){ .md-button }
[架构说明](architecture.md){ .md-button }
</div>
