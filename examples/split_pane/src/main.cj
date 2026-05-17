package example_split_pane

import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("SplitPane Example", 500, 350)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let split = SplitPane(true)
    let c = Theme.colors()

    let leftPanel = VBox(8.0, 12.0)
    leftPanel.add(Label("Left Panel",
        Position.abs(0.0, 0.0), c.accent,
        "Microsoft YaHei", 14.0, SizeScale.fixed(), Anchor.CenterLeft),
        LayoutParams.fixed(220.0, 24.0))
    leftPanel.add(Label("Drag the middle divider to resize.",
        Position.abs(0.0, 0.0), c.textSecondary,
        "Microsoft YaHei", 12.0, SizeScale.fixed(), Anchor.CenterLeft),
        LayoutParams.fixed(220.0, 40.0))

    let rightPanel = VBox(8.0, 12.0)
    rightPanel.add(Label("Right Panel",
        Position.abs(0.0, 0.0), c.accent,
        "Microsoft YaHei", 14.0, SizeScale.fixed(), Anchor.CenterLeft),
        LayoutParams.fixed(220.0, 24.0))
    rightPanel.add(Label("The divider position is adjustable.",
        Position.abs(0.0, 0.0), c.textSecondary,
        "Microsoft YaHei", 12.0, SizeScale.fixed(), Anchor.CenterLeft),
        LayoutParams.fixed(220.0, 40.0))

    split.setLeft(leftPanel)
    split.setRight(rightPanel)
    split.setLayoutFrame(LayoutFrame(10.0, 10.0, 480.0, 330.0))
    win.addWidget(split)

    win.show()
    win.run()
    Int64(0)
}
