package example_spin_box

import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("SpinBox Example", 350, 250)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let ageSpin = SpinBox(0.0, 120.0, 25.0, 1.0, true)
    ageSpin.setOnValueChanged({ v => println("Age: ${v}") })
    ageSpin.setLayoutFrame(LayoutFrame(120.0, 50.0, 120.0, 28.0))
    win.addWidget(ageSpin)

    let quantitySpin = SpinBox(0.0, 99.0, 10.0, 1.0, true)
    quantitySpin.setOnValueChanged({ v => println("Qty: ${v}") })
    quantitySpin.setLayoutFrame(LayoutFrame(120.0, 100.0, 120.0, 28.0))
    win.addWidget(quantitySpin)

    let volumeSpin = SpinBox(0.0, 100.0, 50.0, 5.0, false)
    volumeSpin.setOnValueChanged({ v => println("Volume: ${v}") })
    volumeSpin.setLayoutFrame(LayoutFrame(120.0, 150.0, 120.0, 28.0))
    win.addWidget(volumeSpin)

    win.show()
    win.run()
    Int64(0)
}
