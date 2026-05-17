package example_combo_box

import std.collection.*
import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("ComboBox Example", 350, 250)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let items = ArrayList<String>()
    items.add("Dark Theme")
    items.add("Light Theme")
    items.add("System Default")
    items.add("High Contrast")

    let combo = ComboBox()
    combo.setItems(items)
    combo.setLayoutFrame(LayoutFrame(100.0, 50.0, 150.0, 30.0))
    combo.setParentWindow(win)
    combo.setOnSelectionChanged({ idx, label => println("Selected: ${label}") })
    win.addWidget(combo)

    win.show()
    win.run()
    Int64(0)
}
