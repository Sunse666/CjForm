# 控件参考

CJForm 提供 25+ 种自绘控件，涵盖基础输入、数据展示、布局容器等类别。

---

## 基础控件

### Button 按钮

```cj
let btn = Button("Click Me",
    Position.abs(400.0, 300.0), 120.0, 36.0,
    "Microsoft YaHei", 14.0, SizeScale.scalable(), Anchor.Center,
    ButtonStyle.fromTheme(), { => println("clicked!") })

// 使用样式表
let btn = Button.styled("btn", "Click Me",
    Position.abs(400.0, 300.0), 120.0, 36.0,
    ButtonStyle.fromTheme(), { => println("clicked!") })
```

| 参数 | 类型 | 说明 |
|------|------|------|
| `text` | String | 按钮文字 |
| `position` | Position | 位置 |
| `width` | Float32 | 宽度 |
| `height` | Float32 | 高度 |
| `fontFamily` | String | 字体 |
| `fontSize` | Float32 | 字号 |
| `sizeScale` | SizeScale | 缩放模式 |
| `anchor` | Anchor | 锚点 |
| `style` | ButtonStyle | 样式 |
| `onClick` | `() -> Unit` | 点击回调 |

**ButtonStyle：**

| 工厂方法 | 说明 |
|----------|------|
| `ButtonStyle.fromTheme()` | 主题默认样式（实心填充） |
| `ButtonStyle.outlined()` | 描边样式 |
| `ButtonStyle.bordered(width, color)` | 自定义边框样式 |
| `ButtonStyle.custom(bg, textColor, borderRadius, borderWidth, borderColor)` | 完全自定义 |

---

### Label 标签

```cj
let label = Label("Hello World",
    Position.abs(20.0, 40.0), Theme.colors().textPrimary)

// 完整参数
let label = Label("Title", pos, color,
    "Microsoft YaHei", 16.0, SizeScale.fixed(), Anchor.CenterLeft)
```

| 方法 | 说明 |
|------|------|
| `setText(text)` | 动态更新文字 |

---

### TextBox 文本输入

```cj
let textBox = TextBox(
    Position.abs(0.0, 0.0), 200.0, 28.0,
    "Microsoft YaHei", 14.0, SizeScale.scalable(),
    TextBoxStyle.fromTheme(), "Placeholder...")

// 使用样式表
let textBox = TextBox.styled("input",
    Position.abs(0.0, 0.0), 200.0, 28.0,
    TextBoxStyle.fromTheme(), "Enter text...")
```

| 方法 | 说明 |
|------|------|
| `setPasswordMode(true/false)` | 密码模式（显示 •••） |
| `setText(text)` | 设置文本 |
| `getText()` | 获取文本 |

---

### TextEdit 多行编辑器

```cj
let editor = TextEdit.styled("input", "Consolas", 14.0, TextEditStyle.fromTheme())
editor.setText("Welcome to CJForm TextEdit!\n\nType here...")
```

支持功能：

| 快捷键 | 功能 |
|--------|------|
| ++ctrl+z++ | 撤销 |
| ++ctrl+y++ | 重做 |
| ++ctrl+a++ | 全选 |
| ++ctrl+c++ | 复制 |
| ++ctrl+x++ | 剪切 |
| ++ctrl+v++ | 粘贴 |
| ++home++ / ++end++ | 行首 / 行尾 |
| ++arrow-left++ ++arrow-right++ ++arrow-up++ ++arrow-down++ | 光标移动 |

---

## 选择控件

### CheckBox 多选框

```cj
let cb = CheckBox("Enable notifications",
    Position.abs(0.0, 0.0),
    "Microsoft YaHei", 13.0, SizeScale.scalable(),
    CheckBoxStyle.fromTheme(), true)

let cb = CheckBox.styled("btn", "Enable notifications",
    Position.abs(0.0, 0.0),
    CheckBoxStyle.fromTheme(), true)
```

---

### RadioButton + RadioGroup 单选按钮

```cj
let group = RadioGroup()

let rb1 = RadioButton.styled("btn", "Option A",
    Position.abs(0.0, 0.0), RadioButtonStyle.fromTheme())
let rb2 = RadioButton.styled("btn", "Option B",
    Position.abs(0.0, 0.0), RadioButtonStyle.fromTheme())

group.add(rb1)
group.add(rb2)
group.setOnSelectionChanged({ idx => println("Selected: ${idx}") })
```

---

### Slider 滑块

```cj
let slider = Slider.styled("input",
    Position.abs(0.0, 0.0), 200.0,
    SliderStyle.fromTheme(), 0.0, 100.0, 65.0)
```

---

### ToggleSwitch 开关

```cj
let toggle = ToggleSwitch(true, ToggleSwitchStyle.fromTheme())
```

---

### SpinBox 数字步进器

```cj
let spin = SpinBox(0.0, 120.0, 25.0, 1.0, true)
spin.setOnValueChanged({ v => println("Value: ${v}") })
```

---

### ComboBox 下拉选择

```cj
let combo = ComboBox()
let items = ArrayList<String>()
items.add("Dark Theme")
items.add("Light Theme")
combo.setItems(items)
combo.setLayoutFrame(LayoutFrame(950.0, 36.0, 120.0, 30.0))
combo.setParentWindow(win)
combo.setOnSelectionChanged({ idx, label =>
    println("Selected: ${label}")
})
```

---

### ProgressBar 进度条

```cj
ProgressBar(0.0, 100.0, 72.0, ProgressBarStyle.fromTheme())
```

---

## 布局容器

### VBox 垂直布局

```cj
let vbox = VBox(spacing, padding)
vbox.add(widget, LayoutParams.fixed(900.0, 24.0))
```

### HBox 水平布局

```cj
let hbox = HBox(spacing, padding)
hbox.add(leftPanel, LayoutParams.fixed(420.0, 600.0).withWeight(0.4))
hbox.add(rightPanel, LayoutParams.fill().withWeight(0.6))
```

### GroupBox 分组框

```cj
let group = GroupBox("User Settings")
let inner = VBox(8.0, 12.0)
group.setContent(inner)
```

### SplitPane 分割面板

```cj
let split = SplitPane(true)
split.setLeft(leftPanel)
split.setRight(rightPanel)
```

### ScrollArea 滚动区域

```cj
let scroll = ScrollArea()
let vbox = VBox(10.0, 20.0)
scroll.setContent(vbox)
```

---

## 视图控件

### ListView 列表视图

```cj
let listView = ListView(28.0)
let items = ArrayList<String>()
for (i in 0..200) { items.add("Item #${i + 1}") }
listView.setData(items)
```

### TreeView 树形视图

```cj
let treeView = TreeView()
let root = TreeNode("src/")
root.expanded = true
root.addChild(TreeNode("button.cj"))
treeView.addNode(root)
```

### TableView 表格视图

```cj
let tableView = TableView()
tableView.addColumn(TableColumn("#", 50.0, false, false, 1))
tableView.addColumn(TableColumn("Name", 180.0, true, true, 0))
tableView.setData(rowData)
```

| TableColumn 参数 | 类型 | 说明 |
|------------------|------|------|
| `title` | String | 列标题 |
| `width` | Float32 | 列宽 |
| `resizable` | Bool | 是否可调整宽度 |
| `sortable` | Bool | 是否可排序 |
| `alignment` | Int32 | 对齐（0=左, 1=中, 2=右） |

### TabView 标签页

```cj
let tabView = TabView()
tabView.addTab("Basic", basicPage)
tabView.addTab("Advanced", advancedPage)
tabView.setLayoutFrame(LayoutFrame(0.0, 70.0, 1050.0, 650.0))
```

---

## 菜单与弹出

### MenuBar 菜单栏

```cj
let bar = MenuBar()
bar.setParentWindow(win)

let fileMenu = MenuItem("File", { => () })
fileMenu.addChild(MenuItem("New", { => println("New") }, "", true))
fileMenu.addChild(MenuItem.separator())
fileMenu.addChild(MenuItem("Exit", { => println("Exit") }, "", true))
bar.addItem(fileMenu)
```

| MenuItem 参数 | 类型 | 说明 |
|---------------|------|------|
| `label` | String | 菜单项文字 |
| `action` | `() -> Unit` | 点击回调 |
| `shortcut` | String | 快捷键提示 |
| `enabled` | Bool | 是否可用 |

### ContextMenu 右键菜单

```cj
let menu = ContextMenu()
menu.addItem(MenuItem("Copy", { => copy() }, "Ctrl+C", true))
win.setContextMenu(menu)
```

---

## 其他控件

### Image 图片

```cj
let img = Image("awa.png")
```

### Separator 分隔线

```cj
Separator(true, SeparatorStyle.fromTheme())
```

### MessageBox 消息框

```cj
MessageBox.show("Title", "Message text", MBType.Info)
```

| MBType | 说明 |
|--------|------|
| `MBType.Info` | 信息 |
| `MBType.Warning` | 警告 |
| `MBType.Error` | 错误 |
| `MBType.Question` | 询问 |

---

## 样式结构体速查

所有控件都有对应的 Style 结构体，遵循统一模式，均提供 `fromTheme()` 静态方法：

| 控件 | Style 结构体 |
|------|-------------|
| Button | `ButtonStyle` |
| TextBox | `TextBoxStyle` |
| TextEdit | `TextEditStyle` |
| CheckBox | `CheckBoxStyle` |
| RadioButton | `RadioButtonStyle` |
| Slider | `SliderStyle` |
| ToggleSwitch | `ToggleSwitchStyle` |
| SpinBox | `SpinBoxStyle` |
| ComboBox | `ComboBoxStyle` |
| ProgressBar | `ProgressBarStyle` |
| TabView | `TabViewStyle` |
| TableView | `TableViewStyle` |
| ListView | `ListViewStyle` |
| TreeView | `TreeViewStyle` |
| ScrollArea | `ScrollAreaStyle` |
| GroupBox | `GroupBoxStyle` |
| SplitPane | `SplitPaneStyle` |
| MenuBar | `MenuBarStyle` |
| ContextMenu | `ContextMenuStyle` |
| Popover | `PopoverStyle` |
| Separator | `SeparatorStyle` |
