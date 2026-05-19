package example_button

import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("Button Example", 400, 300)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let btn1 = Button("Primary Button",
        Position.abs(200.0, 100.0), 160.0, 40.0,
        "Microsoft YaHei", 14.0, SizeScale.scalable(), Anchor.Center,
        ButtonStyle.fromTheme(), { => println("Primary clicked") })
    win.addWidget(btn1)

    let btn2 = Button("Outlined Button",
        Position.abs(200.0, 160.0), 160.0, 40.0,
        "Microsoft YaHei", 14.0, SizeScale.scalable(), Anchor.Center,
        ButtonStyle.outlined(), { => println("Outlined clicked") })
    win.addWidget(btn2)

    let btn3 = Button("Danger Button",
        Position.abs(200.0, 220.0), 140.0, 40.0,
        "Microsoft YaHei", 14.0, SizeScale.scalable(), Anchor.Center,
        ButtonStyle.bordered(2.0, Color.rgb(220, 53, 69)), { => println("Danger clicked") })
    win.addWidget(btn3)

    win.show()
    win.run()
    Int64(0)
}
