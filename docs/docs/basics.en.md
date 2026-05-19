# Basic Usage

## Window

### Creating a Window

```cj
let win = Window("My App", 800, 600)
```

### Window Properties

| Method | Description |
|------|------|
| `setMinSize(w, h)` | Set minimum window size |
| `setResizable(true/false)` | Set whether resizable |
| `setAlwaysOnTop(true/false)` | Set whether always on top |
| `setNoTitleBar(true/false)` | Set whether to hide title bar |
| `setBackgroundColor(color)` | Set background color |

### Window Lifecycle

```cj
win.show()        // Show the window
let result = win.run()  // Enter message loop, blocks until window closes
```

### File Drop

```cj
win.setOnFileDrop({ files =>
    for (f in files) {
        println("Dropped: ${f}")
    }
})
```

### Context Menu

```cj
let ctxMenu = ContextMenu()
ctxMenu.addItem(MenuItem("About", { => println("About") }, "", true))
win.setContextMenu(ctxMenu)
```

---

## Position

```cj
// Absolute position (pixel coordinates)
Position.abs(400.0, 300.0)

// Percentage position (relative to window)
Position.pct(0.5, 0.3)
```

---

## Anchor

Alignment reference point relative to Position:

| Value | Description |
|----|------|
| `Anchor.Center` | Centered |
| `Anchor.CenterLeft` | Vertically centered, horizontally left |
| `Anchor.CenterRight` | Vertically centered, horizontally right |
| `Anchor.TopLeft` | Top-left corner |
| `Anchor.TopCenter` | Top center |
| `Anchor.TopRight` | Top-right corner |

---

## SizeScale

| Value | Description |
|----|------|
| `SizeScale.scalable()` | Scale proportionally with window |
| `SizeScale.fixed()` | Fixed size, no scaling |

---

## Adding Widgets to a Window

```cj
win.addButton(btn)
win.addLabel(label)
win.addWidget(widget)   // Generic method
```

---

## Layout

### VBox (Vertical Layout)

```cj
let vbox = VBox(12.0, 20.0)  // spacing=12, padding=20
vbox.add(widget1, LayoutParams.fixed(900.0, 24.0))
vbox.add(widget2, LayoutParams.fill().withWeight(0.5))
```

### HBox (Horizontal Layout)

```cj
let hbox = HBox(10.0, 10.0)
hbox.add(editor, LayoutParams.fill().withWeight(0.75))
hbox.add(panel, LayoutParams.fixed(210.0, 620.0))
```

### LayoutParams

| Method | Description |
|------|------|
| `LayoutParams.fixed(w, h)` | Fixed width and height |
| `LayoutParams.fill()` | Fill remaining space |
| `.withWeight(w)` | Flex weight (0.0 ~ 1.0) |

### LayoutFrame

Precise control over widget position and size (outside layout flow):

```cj
widget.setLayoutFrame(LayoutFrame(0.0, 70.0, 1050.0, 650.0))
```

---

## Event Handling

### Button Click

```cj
let btn = Button("Click", pos, 100.0, 36.0,
    "Microsoft YaHei", 14.0, SizeScale.scalable(), Anchor.Center,
    ButtonStyle.fromTheme(), { => println("clicked!") })
```

### ComboBox Selection

```cj
combo.setOnSelectionChanged({ idx, label =>
    println("Selected: ${label}")
})
```

### RadioGroup Selection

```cj
radioGroup.setOnSelectionChanged({ idx =>
    println("Radio selected: ${idx}")
})
```

### Shortcuts

```cj
// Register Ctrl+D to toggle theme
ShortcutManager.getInstance().register(68, true, false, false, { =>
    Theme.toggle()
    win.setBackgroundColor(Theme.colors().bgSecondary)
})

// Persistence
ShortcutManager.getInstance().saveConfig()    // Save to cjform.ini
ShortcutManager.getInstance().loadConfig(...) // Load from cjform.ini
```

---

## Window State Memory

Window position and size are automatically saved to `cjform.ini` on close and restored on next launch.

---

## Next Steps

- [Widget Reference](controls.md) — Complete API for all widgets
- [Theme System](theme.md) — Custom themes and colors
- [StyleSheet](stylesheet.md) — Declarative style reuse
