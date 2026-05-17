package example_check_box

import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("CheckBox Example", 350, 280)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let cb1 = CheckBox("Enable notifications",
        Position.abs(20.0, 40.0),
        "Microsoft YaHei", 14.0, SizeScale.scalable(),
        CheckBoxStyle.fromTheme(), true)
    cb1.setOnCheckedChanged({ v => println("Notifications: ${v}") })
    win.addCheckBox(cb1)

    let cb2 = CheckBox("Auto save enabled",
        Position.abs(20.0, 90.0),
        "Microsoft YaHei", 14.0, SizeScale.scalable(),
        CheckBoxStyle.fromTheme(), false)
    win.addCheckBox(cb2)

    let cb3 = CheckBox("Dark mode",
        Position.abs(20.0, 140.0),
        "Microsoft YaHei", 14.0, SizeScale.scalable(),
        CheckBoxStyle.fromTheme(), true)
    win.addCheckBox(cb3)

    let cb4 = CheckBox("Compact layout",
        Position.abs(20.0, 190.0),
        "Microsoft YaHei", 14.0, SizeScale.scalable(),
        CheckBoxStyle.fromTheme(), false)
    win.addCheckBox(cb4)

    win.show()
    win.run()
    Int64(0)
}
