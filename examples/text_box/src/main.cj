package example_text_box

import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("TextBox Example", 400, 250)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let nameBox = TextBox(
        Position.abs(200.0, 70.0), 260.0, 32.0,
        "Microsoft YaHei", 14.0, SizeScale.scalable(),
        TextBoxStyle.fromTheme(), "Enter your name...")
    win.addWidget(nameBox)

    let pwBox = TextBox(
        Position.abs(200.0, 130.0), 260.0, 32.0,
        "Microsoft YaHei", 14.0, SizeScale.scalable(),
        TextBoxStyle.fromTheme(), "Enter password...")
    pwBox.setPasswordMode(true)
    win.addWidget(pwBox)

    let searchBox = TextBox(
        Position.abs(200.0, 190.0), 260.0, 32.0,
        "Microsoft YaHei", 14.0, SizeScale.scalable(),
        TextBoxStyle.fromTheme(), "Search...")
    searchBox.setOnTextChanged({ text => println("Search: ${text}") })
    win.addWidget(searchBox)

    win.show()
    win.run()
    Int64(0)
}
