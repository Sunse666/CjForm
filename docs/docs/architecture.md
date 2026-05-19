# 架构说明

## 分层架构

```
用户 API（Window、Button、TextEdit、Theme、StyleSheet...）
    ↓
控件层（Widget 树、事件路由、布局计算）
    ↓
Canvas 渲染抽象
    ↓
bridge.dll（C++ Win32 / GDI+ FFI）
```

## 各层职责

### 1. 用户 API 层

开发者直接使用的公开接口。位于 `cjform/src/`，每个控件一个文件：

| 文件 | 职责 |
|------|------|
| `window.cj` | 窗口创建、消息循环、事件分发、文件拖放 |
| `button.cj` | 按钮控件（点击、悬停、按下动画） |
| `text_box.cj` | 单行文本输入（含密码模式） |
| `text_edit.cj` | 多行编辑器（光标、选区、撤销重做） |
| `label.cj` | 文本标签 |
| `check_box.cj` | 多选框 |
| `radio_button.cj` | 单选按钮 + RadioGroup |
| `slider.cj` | 滑块 |
| `toggle_switch.cj` | 开关 |
| `spin_box.cj` | 数字步进器 |
| `combo_box.cj` | 下拉选择 |
| `progress_bar.cj` | 进度条 |
| `list_view.cj` | 列表视图 |
| `tree_view.cj` | 树形视图 |
| `table_view.cj` | 表格视图 |
| `tab_view.cj` | 标签页 |
| `scroll_area.cj` | 滚动区域 |
| `vbox.cj` / `hbox.cj` | 垂直/水平布局 |
| `group_box.cj` | 分组框 |
| `split_pane.cj` | 分割面板 |
| `menu_bar.cj` | 菜单栏 |
| `context_menu.cj` | 右键菜单 |
| `popover.cj` | 弹出框 |
| `tooltip.cj` | 工具提示 |
| `image.cj` | 图片显示 |
| `separator.cj` | 分隔线 |
| `dialogs.cj` | MessageBox 对话框 |

### 2. 控件层

核心抽象和跨控件共享的基础设施：

| 文件 | 职责 |
|------|------|
| `widget.cj` | `Widget` 接口定义（paint / hitTest / handleEvent / updateAnimation） |
| `event.cj` | 鼠标和键盘事件定义 |
| `focus_manager.cj` | 焦点管理（Tab 切换） |
| `position.cj` | Position 抽象（绝对/百分比） |
| `shadow.cj` | 阴影效果 |
| `tooltip.cj` | 工具提示管理 |

### 3. Canvas 渲染抽象

`canvas.cj` 封装所有绘制操作，桥接到 GDI+：

- 填充矩形 / 圆角矩形
- 绘制边框 / 文本 / 线条
- 阴影绘制
- 文本测量
- 双缓冲交换

### 4. bridge.dll 桥接层

`bridge.cpp` 使用 Win32 API 和 GDI+ 实现底层功能：

- 窗口创建（`CreateWindowExW`）
- 消息循环（`GetMessage` / `DispatchMessage`）
- GDI+ 渲染（`Graphics` / `SolidBrush` / `GraphicsPath`）
- 文本测量（`MeasureString`）
- DWM 暗色模式（`DwmSetWindowAttribute`）
- 文件拖放（`DragAcceptFiles` / `WM_DROPFILES`）
- 窗口状态持久化（`GetWindowPlacement` / `SetWindowPlacement`）

仓颉侧通过 `bridge.cj` 中的 `foreign func` 声明调用这些 C++ 函数。

## 数据流

### 渲染流程

```
Window.run() 消息循环
  → bridge_window_needs_render() 检查是否需要重绘
  → 遍历 widget 树，调用每个 Widget.paint(canvas, ...)
  → Canvas 方法调用 bridge_gdip_*() FFI 函数
  → bridge.dll 执行 GDI+ 绘制
  → bridge_window_present() 交换缓冲区
```

### 事件处理流程

```
Windows 消息循环（bridge.dll）
  → bridge_window_has_mouse_event() / bridge_window_has_key_event()
  → Window 读取事件数据（坐标、按键、修饰键）
  → Window.dispatchEvent()
    → 遍历 widget 树进行 hitTest
    → Widget.handleEvent(event) 处理事件
    → 更新 hover / pressed / focused 状态
    → 触发回调（onClick, onSelectionChanged 等）
```

### 主题切换流程

```
Theme.toggle() / Theme.setCurrent()
  → Theme 单例更新当前 ThemeColors
  → Window 标记需要重绘
  → 下次渲染时，所有 Style.fromTheme() 读取新主题颜色
  → 控件以新颜色重新绘制
```

## Widget 接口

所有控件实现 `Widget` 接口：

```cj
public interface Widget {
    func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32,
        currentWidth: Float32, currentHeight: Float32): Unit
    func hitTest(x: Float32, y: Float32, initialWidth: Float32,
        initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool
    func handleEvent(event: Event): Bool
    func contains(x: Float32, y: Float32): Bool
    func getLayoutMinWidth(): Float32
    func getLayoutMinHeight(): Float32
    func setLayoutFrame(frame: LayoutFrame): Unit
    func clearLayoutFrame(): Unit
    func getLayoutFrame(): Option<LayoutFrame>
    func updateAnimation(tickCount: Int64): Bool
    func findLeafAt(x: Float32, y: Float32): Widget
}
```
