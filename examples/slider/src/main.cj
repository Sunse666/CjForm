package example_slider

import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("Slider Example", 400, 300)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let volSlider = Slider(
        Position.abs(50.0, 60.0), 300.0, SizeScale.scalable(),
        SliderStyle.fromTheme(), 0.0, 100.0, 65.0)
    volSlider.setOnValueChanged({ v => println("Volume: ${v}") })
    win.addWidget(volSlider)

    let brightSlider = Slider(
        Position.abs(50.0, 130.0), 300.0, SizeScale.scalable(),
        SliderStyle.fromTheme(), 0.0, 100.0, 80.0)
    brightSlider.setOnValueChanged({ v => println("Brightness: ${v}") })
    win.addWidget(brightSlider)

    let contrastSlider = Slider(
        Position.abs(50.0, 200.0), 300.0, SizeScale.scalable(),
        SliderStyle.fromTheme(), 0.0, 100.0, 30.0)
    contrastSlider.setOnValueChanged({ v => println("Contrast: ${v}") })
    win.addWidget(contrastSlider)

    win.show()
    win.run()
    Int64(0)
}
