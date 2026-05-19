# Getting Started

## Requirements

- **Windows 10 / 11** 64-bit
- **Cangjie toolchain** (cjc >= 1.0.5)

## Clone

```bash
git clone https://github.com/Sunse666/CjForm.git MyApp
cd MyApp
```

## Run

```bash
cjpm run
```

You'll see a widget gallery window showcasing all available widgets.

## Project Structure

```
MyApp/
├── src/
│   └── main.cj          # Your code entry point
├── cjform/              # CJForm library (don't modify)
│   ├── cjpm.toml
│   └── src/
│       ├── window.cj    # Window management
│       ├── button.cj    # Button widget
│       ├── text_edit.cj # Multi-line editor
│       ├── theme.cj     # Theme system
│       ├── style_sheet.cj # StyleSheet
│       └── ...
├── bridge.dll           # Win32 / GDI+ bridge (prebuilt)
├── cjpm.toml
└── README.md
```

## First Program

Edit `src/main.cj`:

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

## Building bridge.dll (Optional)

A prebuilt `bridge.dll` is included. To build from source:

```bash
cd bridge
mkdir build && cd build
cmake .. -G "MinGW Makefiles"
cmake --build . --config Release
cp bridge.dll ../../
```

Requires MinGW-w64 and CMake.

## Next Steps

Continue to [Basic Usage](basics.md) to learn about windows, layout, and event handling.
