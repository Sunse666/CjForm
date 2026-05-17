package cjform

import std.collection.*

class TabInfo {
    public let title: String
    public let content: Widget

    public init(title: String, content: Widget) {
        this.title = title
        this.content = content
    }
}

public class TabView <: Widget {
    private var tabs: ArrayList<TabInfo>
    private var activeIndex: Int32
    private var tabBarHeight: Float32
    private var tabPadding: Float32
    private var hoveredTab: Int32
    private var layoutFrame: Option<LayoutFrame>
    private var tabPositions: ArrayList<LayoutFrame>

    public init() {
        this.tabs = ArrayList<TabInfo>()
        this.activeIndex = 0
        this.tabBarHeight = 34.0
        this.tabPadding = 4.0
        this.hoveredTab = -1
        this.layoutFrame = None
        this.tabPositions = ArrayList<LayoutFrame>()
    }

    public func addTab(title: String, content: Widget): Unit {
        tabs.add(TabInfo(title, content))
    }

    public func getActiveIndex(): Int32 { activeIndex }

    public func setActiveIndex(index: Int32): Unit {
        if (index >= 0 && index < Int32(tabs.size)) {
            activeIndex = index
        }
    }

    public func getTabCount(): Int32 { Int32(tabs.size) }

    public func getActiveContent(): Option<Widget> {
        if (activeIndex >= 0 && activeIndex < Int32(tabs.size)) {
            Some(tabs[Int64(activeIndex)].content)
        } else { None }
    }

    public func getAllTabContents(): ArrayList<Widget> {
        let result = ArrayList<Widget>()
        for (tab in tabs) {
            result.add(tab.content)
        }
        result
    }

    public func findLeafAt(x: Float32, y: Float32): Widget {
        if (activeIndex >= 0 && activeIndex < Int32(tabs.size)) {
            let content = tabs[Int64(activeIndex)].content
            if (content.hitTest(x, y, 0.0, 0.0, 0.0, 0.0)) {
                content.findLeafAt(x, y)
            } else { this }
        } else { this }
    }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        let frameX = match (layoutFrame) { case Some(f) => f.x; case None => Float32(0.0) }
        let frameY = match (layoutFrame) { case Some(f) => f.y; case None => Float32(0.0) }
        let frameW = match (layoutFrame) { case Some(f) => f.width; case None => Float32(currentWidth) }
        let frameH = match (layoutFrame) { case Some(f) => f.height; case None => Float32(currentHeight) }
        let c = Theme.colors()
        canvas.fillRoundedRect(frameX, frameY, frameW, tabBarHeight, 0.0, c.bgSecondary)

        tabPositions = ArrayList<LayoutFrame>()
        var tabX: Float32 = frameX + tabPadding
        let maxTabW = (frameW - tabPadding * 2.0) / Float32(tabs.size)
        for (i in 0..tabs.size) {
            let title = tabs[i].title
            let textW = canvas.measureTextWidth(title, "Microsoft YaHei", 14.0) + 20.0
            let tabW = if (textW < maxTabW) { textW } else { maxTabW }
            if (tabW > maxTabW) { }
            tabPositions.add(LayoutFrame(tabX, frameY + 4.0, tabW, tabBarHeight - 4.0))
            tabX = tabX + tabW + 2.0
        }

        for (i in 0..tabs.size) {
            let pos = tabPositions[i]
            let isActive = Int32(i) == activeIndex
            let isHovered = Int32(i) == hoveredTab
            let bgColor = if (isActive) { c.tabActiveBg }
                else if (isHovered) { c.tabInactiveBg }
                else { c.bgTertiary }
            let textColor = if (isActive) { c.tabActiveText } else { c.tabInactiveText }

            canvas.fillRoundedRect(pos.x, pos.y, pos.width, pos.height, 6.0, bgColor)

            if (isActive) {
                canvas.drawLine(pos.x + 4.0, pos.y + pos.height - 1.0, pos.x + pos.width - 4.0, pos.y + pos.height - 1.0, 2.0, c.accent)
            }

            canvas.drawTextAligned(pos.x + 4.0, pos.y, pos.width - 8.0, pos.height, tabs[i].title, "Microsoft YaHei", 14.0, 1, textColor)
        }

        let contentY = frameY + tabBarHeight
        let contentH = frameH - tabBarHeight
        if (contentH > 0.0 && activeIndex >= 0 && activeIndex < Int32(tabs.size)) {
            let content = tabs[Int64(activeIndex)].content
            content.setLayoutFrame(LayoutFrame(frameX, contentY, frameW, contentH))
            content.paint(canvas, initialWidth, initialHeight, currentWidth, currentHeight)
        }
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        match (layoutFrame) {
            case Some(f) => x >= f.x && x <= f.x + f.width && y >= f.y && y <= f.y + f.height
            case None => x >= 0.0 && x <= Float32(currentWidth) && y >= 0.0 && y <= Float32(currentHeight)
        }
    }

    public func handleEvent(event: Event): Bool {
        let frameY = match (layoutFrame) { case Some(f) => f.y; case None => Float32(0.0) }

        match (event.eventType) {
            case EventType.MouseDown =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        if (me.y >= frameY && me.y <= frameY + tabBarHeight) {
                            for (i in 0..tabPositions.size) {
                                let pos = tabPositions[i]
                                if (me.x >= pos.x && me.x <= pos.x + pos.width) {
                                    activeIndex = Int32(i)
                                    return true
                                }
                            }
                        }
                        if (activeIndex >= 0 && activeIndex < Int32(tabs.size)) {
                            tabs[Int64(activeIndex)].content.handleEvent(event)
                        }
                        true
                    case None => false
                }
            case EventType.MouseMove =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        var newHovered: Int32 = -1
                        for (i in 0..tabPositions.size) {
                            let pos = tabPositions[i]
                            if (me.x >= pos.x && me.x <= pos.x + pos.width && me.y >= pos.y && me.y <= pos.y + pos.height) {
                                newHovered = Int32(i)
                                break
                            }
                        }
                        hoveredTab = newHovered

                        if (activeIndex >= 0 && activeIndex < Int32(tabs.size)) {
                            tabs[Int64(activeIndex)].content.handleEvent(event)
                        }
                        true
                    case None => false
                }
            case EventType.MouseUp =>
                if (activeIndex >= 0 && activeIndex < Int32(tabs.size)) {
                    tabs[Int64(activeIndex)].content.handleEvent(event)
                }
                true
            case _ =>
                if (activeIndex >= 0 && activeIndex < Int32(tabs.size)) {
                    tabs[Int64(activeIndex)].content.handleEvent(event)
                } else {
                    false
                }
        }
    }

    public func contains(x: Float32, y: Float32): Bool { true }
    public func updateAnimation(tickCount: Int64): Bool {
        if (activeIndex >= 0 && activeIndex < Int32(tabs.size)) {
            tabs[Int64(activeIndex)].content.updateAnimation(tickCount)
        } else {
            false
        }
    }

    public func getLayoutMinWidth(): Float32 { 300.0 }
    public func getLayoutMinHeight(): Float32 { 200.0 }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }
}
