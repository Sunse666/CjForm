<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v1.0.1-green" style="display: inline-block;" />
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

你会看到一个带按钮的窗口。`src/main.cj` 是你的代码入口，直接改它就行。

## 目录结构

```
MyApp/
├── src/
│   └── main.cj          # 你的代码
├── cjform/              # CJForm 库（不需要动）
│   ├── cjpm.toml
│   └── src/
│       ├── window.cj
│       ├── button.cj
│       ├── text_edit.cj
│       ├── theme.cj
│       ├── style_sheet.cj
│       └── ...
├── bridge.dll           # Win32 / GDI+ 桥接
├── cjpm.toml
└── README.md
```

---

## 编写代码

```cj
// src/main.cj
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
    win.addButton(btn)

    win.show()
    win.run()
    Int64(0)
}
```

使用样式表简化重复参数：

```cj
StyleSheet.getDefault()
    .define("btn", StyleProperties()
        .withFontFamily("Microsoft YaHei")
        .withFontSize(14.0)
        .withSizeScale(SizeScale.scalable())
        .withAnchor(Anchor.Center))

let btn = Button.styled("btn", "Click Me",
    Position.abs(400.0, 300.0), 120.0, 36.0,
    ButtonStyle.fromTheme(), { => println("clicked!") })
```

---

## 控件示例

`examples/` 下每个控件一个独立示例，用 PowerShell 运行：

```powershell
cd examples/button
.\run.ps1
```

或完整列表：

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

---

## 控件列表

| 类别 | 控件 |
|------|------|
| 基础 | Window, Button, Label, TextBox, TextEdit, CheckBox, RadioButton + RadioGroup, Slider |
| 复合 | SpinBox, ToggleSwitch, ProgressBar, ComboBox, MenuBar, ContextMenu, Popover, Tooltip, Image |
| 布局 | VBox, HBox, GroupBox, SplitPane |
| 视图 | ListView, TreeView, TableView, TabView |
| 容器 | ScrollArea |
| 对话框 | MessageBox |
| 系统 | Theme, Animation, StyleSheet, ShortcutManager |

---

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

---

## 软件架构

```
用户 API（Window、Button、TextEdit、Theme、StyleSheet ...）
    ↓
控件层（Widget 树、事件路由、布局计算）
    ↓
Canvas 渲染抽象
    ↓
bridge.dll（C++ Win32 / GDI+ FFI）
```

## 编译 bridge.dll（可选）

仓库已提供预编译的 `bridge.dll`。如需自行编译：

```bash
cd bridge
mkdir build && cd build
cmake .. -G "MinGW Makefiles"
cmake --build . --config Release
cp bridge.dll ../../
```

## 许可证

[GPL-3.0](LICENSE)
