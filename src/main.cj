package cjform

import std.collection.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("CJForm v1.0 — Widget Gallery", 1050, 720)
    win.setMinSize(900, 600)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let menuBar = createMenuBar(win)
    menuBar.setLayoutFrame(LayoutFrame(0.0, 0.0, 1050.0, 28.0))
    win.addWidget(menuBar)

    let titleLabel = Label("CJForm v1.0 Widget Gallery",
        Position.abs(20.0, 40.0),
        Theme.colors().textPrimary,
        "Microsoft YaHei", 16.0, SizeScale.fixed(), Anchor.CenterLeft)

    let themeToggleBtn = Button("Toggle Theme", Position.abs(820.0, 36.0), 120.0, 30.0,
        "Microsoft YaHei", 13.0, SizeScale.fixed(), Anchor.Center,
        ButtonStyle.fromTheme(), { =>
            Theme.toggle()
            win.setBackgroundColor(Theme.colors().bgSecondary)
        })

    let themeCombo = createThemeCombo(win)

    let tabView = TabView()
    tabView.addTab("Basic Controls", createBasicControlsTab(win))
    tabView.addTab("Text Editor", createTextEditTab())
    tabView.addTab("Lists && Trees", createListsTab())
    tabView.addTab("Table View", createTableTab())
    tabView.addTab("New Controls", createNewControlsTab(win))
    tabView.addTab("Scroll Area", createScrollTab())
    tabView.addTab("About", createAboutTab())
    tabView.setLayoutFrame(LayoutFrame(0.0, 70.0, 1050.0, 650.0))

    let ctxMenu = createContextMenu(win)
    win.setContextMenu(ctxMenu)

    ShortcutManager.getInstance().register(68, true, false, false, { =>
        Theme.toggle()
        win.setBackgroundColor(Theme.colors().bgSecondary)
    })

    win.addLabel(titleLabel)
    win.addButton(themeToggleBtn)
    win.addWidget(themeCombo)
    win.addWidget(tabView)
    win.setMainWidget(tabView)

    win.show()
    let result = win.run()
    Int64(result)
}

func createMenuBar(win: Window): MenuBar {
    let bar = MenuBar()
    bar.setParentWindow(win)

    let fileMenu = MenuItem("File", { => () })
    fileMenu.addChild(MenuItem("New", { => println("File → New") }, "", true))
    fileMenu.addChild(MenuItem("Open...", { => println("File → Open") }, "", true))
    fileMenu.addChild(MenuItem("Save", { => println("File → Save") }, "Ctrl+S", true))
    fileMenu.addChild(MenuItem("Save As...", { => println("File → Save As") }, "", true))
    fileMenu.addChild(MenuItem.separator())
    fileMenu.addChild(MenuItem("Exit", { => println("File → Exit") }, "", true))
    bar.addItem(fileMenu)

    let editMenu = MenuItem("Edit", { => () })
    editMenu.addChild(MenuItem("Undo", { => println("Edit → Undo") }, "Ctrl+Z", true))
    editMenu.addChild(MenuItem("Redo", { => println("Edit → Redo") }, "Ctrl+Y", true))
    editMenu.addChild(MenuItem.separator())
    editMenu.addChild(MenuItem("Cut", { => println("Edit → Cut") }, "Ctrl+X", true))
    editMenu.addChild(MenuItem("Copy", { => println("Edit → Copy") }, "Ctrl+C", true))
    editMenu.addChild(MenuItem("Paste", { => println("Edit → Paste") }, "Ctrl+V", true))
    bar.addItem(editMenu)

    let viewMenu = MenuItem("View", { => () })
    viewMenu.addChild(MenuItem("Dark Theme", { =>
        Theme.setCurrent(Theme.dark())
        win.setBackgroundColor(Theme.colors().bgSecondary)
    }, "", true))
    viewMenu.addChild(MenuItem("Light Theme", { =>
        Theme.setCurrent(Theme.light())
        win.setBackgroundColor(Theme.colors().bgSecondary)
    }, "", true))
    bar.addItem(viewMenu)

    let helpMenu = MenuItem("Help", { => () })
    helpMenu.addChild(MenuItem("About CJForm", { =>
        println("CJForm v1.0 — Cangjie Windows UI Library")
    }, "", true))
    bar.addItem(helpMenu)

    bar
}

func createThemeCombo(win: Window): ComboBox {
    let combo = ComboBox()
    let themes = ArrayList<String>()
    themes.add("Dark Theme")
    themes.add("Light Theme")
    combo.setItems(themes)
    combo.setLayoutFrame(LayoutFrame(950.0, 36.0, 120.0, 30.0))
    combo.setParentWindow(win)
    combo.setOnSelectionChanged({ idx, label =>
        if (idx == 0) {
            Theme.setCurrent(Theme.dark())
        } else {
            Theme.setCurrent(Theme.light())
        }
        win.setBackgroundColor(Theme.colors().bgSecondary)
    })
    combo
}

func createContextMenu(win: Window): ContextMenu {
    let menu = ContextMenu()
    menu.addItem(MenuItem("Dark Theme", { =>
        Theme.setCurrent(Theme.dark())
        win.setBackgroundColor(Theme.colors().bgSecondary)
    }, "", true))
    menu.addItem(MenuItem("Light Theme", { =>
        Theme.setCurrent(Theme.light())
        win.setBackgroundColor(Theme.colors().bgSecondary)
    }, "", true))
    menu.addItem(MenuItem("", { => () }))
    menu.addItem(MenuItem("About CJForm", { =>
        println("CJForm v1.0 — Cangjie Windows UI Library")
    }, "", true))
    menu
}

func createBasicControlsTab(win: Window): Widget {
    let scroll = ScrollArea()
    let vbox = VBox(12.0, 20.0)
    let c = Theme.colors()
    let section1 = Label("Buttons", Position.abs(0.0, 0.0), c.accent, "Microsoft YaHei", 16.0, SizeScale.fixed(), Anchor.CenterLeft)
    vbox.add(section1, LayoutParams.fixed(900.0, 24.0))
    let btnRow = HBox(10.0, 0.0)
    btnRow.add(Button("Primary", Position.abs(0.0, 0.0), 110.0, 36.0,
        "Microsoft YaHei", 14.0, SizeScale.scalable(), Anchor.Center,
        ButtonStyle.fromTheme(), { => println("Primary clicked") }), LayoutParams.fixed(110.0, 36.0))
    btnRow.add(Button("Outlined", Position.abs(0.0, 0.0), 110.0, 36.0,
        "Microsoft YaHei", 14.0, SizeScale.scalable(), Anchor.Center,
        ButtonStyle.outlined(), { => println("Outlined clicked") }), LayoutParams.fixed(110.0, 36.0))
    btnRow.add(Button("Danger", Position.abs(0.0, 0.0), 90.0, 36.0,
        "Microsoft YaHei", 14.0, SizeScale.scalable(), Anchor.Center,
        ButtonStyle.bordered(2.0, Theme.colors().danger), { => println("Danger clicked") }), LayoutParams.fixed(90.0, 36.0))
    vbox.add(btnRow, LayoutParams.fixed(900.0, 40.0))
    vbox.add(Separator(true, SeparatorStyle.fromTheme()), LayoutParams.fixed(900.0, 10.0))
    let section2 = Label("Text Input", Position.abs(0.0, 0.0), c.accent, "Microsoft YaHei", 16.0, SizeScale.fixed(), Anchor.CenterLeft)
    vbox.add(section2, LayoutParams.fixed(900.0, 24.0))
    let inputRow = HBox(10.0, 0.0)
    inputRow.add(Label("Username:", Position.abs(0.0, 0.0), c.textSecondary, "Microsoft YaHei", 14.0, SizeScale.fixed(), Anchor.CenterLeft), LayoutParams.fixed(90.0, 28.0))
    let nameBox = TextBox(Position.abs(0.0, 0.0), 200.0, 28.0, "Microsoft YaHei", 14.0, SizeScale.scalable(), TextBoxStyle.fromTheme(), "Enter username...")
    inputRow.add(nameBox, LayoutParams.fixed(200.0, 28.0))
    inputRow.add(Label("Password:", Position.abs(0.0, 0.0), c.textSecondary, "Microsoft YaHei", 14.0, SizeScale.fixed(), Anchor.CenterLeft), LayoutParams.fixed(80.0, 28.0))
    let pwBox = TextBox(Position.abs(0.0, 0.0), 200.0, 28.0, "Microsoft YaHei", 14.0, SizeScale.scalable(), TextBoxStyle.fromTheme(), "Enter password...")
    pwBox.setPasswordMode(true)
    inputRow.add(pwBox, LayoutParams.fixed(200.0, 28.0))
    vbox.add(inputRow, LayoutParams.fixed(900.0, 32.0))
    vbox.add(Separator(true, SeparatorStyle.fromTheme()), LayoutParams.fixed(900.0, 10.0))
    let section3 = Label("Checkboxes && Radio Buttons", Position.abs(0.0, 0.0), c.accent, "Microsoft YaHei", 16.0, SizeScale.fixed(), Anchor.CenterLeft)
    vbox.add(section3, LayoutParams.fixed(900.0, 24.0))
    let cbRow = HBox(20.0, 0.0)
    cbRow.add(CheckBox("Enable notifications", Position.abs(0.0, 0.0), "Microsoft YaHei", 14.0, SizeScale.scalable(), CheckBoxStyle.fromTheme(), true), LayoutParams.fixed(220.0, 24.0))
    cbRow.add(CheckBox("Auto save", Position.abs(0.0, 0.0), "Microsoft YaHei", 14.0, SizeScale.scalable(), CheckBoxStyle.fromTheme(), false), LayoutParams.fixed(150.0, 24.0))
    cbRow.add(CheckBox("Compact mode", Position.abs(0.0, 0.0), "Microsoft YaHei", 14.0, SizeScale.scalable(), CheckBoxStyle.fromTheme(), false), LayoutParams.fixed(170.0, 24.0))
    vbox.add(cbRow, LayoutParams.fixed(900.0, 28.0))
    let radioGroup = RadioGroup()
    let rbRow = HBox(20.0, 0.0)
    let rb1 = RadioButton("Option A", Position.abs(0.0, 0.0), "Microsoft YaHei", 14.0, SizeScale.scalable(), RadioButtonStyle.fromTheme())
    let rb2 = RadioButton("Option B", Position.abs(0.0, 0.0), "Microsoft YaHei", 14.0, SizeScale.scalable(), RadioButtonStyle.fromTheme())
    let rb3 = RadioButton("Option C", Position.abs(0.0, 0.0), "Microsoft YaHei", 14.0, SizeScale.scalable(), RadioButtonStyle.fromTheme())
    radioGroup.add(rb1); radioGroup.add(rb2); radioGroup.add(rb3)
    radioGroup.setOnSelectionChanged({ idx => println("Radio selected: ${idx}") })
    rbRow.add(rb1, LayoutParams.fixed(120.0, 24.0))
    rbRow.add(rb2, LayoutParams.fixed(120.0, 24.0))
    rbRow.add(rb3, LayoutParams.fixed(120.0, 24.0))
    vbox.add(rbRow, LayoutParams.fixed(900.0, 28.0))
    vbox.add(Separator(true, SeparatorStyle.fromTheme()), LayoutParams.fixed(900.0, 10.0))
    let section4 = Label("Sliders", Position.abs(0.0, 0.0), c.accent, "Microsoft YaHei", 16.0, SizeScale.fixed(), Anchor.CenterLeft)
    vbox.add(section4, LayoutParams.fixed(900.0, 24.0))
    let sliderRow = HBox(10.0, 0.0)
    sliderRow.add(Label("Volume:", Position.abs(0.0, 0.0), c.textSecondary, "Microsoft YaHei", 14.0, SizeScale.fixed(), Anchor.CenterLeft), LayoutParams.fixed(60.0, 24.0))
    sliderRow.add(Slider(Position.abs(0.0, 0.0), 200.0, SizeScale.scalable(), SliderStyle.fromTheme(), 0.0, 100.0, 65.0), LayoutParams.fixed(200.0, 24.0))
    vbox.add(sliderRow, LayoutParams.fixed(900.0, 28.0))
    vbox.add(Separator(true, SeparatorStyle.fromTheme()), LayoutParams.fixed(900.0, 10.0))
    let section5 = Label("Toggles && Progress", Position.abs(0.0, 0.0), c.accent, "Microsoft YaHei", 16.0, SizeScale.fixed(), Anchor.CenterLeft)
    vbox.add(section5, LayoutParams.fixed(900.0, 24.0))
    let toggleRow = HBox(20.0, 0.0)
    toggleRow.add(Label("Wi-Fi:", Position.abs(0.0, 0.0), c.textSecondary, "Microsoft YaHei", 14.0, SizeScale.fixed(), Anchor.CenterLeft), LayoutParams.fixed(50.0, 22.0))
    toggleRow.add(ToggleSwitch(true, ToggleSwitchStyle.fromTheme()), LayoutParams.fixed(44.0, 22.0))
    toggleRow.add(Label("Bluetooth:", Position.abs(0.0, 0.0), c.textSecondary, "Microsoft YaHei", 14.0, SizeScale.fixed(), Anchor.CenterLeft), LayoutParams.fixed(75.0, 22.0))
    toggleRow.add(ToggleSwitch(false, ToggleSwitchStyle.fromTheme()), LayoutParams.fixed(44.0, 22.0))
    vbox.add(toggleRow, LayoutParams.fixed(900.0, 28.0))
    vbox.add(ProgressBar(0.0, 100.0, 72.0, ProgressBarStyle.fromTheme()), LayoutParams.fixed(900.0, 16.0))
    scroll.setContent(vbox)
    scroll
}

func createTextEditTab(): Widget {
    let hbox = HBox(8.0, 8.0)
    let c = Theme.colors()
    let editor = TextEdit("Consolas", 14.0, TextEditStyle.fromTheme())
    editor.setText("Welcome to CJForm v1.0 TextEdit!\n\nThis is a multi-line text editor widget.\n\nFeatures:\n  • Multi-line editing with cursor navigation\n  • Text selection with mouse drag\n  • Copy / Cut / Paste (Ctrl+C/X/V)\n  • Undo / Redo (Ctrl+Z/Y)\n  • Select All (Ctrl+A)\n  • Arrow key navigation\n  • Home / End keys\n  • Smooth scrolling\n  • Dark / Light theme support\n\nTry typing here...")
    let infoVbox = VBox(8.0, 8.0)
    let infoTitle = Label("Shortcuts", Position.abs(0.0, 0.0), c.accent, "Microsoft YaHei", 15.0, SizeScale.fixed(), Anchor.CenterLeft)
    infoVbox.add(infoTitle, LayoutParams.fixed(200.0, 24.0))

    let shortcuts = [
        "Ctrl+Z — Undo",
        "Ctrl+Y — Redo",
        "Ctrl+A — Select All",
        "Ctrl+C — Copy",
        "Ctrl+X — Cut",
        "Ctrl+V — Paste",
        "←↑↓→ — Navigate",
        "Home/End — Line start/end",
        "Enter — New line",
        "Backspace — Delete",
    ]
    for (s in shortcuts) {
        infoVbox.add(Label(s, Position.abs(0.0, 0.0), c.textSecondary, "Consolas", 12.0, SizeScale.fixed(), Anchor.CenterLeft), LayoutParams.fixed(200.0, 20.0))
    }
    infoVbox.add(Separator(true, SeparatorStyle.fromTheme()), LayoutParams.fixed(200.0, 10.0))

    let wordCountLabel = Label("Lines: —", Position.abs(0.0, 0.0), c.textTertiary, "Microsoft YaHei", 12.0, SizeScale.fixed(), Anchor.CenterLeft)
    infoVbox.add(wordCountLabel, LayoutParams.fixed(200.0, 20.0))

    hbox.add(editor, LayoutParams.fill().withWeight(0.75))
    hbox.add(infoVbox, LayoutParams.fixed(210.0, 620.0))
    hbox
}

func createListsTab(): Widget {
    let hbox = HBox(10.0, 10.0)
    let treeView = TreeView()
    let root1 = TreeNode("src/")
    root1.expanded = true
    let widgets = TreeNode("widgets/")
    widgets.expanded = true
    let widgetFiles = ["button.cj", "text_box.cj", "text_edit.cj", "check_box.cj", "slider.cj",
        "toggle_switch.cj", "progress_bar.cj", "scroll_area.cj", "list_view.cj",
        "tree_view.cj", "table_view.cj", "spin_box.cj", "group_box.cj", "split_pane.cj"]
    for (f in widgetFiles) { widgets.addChild(TreeNode(f)) }
    root1.addChild(widgets)
    root1.addChild(TreeNode("window.cj"))
    root1.addChild(TreeNode("theme.cj"))
    root1.addChild(TreeNode("event.cj"))
    root1.addChild(TreeNode("animation.cj"))
    root1.addChild(TreeNode("menu_bar.cj"))
    root1.addChild(TreeNode("dialogs.cj"))
    let bridge = TreeNode("bridge/")
    bridge.expanded = true
    bridge.addChild(TreeNode("bridge.cpp"))
    bridge.addChild(TreeNode("CMakeLists.txt"))
    treeView.addNode(root1)
    treeView.addNode(bridge)
    let items = ArrayList<String>()
    for (i in 0..200) {
        items.add("Document #${i + 1} — Project report Q${(i % 4) + 1} FY2026")
    }
    let listView = ListView(28.0)
    listView.setData(items)

    hbox.add(treeView, LayoutParams.fixed(420.0, 600.0).withWeight(0.4))
    hbox.add(listView, LayoutParams.fill().withWeight(0.6))
    hbox
}

func createTableTab(): Widget {
    let tableView = TableView()
    tableView.addColumn(TableColumn("#", 50.0, false, false, 1))
    tableView.addColumn(TableColumn("Package", 180.0, true, true, 0))
    tableView.addColumn(TableColumn("Version", 80.0, true, true, 1))
    tableView.addColumn(TableColumn("Size", 80.0, true, false, 2))
    tableView.addColumn(TableColumn("Status", 90.0, true, false, 0))
    tableView.addColumn(TableColumn("Description", 400.0, false, true, 0))
    let pkgs = [
        ["01", "cjform", "1.0.0", "345 KB", "Active", "Cangjie Windows UI Library"],
        ["02", "commonmark4cj", "0.3.0", "128 KB", "Active", "Markdown parser for Cangjie"],
        ["03", "cjhttp", "0.5.0", "89 KB", "Active", "HTTP client library"],
        ["04", "cjjson", "1.2.0", "156 KB", "Stable", "JSON parser and serializer"],
        ["05", "cjsqlite", "0.8.0", "312 KB", "Active", "SQLite bindings"],
        ["06", "cjtest", "0.4.0", "67 KB", "Active", "Unit testing framework"],
        ["07", "cjnet", "0.6.0", "198 KB", "Beta", "Networking library with TLS"],
        ["08", "cjlog", "0.2.0", "45 KB", "Active", "Structured logging"],
        ["09", "cjcrypto", "0.7.0", "234 KB", "Active", "Cryptography utilities"],
        ["10", "cjconfig", "0.3.0", "56 KB", "Stable", "Configuration file parser"],
        ["11", "cjasync", "1.0.0", "178 KB", "Stable", "Async runtime for Cangjie"],
        ["12", "cjcli", "0.5.0", "92 KB", "Active", "CLI argument parser"],
        ["13", "cjimage", "0.4.0", "145 KB", "Beta", "Image processing"],
        ["14", "cjzip", "0.3.0", "78 KB", "Active", "ZIP archive handler"],
        ["15", "cjdbg", "0.2.0", "34 KB", "Active", "Debug utilities"],
        ["16", "cjyaml", "0.6.0", "112 KB", "Active", "YAML parser and emitter"],
        ["17", "cjxml", "0.4.0", "98 KB", "Stable", "XML parser"],
        ["18", "cjdiff", "0.3.0", "52 KB", "Active", "Diff algorithm"],
        ["19", "cjcsv", "0.2.0", "38 KB", "Active", "CSV reader/writer"],
        ["20", "cjmath", "1.1.0", "210 KB", "Stable", "Mathematics library"],
    ]
    let rowData = ArrayList<ArrayList<String>>()
    for (pkg in pkgs) {
        let row = ArrayList<String>()
        for (s in pkg) { row.add(s) }
        rowData.add(row)
    }
    tableView.setData(rowData)
    tableView
}

func createNewControlsTab(win: Window): Widget {
    let scroll = ScrollArea()
    let vbox = VBox(14.0, 20.0)
    let c = Theme.colors()
    let sec1 = Label("SpinBox (Number Stepper)", Position.abs(0.0, 0.0), c.accent, "Microsoft YaHei", 16.0, SizeScale.fixed(), Anchor.CenterLeft)
    vbox.add(sec1, LayoutParams.fixed(900.0, 24.0))
    let spinRow = HBox(10.0, 0.0)
    spinRow.add(Label("Age:", Position.abs(0.0, 0.0), c.textSecondary, "Microsoft YaHei", 14.0, SizeScale.fixed(), Anchor.CenterLeft), LayoutParams.fixed(50.0, 28.0))
    let ageSpin = SpinBox(0.0, 120.0, 25.0, 1.0, true)
    ageSpin.setOnValueChanged({ v => println("Age: ${v}") })
    spinRow.add(ageSpin, LayoutParams.fixed(120.0, 28.0))
    spinRow.add(Label("Volume:", Position.abs(0.0, 0.0), c.textSecondary, "Microsoft YaHei", 14.0, SizeScale.fixed(), Anchor.CenterLeft), LayoutParams.fixed(60.0, 28.0))
    let volSpin = SpinBox(0.0, 100.0, 50.0, 5.0, false)
    volSpin.setOnValueChanged({ v => println("Volume: ${v}") })
    spinRow.add(volSpin, LayoutParams.fixed(120.0, 28.0))
    vbox.add(spinRow, LayoutParams.fixed(900.0, 36.0))
    vbox.add(Separator(true, SeparatorStyle.fromTheme()), LayoutParams.fixed(900.0, 10.0))
    let sec2 = Label("GroupBox", Position.abs(0.0, 0.0), c.accent, "Microsoft YaHei", 16.0, SizeScale.fixed(), Anchor.CenterLeft)
    vbox.add(sec2, LayoutParams.fixed(900.0, 24.0))
    let group = GroupBox("User Settings")
    let groupVbox = VBox(8.0, 12.0)
    let gbRow1 = HBox(10.0, 0.0)
    gbRow1.add(Label("Nickname:", Position.abs(0.0, 0.0), c.textSecondary, "Microsoft YaHei", 13.0, SizeScale.fixed(), Anchor.CenterLeft), LayoutParams.fixed(80.0, 24.0))
    gbRow1.add(TextBox(Position.abs(0.0, 0.0), 180.0, 26.0, "Microsoft YaHei", 13.0, SizeScale.scalable(), TextBoxStyle.fromTheme(), "Enter nickname..."), LayoutParams.fixed(180.0, 26.0))
    groupVbox.add(gbRow1, LayoutParams.fixed(900.0, 28.0))
    let gbRow2 = HBox(10.0, 0.0)
    gbRow2.add(CheckBox("Enable dark mode", Position.abs(0.0, 0.0), "Microsoft YaHei", 13.0, SizeScale.scalable(), CheckBoxStyle.fromTheme(), true), LayoutParams.fixed(200.0, 24.0))
    gbRow2.add(CheckBox("Auto update", Position.abs(0.0, 0.0), "Microsoft YaHei", 13.0, SizeScale.scalable(), CheckBoxStyle.fromTheme(), false), LayoutParams.fixed(150.0, 24.0))
    groupVbox.add(gbRow2, LayoutParams.fixed(900.0, 28.0))
    group.setContent(groupVbox)
    vbox.add(group, LayoutParams.fixed(900.0, 100.0))
    vbox.add(Separator(true, SeparatorStyle.fromTheme()), LayoutParams.fixed(900.0, 10.0))
    let sec3 = Label("SplitPane (Vertical)", Position.abs(0.0, 0.0), c.accent, "Microsoft YaHei", 16.0, SizeScale.fixed(), Anchor.CenterLeft)
    vbox.add(sec3, LayoutParams.fixed(900.0, 24.0))
    let split = SplitPane(true)
    let leftPanel = VBox(8.0, 12.0)
    leftPanel.add(Label("Left Panel", Position.abs(0.0, 0.0), c.textPrimary, "Microsoft YaHei", 14.0, SizeScale.fixed(), Anchor.CenterLeft), LayoutParams.fixed(400.0, 20.0))
    leftPanel.add(Label("Drag the divider to resize", Position.abs(0.0, 0.0), c.textSecondary, "Microsoft YaHei", 12.0, SizeScale.fixed(), Anchor.CenterLeft), LayoutParams.fixed(400.0, 20.0))
    let rightPanel = VBox(8.0, 12.0)
    rightPanel.add(Label("Right Panel", Position.abs(0.0, 0.0), c.textPrimary, "Microsoft YaHei", 14.0, SizeScale.fixed(), Anchor.CenterLeft), LayoutParams.fixed(400.0, 20.0))
    rightPanel.add(Label("This is the right side", Position.abs(0.0, 0.0), c.textSecondary, "Microsoft YaHei", 12.0, SizeScale.fixed(), Anchor.CenterLeft), LayoutParams.fixed(400.0, 20.0))
    split.setLeft(leftPanel)
    split.setRight(rightPanel)
    vbox.add(split, LayoutParams.fixed(900.0, 120.0))
    vbox.add(Separator(true, SeparatorStyle.fromTheme()), LayoutParams.fixed(900.0, 10.0))
    let sec4 = Label("Image (Placeholder)", Position.abs(0.0, 0.0), c.accent, "Microsoft YaHei", 16.0, SizeScale.fixed(), Anchor.CenterLeft)
    vbox.add(sec4, LayoutParams.fixed(900.0, 24.0))
    let img = Image("awa.png")
    vbox.add(img, LayoutParams.fixed(200.0, 120.0))
    scroll.setContent(vbox)
    scroll
}

func createScrollTab(): Widget {
    let scroll = ScrollArea()
    let vbox = VBox(10.0, 20.0)
    let c = Theme.colors()

    for (section in 0..6) {
        let header = Label("Section ${section + 1}: Lorem Ipsum",
            Position.abs(0.0, 0.0),
            c.accent, "Microsoft YaHei", 16.0, SizeScale.fixed(), Anchor.CenterLeft)
        vbox.add(header, LayoutParams.fixed(900.0, 24.0))

        let paragraphs = [
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
            "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
            "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.",
        ]
        for (text in paragraphs) {
            vbox.add(Label(text, Position.abs(0.0, 0.0),
                c.textSecondary, "Microsoft YaHei", 13.0, SizeScale.fixed(), Anchor.CenterLeft), LayoutParams.fixed(900.0, 48.0))
        }
        vbox.add(Separator(true, SeparatorStyle.fromTheme()), LayoutParams.fixed(900.0, 10.0))
    }
    scroll.setContent(vbox)
    scroll
}

func createAboutTab(): Widget {
    let scroll = ScrollArea()
    let vbox = VBox(14.0, 24.0)
    let c = Theme.colors()
    let titleL = Label("CJForm v1.0.0", Position.abs(0.0, 0.0),
        c.accent, "Microsoft YaHei", 24.0, SizeScale.fixed(), Anchor.CenterLeft)
    vbox.add(titleL, LayoutParams.fixed(900.0, 32.0))
    let subtitle = Label("Cangjie Windows UI Library", Position.abs(0.0, 0.0),
        c.textSecondary, "Microsoft YaHei", 15.0, SizeScale.fixed(), Anchor.CenterLeft)
    vbox.add(subtitle, LayoutParams.fixed(900.0, 24.0))
    vbox.add(Separator(true, SeparatorStyle.fromTheme()), LayoutParams.fixed(900.0, 10.0))
    let widgetsTitle = Label("Widgets included (v1.0):", Position.abs(0.0, 0.0),
        c.textPrimary, "Microsoft YaHei", 15.0, SizeScale.fixed(), Anchor.CenterLeft)
    vbox.add(widgetsTitle, LayoutParams.fixed(900.0, 24.0))
    let widgetList = [
        "Window, Button, Label, TextBox (with password mode)",
        "TextEdit (multi-line editor, undo/redo)",
        "CheckBox, RadioButton (with RadioGroup), Slider",
        "SpinBox (number stepper), ToggleSwitch, ProgressBar",
        "VBox, HBox, GroupBox, SplitPane (layout containers)",
        "ScrollArea (smooth scroll, auto-hide scrollbars)",
        "ListView, TreeView, TableView, TabView",
        "ComboBox, ContextMenu, MenuBar, Popover",
        "Tooltip, Separator, Image (placeholder)",
        "MessageBox (Info/Warning/Error/Question)",
        "Theme (Dark/Light, runtime switching)",
        "Animation (easing, color lerp, scroll smoothing)",
        "ShortcutManager (global keyboard accelerators)",
    ]
    for (text in widgetList) {
        vbox.add(Label("  • ${text}", Position.abs(0.0, 0.0),
            c.textSecondary, "Microsoft YaHei", 13.0, SizeScale.fixed(), Anchor.CenterLeft), LayoutParams.fixed(900.0, 22.0))
    }
    vbox.add(Separator(true, SeparatorStyle.fromTheme()), LayoutParams.fixed(900.0, 10.0))
    let archTitle = Label("Architecture:", Position.abs(0.0, 0.0),
        c.textPrimary, "Microsoft YaHei", 15.0, SizeScale.fixed(), Anchor.CenterLeft)
    vbox.add(archTitle, LayoutParams.fixed(900.0, 24.0))
    let archLines = [
        "User API (Window, Button, TextEdit, Theme, ...)",
        "  → Widget tree + Event routing + Layout engine",
        "  → Canvas (rendering abstraction)",
        "  → bridge.dll (C++ Win32 / GDI+ FFI)",
        "     → Windows GDI+ / User32 / DWM",
    ]
    for (text in archLines) {
        vbox.add(Label("  ${text}", Position.abs(0.0, 0.0),
            c.textTertiary, "Microsoft YaHei", 12.0, SizeScale.fixed(), Anchor.CenterLeft), LayoutParams.fixed(900.0, 20.0))
    }
    scroll.setContent(vbox)
    scroll
}
