# 主题系统

CJForm 内置 Dark / Light 双主题，支持运行时切换。

## 切换主题

```cj
// 设置为暗色主题
Theme.setCurrent(Theme.dark())

// 设置为亮色主题
Theme.setCurrent(Theme.light())

// 一键切换
Theme.toggle()
```

切换主题后需要重新设置窗口背景色：

```cj
Theme.toggle()
win.setBackgroundColor(Theme.colors().bgSecondary)
```

## 获取主题颜色

```cj
let c = Theme.colors()
c.bgPrimary     // 主背景色
c.bgSecondary   // 次背景色
c.textPrimary   // 主文字色
c.accent        // 强调色
```

## 完整颜色列表

### 背景色

| 属性 | 说明 |
|------|------|
| `bgPrimary` | 主背景色 |
| `bgSecondary` | 次背景色 |
| `bgTertiary` | 三级背景色 |

### 文字色

| 属性 | 说明 |
|------|------|
| `textPrimary` | 主文字色 |
| `textSecondary` | 次文字色 |
| `textTertiary` | 三级文字色 |

### 强调色

| 属性 | 说明 |
|------|------|
| `accent` | 强调色 |
| `accentHover` | 强调色悬停 |
| `accentPressed` | 强调色按下 |

### 边框色

| 属性 | 说明 |
|------|------|
| `border` | 边框色 |
| `borderFocused` | 聚焦边框色 |

### 语义色

| 属性 | 说明 |
|------|------|
| `danger` | 危险/错误色 |
| `success` | 成功色 |
| `warning` | 警告色 |
| `shadow` | 阴影色 |

### 按钮色

| 属性 | 说明 |
|------|------|
| `buttonBg` | 按钮背景 |
| `buttonHover` | 按钮悬停 |
| `buttonPressed` | 按钮按下 |
| `buttonText` | 按钮文字 |

### 输入框色

| 属性 | 说明 |
|------|------|
| `inputBg` | 输入框背景 |
| `inputBorder` | 输入框边框 |
| `inputPlaceholder` | 占位符文字 |

### 滑块色

| 属性 | 说明 |
|------|------|
| `sliderTrack` | 滑轨颜色 |
| `sliderFill` | 滑轨填充 |
| `sliderThumb` | 滑块颜色 |

### 进度条色

| 属性 | 说明 |
|------|------|
| `progressTrack` | 轨道颜色 |
| `progressFill` | 填充颜色 |

### 开关色

| 属性 | 说明 |
|------|------|
| `toggleTrack` | 关闭状态轨道 |
| `toggleTrackOn` | 开启状态轨道 |
| `toggleThumb` | 滑块颜色 |

### 分隔线色

| 属性 | 说明 |
|------|------|
| `separator` | 分隔线颜色 |

### 滚动条色

| 属性 | 说明 |
|------|------|
| `scrollbarTrack` | 滚动条轨道 |
| `scrollbarThumb` | 滚动条滑块 |
| `scrollbarThumbHover` | 滚动条滑块悬停 |

### Tab 标签页色

| 属性 | 说明 |
|------|------|
| `tabActiveBg` | 激活标签背景 |
| `tabInactiveBg` | 未激活标签背景 |
| `tabActiveText` | 激活标签文字 |
| `tabInactiveText` | 未激活标签文字 |

### Table 表格色

| 属性 | 说明 |
|------|------|
| `tableHeaderBg` | 表头背景 |
| `tableHeaderText` | 表头文字 |
| `tableGridLine` | 网格线 |
| `tableSelectedBg` | 选中行背景 |
| `tableRowEven` | 偶数行背景 |
| `tableRowOdd` | 奇数行背景 |

### Popup 弹出色

| 属性 | 说明 |
|------|------|
| `popupBg` | 弹出框背景 |
| `popupBorder` | 弹出框边框 |
| `popupItemHover` | 弹出项悬停 |
| `popupItemText` | 弹出项文字 |
| `popupItemTextSecondary` | 弹出项次文字 |

## 样式结构体与主题

每个控件的 Style 结构体都有一个 `isThemeBased` 字段。当为 `true` 时，`fromTheme()` 会使用当前主题颜色：

```cj
// 使用主题颜色（跟随主题切换自动变化）
ButtonStyle.fromTheme()

// 使用自定义颜色（不跟随主题）
ButtonStyle.custom(bg, text, 4.0, 1.0, border)
```

## 自定义颜色

所有颜色使用 `Color` 结构体：

```cj
Color.rgb(255, 100, 50)       // RGB
Color.rgba(255, 100, 50, 200) // RGBA（带透明度）

// 预定义颜色
Color.WHITE
Color.BLACK
Color.RED
Color.GREEN
Color.BLUE
Color.LIGHT_GRAY
Color.GRAY
Color.DARK_GRAY
```
