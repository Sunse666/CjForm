# CJForm — 仓颉 Windows 原生 UI 库

用仓颉语言写 Windows 桌面应用。C++ 桥接 Win32 / GDI+，全部控件自绘

## 架构

```
用户 API（Window、Button、TextEdit、Theme ...）
    ↓
控件层（Widget 树、事件路由、布局计算）
    ↓
Canvas 渲染抽象
    ↓
bridge.dll（C++ Win32 / GDI+ FFI）
```

## 快速开始

### 1. 准备文件

将仓库中以下内容复制到你的项目目录：

```
your-app/
├── src/                   # 你的代码
│   └── main.cj
├── cjform/                # CJForm 库（从本仓库 src/ 复制）
│   ├── animation.cj
│   ├── bridge.cj
│   ├── button.cj
│   ├── ...（所有 .cj 文件）
│   └── widget.cj
├── bridge.dll             # 预编译 DLL（从本仓库直接复制）
├── bridge/                # C++ 源码（可选，需要自己编译时保留）
│   ├── bridge.cpp
│   └── CMakeLists.txt
└── cjpm.toml
```

> 没有 CMake 可用仓库里编译好的 `bridge.dll`

### 2. 配置 cjpm.toml

```toml
[package]
  cjc-version = "1.0.5"
  name = "myapp"
  version = "0.1.0"
  output-type = "executable"
  link-option = "-L. -lbridge --subsystem windows"

[dependencies]
```

### 3. 编写代码

```cj
// src/main.cj
package myapp

import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("Hello CJForm", 800, 600)
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

### 4. 运行

```bash
cjpm run
```

## 自己编译 bridge.dll

```bash
cd bridge
mkdir build && cd build
cmake .. -G "MinGW Makefiles"
cmake --build . --config Release
cp bridge.dll ../../
```

## 控件

| 类别 | 控件 |
|------|------|
| 基础 | Button、Label、TextBox、PasswordBox、CheckBox、RadioButton、Slider、SpinBox |
| 文本 | TextEdit |
| 容器 | VBox、HBox、GroupBox、SplitPane、ScrollArea、TabView |
| 列表 | ListView、TreeView、TableView |
| 弹出 | ComboBox、ContextMenu、Popover、Tooltip |
| 菜单 | MenuBar |
| 视觉 | ProgressBar、ToggleSwitch、Separator、Image |
| 对话框 | MessageBox、FileDialog |
| 主题 | Theme |
| 动画 | AnimationState、Easing、lerp、lerpColor |
| 快捷键 | ShortcutManager |

## 路线图

详见 [cjform.md](cjform.md)。

## 许可证

[GPL-3.0](LICENSE)
