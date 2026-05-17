<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v1.0.1-green" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-green" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v1.0.5-green" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/platform-Windows%20x64-blue" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/license-GPL--3.0-orange" style="display: inline-block;" />
</p>

## 介绍

CJForm 是仓颉语言的 Windows 原生 UI 库。通过 C++ 桥接 Win32 API / GDI+，全部控件自绘。

## 环境要求

- Windows 10 / 11 64 位
- 仓颉工具链（cjc ≥ 1.0.5）

## 快速开始

### 1. 创建项目

```bash
cjpm init
```

### 2. 配置 cjpm.toml

```toml
[package]
  cjc-version = "1.0.5"
  name = "myapp"
  version = "0.1.0"
  output-type = "executable"
  link-option = "-L. -lbridge --subsystem windows"

[dependencies]
cjform = { git = "https://github.com/Sunse666/CjForm.git" }
```

### 3. 下载 bridge.dll

PowerShell：

```powershell
Invoke-WebRequest -Uri "https://github.com/Sunse666/CjForm/raw/main/bridge.dll" -OutFile "bridge.dll"
```

### 4. 编写代码

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

### 5. 运行

```bash
cjpm run
```

---

## 手动安装（离线 / 本地路径）

```bash
git clone https://github.com/Sunse666/CjForm.git
```

```toml
# cjpm.toml
[dependencies]
cjform = { path = "../CjForm" }
```

---

## 目录结构

```
myapp/
├── src/
│   └── main.cj
├── bridge.dll
└── cjpm.toml
```

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

## 源码目录

```
.
├── src/                     # 库源码
│   ├── window.cj
│   ├── widget.cj
│   ├── button.cj
│   ├── text_edit.cj
│   ├── theme.cj
│   ├── style_sheet.cj
│   └── ...
├── gallery/                 # 控件演示程序
│   ├── cjpm.toml
│   └── src/main.cj
├── bridge.dll
├── bridge/                  # C++ 桥接源码
├── cjpm.toml
└── README.md
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
