package example_menu_bar

import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("MenuBar Example", 400, 300)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let menuBar = MenuBar()
    menuBar.setParentWindow(win)

    let fileMenu = MenuItem("File", { => () })
    fileMenu.addChild(MenuItem("New", { => println("File → New") }, "", true))
    fileMenu.addChild(MenuItem("Open...", { => println("File → Open") }, "", true))
    fileMenu.addChild(MenuItem.separator())
    fileMenu.addChild(MenuItem("Exit", { => println("File → Exit") }, "", true))
    menuBar.addItem(fileMenu)

    let editMenu = MenuItem("Edit", { => () })
    editMenu.addChild(MenuItem("Undo", { => println("Edit → Undo") }, "Ctrl+Z", true))
    editMenu.addChild(MenuItem("Redo", { => println("Edit → Redo") }, "Ctrl+Y", true))
    editMenu.addChild(MenuItem.separator())
    editMenu.addChild(MenuItem("Copy", { => println("Edit → Copy") }, "Ctrl+C", true))
    editMenu.addChild(MenuItem("Paste", { => println("Edit → Paste") }, "Ctrl+V", true))
    menuBar.addItem(editMenu)

    let helpMenu = MenuItem("Help", { => () })
    helpMenu.addChild(MenuItem("About", { => println("CJForm MenuBar Example") }, "", true))
    menuBar.addItem(helpMenu)

    menuBar.setLayoutFrame(LayoutFrame(0.0, 0.0, 400.0, 28.0))
    win.addWidget(menuBar)

    win.show()
    win.run()
    Int64(0)
}
