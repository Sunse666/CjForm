---
icon: material/home
---

# CJForm

!!! tip "Tip"

    CJForm is a native Windows UI library for the Cangjie language. All widgets are custom-drawn. Clone and run.

    - [x] Press ++left++ and ++right++ to navigate between pages!
    - [x] Click the search bar at the top or press <kbd>/</kbd> to quickly find content!
    - [x] Click the theme button at the top to switch the website theme!

    Enjoy reading! :heart:

## Introduction

CJForm is a native Windows UI library for the **Cangjie language**. It bridges to Win32 API / GDI+ through a C++ layer, with all widgets custom-drawn. No third-party UI framework dependencies.

Features Dark / Light dual themes, a declarative StyleSheet system, a complete layout engine, and an animation system, covering 25+ common widgets.

## Core Features

=== "Custom-Drawn Widgets"

    25+ widget types, all custom-drawn via GDI+. No reliance on native Windows controls.

=== "Dual Themes"

    Built-in Dark / Light themes with runtime switching. All widget colors respond automatically.

=== "Declarative Styles"

    StyleSheet system similar to CSS classes — define once, reuse everywhere.

=== "Layout Engine"

    VBox / HBox flexible layout with LayoutFrame for precise control and window resizing.

=== "Animation System"

    Easing functions + color interpolation for smooth hover and click animations.

=== "Data Views"

    ListView, TreeView, TableView, TabView for full data display capabilities.

## Quick Links

<div class="grid cards" markdown>

-   :fontawesome-solid-rocket: **Getting Started**

    ---

    Clone and run your first CJForm app in 10 minutes

    [:octicons-arrow-right-24: Get Started](../getting-started.md)

-   :fontawesome-brands-github: **GitHub Repository**

    ---

    View source code, submit issues or PRs

    [:octicons-arrow-right-24: View on GitHub](https://github.com/Sunse666/CjForm)

-   :material-widgets: **Widget Reference**

    ---

    Complete API and examples for 25+ widgets

    [:octicons-arrow-right-24: View Widgets](../controls.md)

-   :material-palette: **Theme System**

    ---

    Dark / Light theme configuration and customization

    [:octicons-arrow-right-24: View Themes](../theme.md)

</div>

## System Requirements

- OS: **Windows 10 / 11 64-bit**
- Toolchain: **Cangjie toolchain (cjc >= 1.0.5)**
- No extra configuration needed — clone and run

## Quick Start

```bash
git clone https://github.com/Sunse666/CjForm.git MyApp
cd MyApp
cjpm run
```

<div align="center" markdown>
[Getting Started](../getting-started.md){ .md-button }
[Basic Usage](../basics.md){ .md-button }
[Widget Reference](../controls.md){ .md-button }
[Architecture](../architecture.md){ .md-button }
</div>
