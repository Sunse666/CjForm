# Architecture

## Layered Architecture

```
User API (Window, Button, TextEdit, Theme, StyleSheet...)
    ↓
Widget Layer (widget tree, event routing, layout calculation)
    ↓
Canvas (rendering abstraction)
    ↓
bridge.dll (C++ Win32 / GDI+ FFI)
```

## Layer Responsibilities

### 1. User API Layer

Public interfaces for developers. Located in `cjform/src/`, one file per widget:

| File | Responsibility |
|------|------|
| `window.cj` | Window creation, message loop, event dispatch, file drop |
| `button.cj` | Button (click, hover, press animations) |
| `text_box.cj` | Single-line text input (including password mode) |
| `text_edit.cj` | Multi-line editor (cursor, selection, undo/redo) |
| `label.cj` | Text label |
| `check_box.cj` | Checkbox |
| `radio_button.cj` | Radio button + RadioGroup |
| `slider.cj` | Slider |
| `toggle_switch.cj` | Toggle switch |
| `spin_box.cj` | Number stepper |
| `combo_box.cj` | Dropdown selector |
| `progress_bar.cj` | Progress bar |
| `list_view.cj` | List view |
| `tree_view.cj` | Tree view |
| `table_view.cj` | Table view |
| `tab_view.cj` | Tab view |
| `scroll_area.cj` | Scroll area |
| `vbox.cj` / `hbox.cj` | Vertical / horizontal layout |
| `group_box.cj` | Group box |
| `split_pane.cj` | Split pane |
| `menu_bar.cj` | Menu bar |
| `context_menu.cj` | Context menu |
| `popover.cj` | Popover |
| `tooltip.cj` | Tooltip |
| `image.cj` | Image |
| `separator.cj` | Separator |
| `dialogs.cj` | MessageBox dialog |

### 2. Widget Layer

Core abstractions and shared infrastructure:

| File | Responsibility |
|------|------|
| `widget.cj` | `Widget` interface (paint / hitTest / handleEvent / updateAnimation) |
| `event.cj` | Mouse and keyboard event definitions |
| `focus_manager.cj` | Focus management (Tab navigation) |
| `position.cj` | Position abstraction (absolute / percentage) |
| `shadow.cj` | Shadow effects |
| `tooltip.cj` | Tooltip management |

### 3. Canvas Rendering Abstraction

`canvas.cj` encapsulates all drawing operations bridged to GDI+:

- Fill rect / rounded rect
- Draw border / text / lines
- Shadow rendering
- Text measurement
- Double-buffered swap

### 4. bridge.dll Bridge Layer

`bridge.cpp` implements low-level functionality using Win32 API and GDI+:

- Window creation (`CreateWindowExW`)
- Message loop (`GetMessage` / `DispatchMessage`)
- GDI+ rendering (`Graphics` / `SolidBrush` / `GraphicsPath`)
- Text measurement (`MeasureString`)
- DWM dark mode (`DwmSetWindowAttribute`)
- File drag and drop (`DragAcceptFiles` / `WM_DROPFILES`)
- Window state persistence (`GetWindowPlacement` / `SetWindowPlacement`)

The Cangjie side calls these C++ functions via `foreign func` declarations in `bridge.cj`.

## Data Flow

### Render Flow

```
Window.run() message loop
  → bridge_window_needs_render() checks if repaint is needed
  → Traverse widget tree, call each Widget.paint(canvas, ...)
  → Canvas methods call bridge_gdip_*() FFI functions
  → bridge.dll performs GDI+ drawing
  → bridge_window_present() swaps buffers
```

### Event Flow

```
Windows message loop (bridge.dll)
  → bridge_window_has_mouse_event() / bridge_window_has_key_event()
  → Window reads event data (coordinates, keys, modifiers)
  → Window.dispatchEvent()
    → Traverse widget tree for hitTest
    → Widget.handleEvent(event) processes the event
    → Update hover / pressed / focused state
    → Fire callbacks (onClick, onSelectionChanged, etc.)
```

### Theme Switch Flow

```
Theme.toggle() / Theme.setCurrent()
  → Theme singleton updates current ThemeColors
  → Window marks itself dirty for repaint
  → On next render, all Style.fromTheme() reads new theme colors
  → Widgets repaint with new colors
```

## Widget Interface

All widgets implement the `Widget` interface:

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
