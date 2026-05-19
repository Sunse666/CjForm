# 样式表

StyleSheet 系统提供类似 CSS class 的声明式样式复用，减少重复代码。

## 定义样式

```cj
StyleSheet.getDefault()
    .define("btn", StyleProperties()
        .withFontFamily("Microsoft YaHei")
        .withFontSize(14.0)
        .withSizeScale(SizeScale.scalable())
        .withAnchor(Anchor.Center))
    .define("section-title", StyleProperties()
        .withFontFamily("Microsoft YaHei")
        .withFontSize(16.0)
        .withSizeScale(SizeScale.fixed())
        .withAnchor(Anchor.CenterLeft))
```

建议在 `main()` 开头一次性定义所有样式。

## 使用样式

控件通过 `.styled()` 静态方法使用样式：

```cj
// 不使用样式
let btn = Button("Click", pos, 120.0, 36.0,
    "Microsoft YaHei", 14.0, SizeScale.scalable(), Anchor.Center,
    ButtonStyle.fromTheme(), { => })

// 使用样式
let btn = Button.styled("btn", "Click",
    pos, 120.0, 36.0,
    ButtonStyle.fromTheme(), { => })
```

支持 `.styled()` 的控件：Button, Label, TextBox, TextEdit, CheckBox, RadioButton, Slider。

## StyleProperties

| 属性 | 类型 | 说明 |
|------|------|------|
| `fontFamily` | `Option<String>` | 字体家族 |
| `fontSize` | `Option<Float32>` | 字号 |
| `sizeScale` | `Option<SizeScale>` | 缩放模式 |
| `anchor` | `Option<Anchor>` | 锚点 |
| `cornerRadius` | `Option<Float32>` | 圆角半径 |

### Builder 方法

```cj
StyleProperties()
    .withFontFamily("Microsoft YaHei")
    .withFontSize(14.0)
    .withSizeScale(SizeScale.scalable())
    .withAnchor(Anchor.Center)
    .withCornerRadius(6.0)
```

每个 `.with*()` 方法返回一个新的 `StyleProperties`，支持链式调用。

## 完整示例

```cj
main(): Int64 {
    // 1. 定义样式
    StyleSheet.getDefault()
        .define("btn", StyleProperties()
            .withFontFamily("Microsoft YaHei")
            .withFontSize(14.0)
            .withSizeScale(SizeScale.scalable())
            .withAnchor(Anchor.Center))
        .define("body-label", StyleProperties()
            .withFontFamily("Microsoft YaHei")
            .withFontSize(14.0)
            .withSizeScale(SizeScale.fixed())
            .withAnchor(Anchor.CenterLeft))
        .define("input", StyleProperties()
            .withFontFamily("Microsoft YaHei")
            .withFontSize(14.0)
            .withSizeScale(SizeScale.scalable()))

    Theme.setCurrent(Theme.dark())
    let win = Window("My App", 800, 600)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    // 2. 使用样式
    let btn = Button.styled("btn", "Hello", ...)
    let label = Label.styled("body-label", "User:", ...)
    let input = TextBox.styled("input", ...)

    win.show()
    win.run()
    Int64(0)
}
```
