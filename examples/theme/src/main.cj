package example_theme

import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("Theme Example", 400, 250)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let label = Label("Click buttons to switch theme",
        Position.abs(200.0, 50.0),
        Theme.colors().textPrimary,
        "Microsoft YaHei", 14.0, SizeScale.fixed(), Anchor.Center)
    win.addLabel(label)

    let darkBtn = Button("Dark Theme",
        Position.abs(140.0, 120.0), 120.0, 36.0,
        "Microsoft YaHei", 14.0, SizeScale.scalable(), Anchor.Center,
        ButtonStyle.fromTheme(), { =>
            Theme.setCurrent(Theme.dark())
            win.setBackgroundColor(Theme.colors().bgSecondary)
        })
    win.addButton(darkBtn)

    let lightBtn = Button("Light Theme",
        Position.abs(270.0, 120.0), 120.0, 36.0,
        "Microsoft YaHei", 14.0, SizeScale.scalable(), Anchor.Center,
        ButtonStyle.outlined(), { =>
            Theme.setCurrent(Theme.light())
            win.setBackgroundColor(Theme.colors().bgSecondary)
        })
    win.addButton(lightBtn)

    let toggleBtn = Button("Toggle Theme",
        Position.abs(200.0, 180.0), 120.0, 36.0,
        "Microsoft YaHei", 13.0, SizeScale.scalable(), Anchor.Center,
        ButtonStyle.bordered(2.0, Theme.colors().accent), { =>
            Theme.toggle()
            win.setBackgroundColor(Theme.colors().bgSecondary)
        })
    win.addButton(toggleBtn)

    win.show()
    win.run()
    Int64(0)
}
