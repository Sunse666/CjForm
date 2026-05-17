package example_tree_view

import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("TreeView Example", 380, 400)
    win.setBackgroundColor(Theme.colors().bgSecondary)

    let treeView = TreeView()

    let root = TreeNode("Project Files")
    root.expanded = true

    let src = TreeNode("src/")
    src.expanded = true
    src.addChild(TreeNode("main.cj"))
    src.addChild(TreeNode("window.cj"))
    src.addChild(TreeNode("theme.cj"))
    root.addChild(src)

    let res = TreeNode("resources/")
    res.expanded = true
    res.addChild(TreeNode("icon.ico"))
    res.addChild(TreeNode("style.json"))
    root.addChild(res)

    root.addChild(TreeNode("README.md"))
    root.addChild(TreeNode("cjpm.toml"))

    treeView.addNode(root)
    treeView.setLayoutFrame(LayoutFrame(10.0, 10.0, 360.0, 380.0))
    win.addWidget(treeView)

    win.show()
    win.run()
    Int64(0)
}
