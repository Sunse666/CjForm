# StyleSheet

The StyleSheet system provides CSS-class-like declarative style reuse to reduce repetitive code.

## Defining Styles

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

Define all styles at the top of `main()` in one block.

## Using Styles

Widgets access styles via their `.styled()` static method:

```cj
// Without styles
let btn = Button("Click", pos, 120.0, 36.0,
    "Microsoft YaHei", 14.0, SizeScale.scalable(), Anchor.Center,
    ButtonStyle.fromTheme(), { => })

// With styles
let btn = Button.styled("btn", "Click",
    pos, 120.0, 36.0,
    ButtonStyle.fromTheme(), { => })
```

Widgets supporting `.styled()`: Button, Label, TextBox, TextEdit, CheckBox, RadioButton, Slider.

## StyleProperties

| Property | Type | Description |
|------|------|------|
| `fontFamily` | `Option<String>` | Font family |
| `fontSize` | `Option<Float32>` | Font size |
| `sizeScale` | `Option<SizeScale>` | Scale mode |
| `anchor` | `Option<Anchor>` | Anchor point |
| `cornerRadius` | `Option<Float32>` | Corner radius |

### Builder Methods

```cj
StyleProperties()
    .withFontFamily("Microsoft YaHei")
    .withFontSize(14.0)
    .withSizeScale(SizeScale.scalable())
    .withAnchor(Anchor.Center)
    .withCornerRadius(6.0)
```

Each `.with*()` method returns a new `StyleProperties`, enabling method chaining.

## Full Example

```cj
main(): Int64 {
    // 1. Define styles
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

    // 2. Use styles
    let btn = Button.styled("btn", "Hello", ...)
    let label = Label.styled("body-label", "User:", ...)
    let input = TextBox.styled("input", ...)

    win.show()
    win.run()
    Int64(0)
}
```
