package example_radio_button

import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("RadioButton Example", 350, 280)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let group = RadioGroup()
    group.setOnSelectionChanged({ idx => println("Selected option: ${idx}") })

    let rb1 = RadioButton("Option A — Default",
        Position.abs(20.0, 40.0),
        "Microsoft YaHei", 14.0, SizeScale.scalable(),
        RadioButtonStyle.fromTheme())
    let rb2 = RadioButton("Option B — Alternative",
        Position.abs(20.0, 90.0),
        "Microsoft YaHei", 14.0, SizeScale.scalable(),
        RadioButtonStyle.fromTheme())
    let rb3 = RadioButton("Option C — Custom",
        Position.abs(20.0, 140.0),
        "Microsoft YaHei", 14.0, SizeScale.scalable(),
        RadioButtonStyle.fromTheme())

    group.add(rb1); group.add(rb2); group.add(rb3)
    win.addWidget(rb1)
    win.addWidget(rb2)
    win.addWidget(rb3)

    win.show()
    win.run()
    Int64(0)
}
