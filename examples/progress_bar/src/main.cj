package example_progress_bar

import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("ProgressBar Example", 400, 250)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let pb1 = ProgressBar(0.0, 100.0, 72.0, ProgressBarStyle.fromTheme())
    pb1.setLayoutFrame(LayoutFrame(20.0, 50.0, 360.0, 16.0))
    win.addWidget(pb1)

    let pb2 = ProgressBar(0.0, 100.0, 35.0, ProgressBarStyle.fromTheme())
    pb2.setLayoutFrame(LayoutFrame(20.0, 100.0, 360.0, 16.0))
    win.addWidget(pb2)

    let pb3 = ProgressBar(0.0, 100.0, 100.0, ProgressBarStyle.fromTheme())
    pb3.setLayoutFrame(LayoutFrame(20.0, 150.0, 360.0, 16.0))
    win.addWidget(pb3)

    win.show()
    win.run()
    Int64(0)
}
