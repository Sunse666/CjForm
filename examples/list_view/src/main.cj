package example_list_view

import std.collection.*
import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("ListView Example", 400, 400)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let items = ArrayList<String>()
    for (i in 0..50) {
        items.add("Item #${i + 1} — List entry ${(i % 5) + 1}")
    }

    let listView = ListView(30.0)
    listView.setData(items)
    listView.setOnSelectionChanged({ idx => println("Selected item: ${idx}") })
    listView.setLayoutFrame(LayoutFrame(10.0, 10.0, 380.0, 380.0))
    win.addWidget(listView)

    win.show()
    win.run()
    Int64(0)
}
