<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v1.4.0-green" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-green" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v1.0.5-green" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/platform-Windows%20x64-blue" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/license-GPL--3.0-orange" style="display: inline-block;" />
</p>

## 介绍

CJForm 是仓颉语言的 Windows 原生 UI 库。通过 C++ 桥接 Win32 API / GDI+，全部控件自绘。

Clone 即用，无需额外配置。

## 环境要求

- Windows 10 / 11 64 位
- 仓颉工具链（cjc ≥ 1.0.5）

## 快速开始

```bash
git clone https://github.com/Sunse666/CjForm.git MyApp
cd MyApp
cjpm run
```

你会看到一个控件演示窗口。`src/main.cj` 是代码入口。

## 目录结构

```
MyApp/
├── src/
│   └── main.cj              # 控件演示入口
├── cjform/                  # CJForm 库
│   ├── cjpm.toml
│   └── src/
│       ├── widget.cj        # Widget 接口
│       ├── window.cj        # 窗口、事件循环、渲染
│       ├── canvas.cj        # 绘制抽象
│       ├── bridge.cj        # FFI 声明
│       ├── ffi_safe.cj      # 安全 FFI 封装
│       ├── focus_manager.cj # 焦点管理 + Focusable 接口
│       ├── theme.cj         # 主题（Dark/Light）
│       ├── style_sheet.cj   # 样式表
│       ├── layout.cj        # 布局引擎
│       ├── event.cj         # 事件系统
│       ├── button.cj        # 按钮
│       ├── text_box.cj      # 单行输入
│       ├── text_edit.cj     # 多行编辑器
│       ├── check_box.cj     # 复选框
│       ├── radio_button.cj  # 单选按钮 + RadioGroup
│       ├── slider.cj        # 滑块
│       ├── toggle_switch.cj # 开关
│       ├── progress_bar.cj  # 进度条
│       ├── spin_box.cj      # 数字步进器
│       ├── combo_box.cj     # 下拉选择
│       ├── status_bar.cj    # 状态栏
│       ├── link_label.cj    # 超链接标签
│       ├── toolbar.cj       # 工具栏
│       ├── list_view.cj     # 列表视图
│       ├── tree_view.cj     # 树形视图
│       ├── table_view.cj    # 表格视图
│       ├── tab_view.cj      # 标签页
│       ├── scroll_area.cj   # 滚动区域
│       ├── group_box.cj     # 分组框
│       ├── split_pane.cj    # 分割面板
│       ├── menu_bar.cj      # 菜单栏
│       ├── context_menu.cj  # 右键菜单
│       ├── dialogs.cj       # 对话框 + 快捷键管理
│       └── ...
├── bridge/                  # C++ 桥接层（9 个模块）
│   ├── bridge_common.h      # 共享头文件
│   ├── window.cpp           # 窗口创建、消息泵
│   ├── render.cpp           # GDI+ 渲染
│   ├── events.cpp           # 输入事件
│   ├── edit.cpp             # 原生 Edit 控件
│   ├── clipboard.cpp        # 剪贴板
│   ├── config.cpp           # INI配置 
│   ├── image.cpp            # 图片加载
│   ├── dialog.cpp           # 文件对话框
│   └── util.cpp             # 工具函数
├── bridge.dll               # 预编译桥接 DLL
├── cjpm.toml
└── README.md
```

## 编写代码

```cj
package myapp

import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("Hello CJForm", 800, 600)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let btn = Button("Click Me",
        Position.abs(400.0, 300.0), 120.0, 36.0,
        "Microsoft YaHei", 14.0, SizeScale.scalable(), Anchor.Center,
        ButtonStyle.fromTheme(), { => println("clicked!") })
    win.addWidget(btn)

    win.show()
    win.run()
    Int64(0)
}
```

## 统一回调 API

所有交互控件支持 `onXxx()` 链式回调：

```cj
// 按钮
btn.onClick() { println("clicked") }

// 复选框
cb.onToggle() { checked => println("checked: ${checked}") }

// 滑块
slider.onValueChanged() { v => println("value: ${v}") }
      .onHover() { showTooltip() }

// 单选按钮组
radioGroup.onSelectionChanged() { idx => println("selected: ${idx}") }

// 超链接
LinkLabel("GitHub", pos, "Segoe UI", 14.0, SizeScale.fixed(), Anchor.CenterLeft,
    { => println("link clicked") })
```

## 控件列表

| 类别 | 控件 |
|------|------|
| 基础 | Window, Button, Label, TextBox, TextEdit, CheckBox, RadioButton + RadioGroup, Slider |
| 复合 | SpinBox, ToggleSwitch, ProgressBar, ComboBox, StatusBar, MenuBar, ContextMenu, Popover, Toolbar, LinkLabel, Tooltip, Image |
| 布局 | VBox, HBox, GroupBox, SplitPane, Toolbar |
| 视图 | ListView, TreeView, TableView, TabView |
| 容器 | ScrollArea |
| 对话框 | MessageBox, FileDialog |
| 系统 | Theme, Animation, StyleSheet, ShortcutManager |

## Theme / StyleSheet 概览

```cj
// 主题切换
Theme.setCurrent(Theme.dark())
Theme.setCurrent(Theme.light())
Theme.toggle()

let c = Theme.colors()

// 样式表
StyleSheet.getDefault()
    .define("btn", StyleProperties()
        .withFontFamily("Microsoft YaHei")
        .withFontSize(14.0)
        .withSizeScale(SizeScale.scalable())
        .withAnchor(Anchor.Center))
```

## 示例

`examples/` 下每个控件一个独立示例，外加一个翻牌记忆游戏：

| 示例 | 说明 |
|------|------|
| `button` | 三种按钮样式 |
| `text_box` | 文本输入 / 密码 / 搜索 |
| `text_edit` | 多行编辑器 |
| `check_box` | 多选框 |
| `radio_button` | 单选按钮组 |
| `slider` | 滑块 |
| `toggle_switch` | 开关 |
| `progress_bar` | 进度条 |
| `spin_box` | 数字步进器 |
| `combo_box` | 下拉选择 |
| `list_view` | 列表视图 |
| `tree_view` | 树形视图 |
| `table_view` | 表格视图 |
| `tab_view` | 标签页 |
| `scroll_area` | 滚动区域 |
| `group_box` | 分组框 |
| `split_pane` | 分割面板 |
| `menu_bar` | 菜单栏 |
| `context_menu` | 右键菜单 |
| `dialog` | 对话框 |
| `theme` | 主题切换 |
| `stylesheet` | 样式表 |
| `gallery` | 控件总览 |
| `memory_game` | 翻牌记忆游戏（5x5 矩阵，60 秒限时） |

运行示例：

```powershell
cd examples/button
cjpm run

# 翻牌记忆游戏
cd examples/memory_game
cjpm run
```

## 软件架构

```
用户 API（Window、Button、TextEdit、Theme、StyleSheet ...）
    ↓
控件层（Widget 树、事件路由、布局计算）
    ↓
ffi_safe.cj — 安全 FFI 封装（CString 管理）
    ↓
bridge.cj — 外部函数声明
    ↓
bridge.dll（C++ Win32 / GDI+ FFI，拆分为 9 个模块）
```

## v1.4 更新

- 统一回调系统：所有控件支持 `onClick()` / `onToggle()` / `onValueChanged()` 等链式 API
- 新控件：StatusBar, LinkLabel, Toolbar
- FocusManager 扩展：TextEdit, SpinBox, ComboBox 加入 Tab 序列
- Bridge 重构：898 行单体拆分为 9 个模块
- 安全 FFI 封装：CString 管理集中在 ffi_safe.cj，控件层零 unsafe
- 错误处理：窗口创建/GDI+ 初始化失败打印诊断
- 高 DPI：自动字体缩放，窗口不模糊
- 翻牌记忆游戏示例（60 秒限时、进度条、Joker 卡）
- Window API 统一：10 个 addXxx() 合并为 addWidget()
- 容器事件委托补全

## 编译 bridge.dll（可选）

仓库已提供预编译的 `bridge.dll`。如需自行编译：

```bash
cd bridge
mkdir build && cd build
cmake .. -G "MinGW Makefiles"
cmake --build . --config Release
cp bridge.dll ../../ && cp libbridge.dll.a ../../
```

## 许可证

[GPL-3.0](LICENSE)
