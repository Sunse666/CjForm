package example_scroll_area

import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("ScrollArea Example", 400, 400)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let scroll = ScrollArea()
    let vbox = VBox(8.0, 16.0)
    let c = Theme.colors()

    for (i in 0..20) {
        let title = Label("Section ${i + 1}",
            Position.abs(0.0, 0.0),
            c.accent, "Microsoft YaHei", 14.0, SizeScale.fixed(), Anchor.CenterLeft)
        vbox.add(title, LayoutParams.fixed(380.0, 22.0))

        let body = Label("This is the content of section ${i + 1}. " +
            "Scroll down to see more sections.",
            Position.abs(0.0, 0.0),
            c.textSecondary, "Microsoft YaHei", 12.0, SizeScale.fixed(), Anchor.CenterLeft)
        vbox.add(body, LayoutParams.fixed(380.0, 36.0))
    }

    scroll.setContent(vbox)
    scroll.setLayoutFrame(LayoutFrame(0.0, 0.0, 400.0, 400.0))
    win.addWidget(scroll)
    win.setMainWidget(scroll)

    win.show()
    win.run()
    Int64(0)
}
