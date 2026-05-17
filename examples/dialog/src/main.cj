package example_dialog

import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("Dialog Example", 400, 350)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let btn1 = Button("Info Dialog",
        Position.abs(200.0, 60.0), 160.0, 36.0,
        "Microsoft YaHei", 14.0, SizeScale.scalable(), Anchor.Center,
        ButtonStyle.fromTheme(), { =>
            let result = showMessageBox("Information", "This is an info message.",
                MessageBoxIcon.Info, MessageBoxButtons.Ok)
            println("Info dialog result: ${convertResult(result)}")
        })
    win.addButton(btn1)

    let btn2 = Button("Warning Dialog",
        Position.abs(200.0, 120.0), 160.0, 36.0,
        "Microsoft YaHei", 14.0, SizeScale.scalable(), Anchor.Center,
        ButtonStyle.outlined(), { =>
            let result = showMessageBox("Warning", "This is a warning message.",
                MessageBoxIcon.Warning, MessageBoxButtons.Ok)
            println("Warning dialog result: ${convertResult(result)}")
        })
    win.addButton(btn2)

    let btn3 = Button("Error Dialog",
        Position.abs(200.0, 180.0), 160.0, 36.0,
        "Microsoft YaHei", 14.0, SizeScale.scalable(), Anchor.Center,
        ButtonStyle.bordered(2.0, Theme.colors().danger), { =>
            let result = showMessageBox("Error", "This is an error message.",
                MessageBoxIcon.Error, MessageBoxButtons.Ok)
            println("Error dialog result: ${convertResult(result)}")
        })
    win.addButton(btn3)

    let btn4 = Button("Question Dialog",
        Position.abs(200.0, 240.0), 160.0, 36.0,
        "Microsoft YaHei", 14.0, SizeScale.scalable(), Anchor.Center,
        ButtonStyle.fromTheme(), { =>
            let result = showMessageBox("Question", "Are you sure?",
                MessageBoxIcon.Question, MessageBoxButtons.YesNo)
            println("Question dialog result: ${convertResult(result)}")
        })
    win.addButton(btn4)

    win.show()
    win.run()
    Int64(0)
}

func convertResult(result: MessageBoxResult): String {
    match (result) {
        case MessageBoxResult.Ok_ => "Ok"
        case MessageBoxResult.Cancel => "Cancel"
        case MessageBoxResult.Yes => "Yes"
        case MessageBoxResult.No => "No"
    }
}
