package example_context_menu

import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("ContextMenu Example (right-click anywhere)", 400, 300)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let ctxMenu = ContextMenu()
    ctxMenu.addItem(MenuItem("Cut", { => println("Cut") }, "Ctrl+X", true))
    ctxMenu.addItem(MenuItem("Copy", { => println("Copy") }, "Ctrl+C", true))
    ctxMenu.addItem(MenuItem("Paste", { => println("Paste") }, "Ctrl+V", true))
    ctxMenu.addItem(MenuItem("", { => () }))
    ctxMenu.addItem(MenuItem("Select All", { => println("Select All") }, "Ctrl+A", true))
    win.setContextMenu(ctxMenu)

    let label = Label("Right-click anywhere to show context menu.",
        Position.abs(200.0, 140.0),
        Theme.colors().textSecondary,
        "Microsoft YaHei", 14.0, SizeScale.fixed(), Anchor.Center)
    win.addLabel(label)

    win.show()
    win.run()
    Int64(0)
}
