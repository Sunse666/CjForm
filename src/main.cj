package myapp

import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("CJForm App", 800, 600)
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
