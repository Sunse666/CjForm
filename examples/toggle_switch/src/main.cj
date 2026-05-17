package example_toggle_switch

import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("ToggleSwitch Example", 350, 250)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let ts1 = ToggleSwitch(true, ToggleSwitchStyle.fromTheme())
    ts1.setOnCheckedChanged({ v => println("Wi-Fi: ${v}") })
    ts1.setLayoutFrame(LayoutFrame(160.0, 50.0, 44.0, 22.0))
    win.addWidget(ts1)

    let ts2 = ToggleSwitch(false, ToggleSwitchStyle.fromTheme())
    ts2.setOnCheckedChanged({ v => println("Bluetooth: ${v}") })
    ts2.setLayoutFrame(LayoutFrame(160.0, 100.0, 44.0, 22.0))
    win.addWidget(ts2)

    let ts3 = ToggleSwitch(true, ToggleSwitchStyle.fromTheme())
    ts3.setOnCheckedChanged({ v => println("Airplane mode: ${v}") })
    ts3.setLayoutFrame(LayoutFrame(160.0, 150.0, 44.0, 22.0))
    win.addWidget(ts3)

    win.show()
    win.run()
    Int64(0)
}
