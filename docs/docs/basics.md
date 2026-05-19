# 基本使用

## 窗口

### 创建窗口

```cj
let win = Window("My App", 800, 600)
```

### 窗口属性

| 方法 | 说明 |
|------|------|
| `setMinSize(w, h)` | 设置最小窗口尺寸 |
| `setResizable(true/false)` | 设置是否可调整大小 |
| `setAlwaysOnTop(true/false)` | 设置是否置顶 |
| `setNoTitleBar(true/false)` | 设置是否隐藏标题栏 |
| `setBackgroundColor(color)` | 设置背景颜色 |

### 窗口生命周期

```cj
win.show()        // 显示窗口
let result = win.run()  // 进入消息循环，阻塞直到窗口关闭
```

### 文件拖放

```cj
win.setOnFileDrop({ files =>
    for (f in files) {
        println("Dropped: ${f}")
    }
})
```

### 右键菜单

```cj
let ctxMenu = ContextMenu()
ctxMenu.addItem(MenuItem("About", { => println("About") }, "", true))
win.setContextMenu(ctxMenu)
```

---

## Position 定位

```cj
// 绝对定位（像素坐标）
Position.abs(400.0, 300.0)

// 百分比定位（相对窗口的百分比）
Position.pct(0.5, 0.3)
```

---

## Anchor 锚点

控件以 Position 为基准的对齐方式：

| 值 | 说明 |
|----|------|
| `Anchor.Center` | 居中定位 |
| `Anchor.CenterLeft` | 垂直居中，水平靠左 |
| `Anchor.CenterRight` | 垂直居中，水平靠右 |
| `Anchor.TopLeft` | 左上角定位 |
| `Anchor.TopCenter` | 顶部居中 |
| `Anchor.TopRight` | 右上角定位 |

---

## SizeScale 缩放

| 值 | 说明 |
|----|------|
| `SizeScale.scalable()` | 随窗口等比缩放 |
| `SizeScale.fixed()` | 固定大小，不随窗口缩放 |

---

## 添加控件到窗口

```cj
win.addButton(btn)
win.addLabel(label)
win.addWidget(widget)   // 通用方法
```

---

## 布局

### VBox（垂直布局）

```cj
let vbox = VBox(12.0, 20.0)  // spacing=12, padding=20
vbox.add(widget1, LayoutParams.fixed(900.0, 24.0))
vbox.add(widget2, LayoutParams.fill().withWeight(0.5))
```

### HBox（水平布局）

```cj
let hbox = HBox(10.0, 10.0)
hbox.add(editor, LayoutParams.fill().withWeight(0.75))
hbox.add(panel, LayoutParams.fixed(210.0, 620.0))
```

### LayoutParams

| 方法 | 说明 |
|------|------|
| `LayoutParams.fixed(w, h)` | 固定宽高 |
| `LayoutParams.fill()` | 填充剩余空间 |
| `.withWeight(w)` | 弹性权重（0.0 ~ 1.0） |

### LayoutFrame

精确控制控件的位置和大小（用于脱离布局流）：

```cj
widget.setLayoutFrame(LayoutFrame(0.0, 70.0, 1050.0, 650.0))
```

---

## 事件处理

### 按钮点击

```cj
let btn = Button("Click", pos, 100.0, 36.0,
    "Microsoft YaHei", 14.0, SizeScale.scalable(), Anchor.Center,
    ButtonStyle.fromTheme(), { => println("clicked!") })
```

### ComboBox 选择

```cj
combo.setOnSelectionChanged({ idx, label =>
    println("Selected: ${label}")
})
```

### RadioGroup 选择

```cj
radioGroup.setOnSelectionChanged({ idx =>
    println("Radio selected: ${idx}")
})
```

### 快捷键

```cj
// 注册 Ctrl+D 切换主题
ShortcutManager.getInstance().register(68, true, false, false, { =>
    Theme.toggle()
    win.setBackgroundColor(Theme.colors().bgSecondary)
})

// 持久化
ShortcutManager.getInstance().saveConfig()    // 保存到 cjform.ini
ShortcutManager.getInstance().loadConfig(...) // 从 cjform.ini 加载
```

---

## 窗口状态记忆

窗口关闭时，位置和大小会自动保存到 `cjform.ini`，下次启动时自动恢复。

---

## 下一步

- [控件参考](controls.md) — 所有控件的 API 详解
- [主题系统](theme.md) — 自定义主题和颜色
- [样式表](stylesheet.md) — 声明式样式复用
