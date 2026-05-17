package example_text_edit

import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("TextEdit Example", 600, 450)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let editor = TextEdit("Consolas", 14.0, TextEditStyle.fromTheme())
    editor.setText("Welcome to TextEdit!\n\n" +
        "This is a multi-line text editor.\n" +
        "Try typing here...\n\n" +
        "Shortcuts:\n" +
        "  Ctrl+Z — Undo    Ctrl+Y — Redo\n" +
        "  Ctrl+A — Select All\n" +
        "  Ctrl+C — Copy    Ctrl+V — Paste\n" +
        "  Ctrl+X — Cut")
    editor.setLayoutFrame(LayoutFrame(10.0, 10.0, 580.0, 430.0))
    win.addWidget(editor)

    win.show()
    win.run()
    Int64(0)
}
