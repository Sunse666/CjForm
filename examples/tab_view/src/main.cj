package example_tab_view

import std.collection.*
import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("TabView Example", 500, 350)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let tabView = TabView()

    let tab1 = VBox(10.0, 16.0)
    tab1.add(Label("Welcome to Tab 1",
        Position.abs(0.0, 0.0), Theme.colors().textPrimary,
        "Microsoft YaHei", 16.0, SizeScale.fixed(), Anchor.CenterLeft),
        LayoutParams.fixed(460.0, 30.0))
    tab1.add(Label("This is the first tab content.",
        Position.abs(0.0, 0.0), Theme.colors().textSecondary,
        "Microsoft YaHei", 13.0, SizeScale.fixed(), Anchor.CenterLeft),
        LayoutParams.fixed(460.0, 24.0))
    tabView.addTab("General", tab1)

    let tab2 = VBox(10.0, 16.0)
    tab2.add(Label("Settings",
        Position.abs(0.0, 0.0), Theme.colors().textPrimary,
        "Microsoft YaHei", 16.0, SizeScale.fixed(), Anchor.CenterLeft),
        LayoutParams.fixed(460.0, 30.0))
    tab2.add(CheckBox("Enable feature X",
        Position.abs(0.0, 0.0),
        "Microsoft YaHei", 13.0, SizeScale.scalable(),
        CheckBoxStyle.fromTheme(), true),
        LayoutParams.fixed(460.0, 24.0))
    tab2.add(CheckBox("Enable feature Y",
        Position.abs(0.0, 0.0),
        "Microsoft YaHei", 13.0, SizeScale.scalable(),
        CheckBoxStyle.fromTheme(), false),
        LayoutParams.fixed(460.0, 24.0))
    tabView.addTab("Settings", tab2)

    let tab3 = VBox(10.0, 16.0)
    tab3.add(Label("About",
        Position.abs(0.0, 0.0), Theme.colors().textPrimary,
        "Microsoft YaHei", 16.0, SizeScale.fixed(), Anchor.CenterLeft),
        LayoutParams.fixed(460.0, 30.0))
    tab3.add(Label("CJForm TabView Demo v1.0",
        Position.abs(0.0, 0.0), Theme.colors().textSecondary,
        "Microsoft YaHei", 13.0, SizeScale.fixed(), Anchor.CenterLeft),
        LayoutParams.fixed(460.0, 24.0))
    tabView.addTab("About", tab3)

    tabView.setLayoutFrame(LayoutFrame(0.0, 50.0, 500.0, 300.0))
    win.addWidget(tabView)

    win.show()
    win.run()
    Int64(0)
}
