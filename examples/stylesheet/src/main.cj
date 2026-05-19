package example_stylesheet

import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    StyleSheet.getDefault()
        .define("btn", StyleProperties()
            .withFontFamily("Microsoft YaHei")
            .withFontSize(14.0)
            .withSizeScale(SizeScale.scalable())
            .withAnchor(Anchor.Center))
        .define("sm-btn", StyleProperties()
            .withFontFamily("Microsoft YaHei")
            .withFontSize(12.0)
            .withSizeScale(SizeScale.scalable())
            .withAnchor(Anchor.Center))
        .define("title", StyleProperties()
            .withFontFamily("Microsoft YaHei")
            .withFontSize(16.0)
            .withSizeScale(SizeScale.fixed())
            .withAnchor(Anchor.CenterLeft))

    let win = Window("StyleSheet Example", 400, 300)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let title = Label.styled("title", "StyleSheet Demo",
        Position.abs(20.0, 30.0), Theme.colors().accent)
    win.addWidget(title)

    let info = Label("All buttons below use styled() factory — " +
        "font and anchor come from the stylesheet.",
        Position.abs(20.0, 70.0),
        Theme.colors().textSecondary,
        "Microsoft YaHei", 12.0, SizeScale.fixed(), Anchor.CenterLeft)
    win.addWidget(info)

    let btn1 = Button.styled("btn", "Primary Button",
        Position.abs(200.0, 150.0), 160.0, 36.0,
        ButtonStyle.fromTheme(), { => println("Primary") })
    win.addWidget(btn1)

    let btn2 = Button.styled("btn", "Outlined Button",
        Position.abs(200.0, 210.0), 160.0, 36.0,
        ButtonStyle.outlined(), { => println("Outlined") })
    win.addWidget(btn2)

    win.show()
    win.run()
    Int64(0)
}
