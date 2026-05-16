<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v1.0.0-green" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-green" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v1.0.5-green" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/platform-Windows%20x64-blue" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/license-GPL--3.0-orange" style="display: inline-block;" />
</p>

## 介绍

CJForm 是仓颉语言的 Windows 原生 UI 库。通过 C++ 桥接 Win32 API / GDI+，全部控件自绘

项目基于 Windows 环境构建和测试，要求 64 位系统。


## 软件架构

```
用户 API（Window、Button、TextEdit、Theme ...）
    ↓
控件层（Widget 树、事件路由、布局计算）
    ↓
Canvas 渲染抽象
    ↓
bridge.dll（C++ Win32 / GDI+ FFI）
```

### 源码目录

```
.
├── README.md
├── cjpm.toml
├── bridge.dll                # 预编译 DLL
├── src/                      # 仓颉库源码
│   ├── window.cj
│   ├── widget.cj
│   ├── button.cj
│   ├── text_edit.cj
│   ├── theme.cj
│   ├── ...                   # 控件文件
│   └── main.cj               # 控件演示程序
└── bridge/                   # C++ 桥接源码
    ├── bridge.cpp
    └── CMakeLists.txt
```

- `src/` 库源码，包含所有控件、布局、主题、事件系统
- `bridge/` C++ 桥接源码，封装 Win32 窗口管理、GDI+ 绘制、COM 对话框


## 编译执行

### 环境要求

- Windows 10 / 11 64 位
- 仓颉工具链（cjc ≥ 1.0.5）
- CMake + MinGW-w64（仅编译 bridge.dll 时需要）

### 编译 bridge.dll（可选）

仓库已提供预编译的 `bridge.dll`，可直接使用。如需自行编译：

```bash
cd bridge
mkdir build && cd build
cmake .. -G "MinGW Makefiles"
cmake --build . --config Release
cp bridge.dll ../../
```

### 编译 CJForm 项目

```bash
# 克隆仓库
git clone https://github.com/Sunse666/CjForm.git
cd CjForm

# 编译
cjpm build

# 运行控件演示程序
cjpm run
```

### 项目使用

将 `src/` 下所有 `.cj` 文件复制到你的项目目录，同时复制 `bridge.dll`。

**1. 准备文件**

```
myapp/
├── src/
│   └── main.cj
├── cjform/                   # 从 CJForm 仓库 src/ 复制
│   ├── window.cj
│   ├── widget.cj
│   ├── button.cj
│   └── ...
├── bridge.dll                # 从 CJForm 仓库复制
└── cjpm.toml
```

```bash
cjpm init
```

```bash
# 假设 CJForm 克隆到了 ~/CjForm
cp -r ~/CjForm/src ./cjform
cp ~/CjForm/bridge.dll ./
```

**2. 配置 cjpm.toml**

```toml
[package]
  cjc-version = "1.0.5"
  name = "myapp"
  version = "0.1.0"
  output-type = "executable"
  link-option = "-L. -lbridge --subsystem windows"

[dependencies]
```

**3. 编写代码**

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
    win.addButton(btn)

    win.show()
    win.run()
    Int64(0)
}
```

**4. 运行**

```bash
cjpm run
```

## 许可证

[GPL-3.0](LICENSE)
