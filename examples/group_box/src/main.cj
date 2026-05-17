package example_group_box

import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("GroupBox Example", 380, 300)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let group = GroupBox("User Settings")
    let content = VBox(8.0, 12.0)

    content.add(CheckBox("Enable notifications",
        Position.abs(0.0, 0.0),
        "Microsoft YaHei", 13.0, SizeScale.scalable(),
        CheckBoxStyle.fromTheme(), true),
        LayoutParams.fixed(340.0, 24.0))
    content.add(CheckBox("Auto update",
        Position.abs(0.0, 0.0),
        "Microsoft YaHei", 13.0, SizeScale.scalable(),
        CheckBoxStyle.fromTheme(), false),
        LayoutParams.fixed(340.0, 24.0))
    content.add(CheckBox("Send usage data",
        Position.abs(0.0, 0.0),
        "Microsoft YaHei", 13.0, SizeScale.scalable(),
        CheckBoxStyle.fromTheme(), true),
        LayoutParams.fixed(340.0, 24.0))

    group.setContent(content)
    group.setLayoutFrame(LayoutFrame(20.0, 50.0, 340.0, 140.0))
    win.addWidget(group)

    win.show()
    win.run()
    Int64(0)
}
