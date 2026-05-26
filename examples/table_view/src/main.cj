package example_table_view

import std.collection.*
import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("TableView Example", 600, 350)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let tableView = TableView()
    tableView.addColumn(TableColumn("#", 40.0, false, false, TextAlignment.Center))
    tableView.addColumn(TableColumn("Name", 120.0, true, true, TextAlignment.Left))
    tableView.addColumn(TableColumn("Version", 80.0, true, true, TextAlignment.Center))
    tableView.addColumn(TableColumn("Size", 70.0, true, false, TextAlignment.Right))
    tableView.addColumn(TableColumn("Status", 80.0, true, false, TextAlignment.Left))
    tableView.addColumn(TableColumn("Description", 200.0, false, true, TextAlignment.Left))

    let rows = ArrayList<ArrayList<String>>()
    let data = [
        ["01", "cjform", "1.0.1", "345 KB", "Active", "Windows UI Library"],
        ["02", "cjhttp", "0.5.0", "89 KB", "Active", "HTTP client"],
        ["03", "cjjson", "1.2.0", "156 KB", "Stable", "JSON parser"],
        ["04", "cjnet", "0.6.0", "198 KB", "Beta", "Networking lib"],
        ["05", "cjlog", "0.2.0", "45 KB", "Active", "Structured logging"],
    ]
    for (row in data) {
        let r = ArrayList<String>()
        for (s in row) { r.add(s) }
        rows.add(r)
    }
    tableView.setData(rows)
    tableView.setLayoutFrame(LayoutFrame(5.0, 5.0, 590.0, 340.0))
    win.addWidget(tableView)

    win.show()
    win.run()
    Int64(0)
}
