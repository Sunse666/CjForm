package cjform

import std.collection.*

public class ContextMenu <: Widget {
    private var items: ArrayList<MenuItem>
    private var itemHeight: Float32
    private var minWidth: Float32
    private var posX: Float32
    private var posY: Float32
    private var hoveredItem: Int32
    private var layoutFrame: Option<LayoutFrame>
    private var computedWidth: Float32
    private var computedHeight: Float32
    private var adjustedX: Float32
    private var adjustedY: Float32

    public init() {
        this.items = ArrayList<MenuItem>()
        this.itemHeight = 28.0
        this.minWidth = 150.0
        this.posX = 0.0
        this.posY = 0.0
        this.hoveredItem = -1
        this.layoutFrame = None
        this.computedWidth = 0.0
        this.computedHeight = 0.0
        this.adjustedX = 0.0
        this.adjustedY = 0.0
    }

    public func addItem(item: MenuItem): Unit {
        items.add(item)
    }

    public func setPosition(x: Float32, y: Float32): Unit {
        this.posX = x
        this.posY = y
    }

    private func isItemSeparator(idx: Int32): Bool {
        if (idx < 0 || idx >= Int32(items.size)) { return false }
        let item = items[Int64(idx)]
        item.text.size == 0 && item.shortcut.size == 0 && !item.isEnabled
    }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        let c = Theme.colors()
        computedWidth = minWidth
        for (item in items) {
            if (item.text.size == 0 && item.shortcut.size == 0 && !item.isEnabled) { continue }
            let textW = canvas.measureTextWidth(item.text, "Microsoft YaHei", 13.0) + 40.0
            if (item.shortcut.size > 0) {
                let sw = canvas.measureTextWidth(item.shortcut, "Microsoft YaHei", 11.0)
                if (textW + sw > computedWidth) { computedWidth = textW + sw + 16.0 }
            }
            if (textW > computedWidth) { computedWidth = textW }
        }
        var totalH: Float32 = 0.0
        for (item in items) {
            let isItemSep = item.text.size == 0 && item.shortcut.size == 0 && !item.isEnabled
            totalH = totalH + if (isItemSep) { 8.0 } else { itemHeight }
        }
        computedHeight = totalH + 8.0
        var px = posX
        var py = posY
        if (px + computedWidth > Float32(currentWidth)) { px = Float32(currentWidth) - computedWidth - Float32(4.0) }
        if (py + computedHeight > Float32(currentHeight)) { py = Float32(currentHeight) - computedHeight - Float32(4.0) }
        if (px < 0.0) { px = Float32(4.0) }
        if (py < 0.0) { py = Float32(4.0) }
        adjustedX = px
        adjustedY = py
        canvas.drawShadow(px, py, computedWidth, computedHeight, 6.0, 8.0, 0.0, 4.0, c.shadow)
        canvas.fillRoundedRect(px, py, computedWidth, computedHeight, 6.0, c.popupBg)
        canvas.drawRoundedRect(px, py, computedWidth, computedHeight, 6.0, 1.0, c.popupBorder)
        var itemY: Float32 = py + 4.0
        for (i in 0..items.size) {
            let item = items[i]
            let itemIdx = Int32(i)
            let isItemSep = item.text.size == 0 && item.shortcut.size == 0 && !item.isEnabled

            if (isItemSep) {
                canvas.drawLine(px + 12.0, itemY + 3.0, px + computedWidth - 12.0, itemY + 3.0, 1.0, c.popupBorder)
                itemY = itemY + 8.0
            } else {
                if (itemIdx == hoveredItem && item.isEnabled) {
                    canvas.fillRoundedRect(px + 4.0, itemY, computedWidth - 8.0, itemHeight, 4.0, c.popupItemHover)
                }
                let textColor = if (item.isEnabled) { c.popupItemText } else { c.popupItemTextSecondary }
                canvas.drawTextAligned(px + 12.0, itemY, computedWidth - 100.0, itemHeight, item.text, "Microsoft YaHei", 13.0, 0, textColor)
                if (item.shortcut.size > 0) {
                    canvas.drawTextAligned(px + computedWidth - 90.0, itemY, 78.0, itemHeight, item.shortcut, "Microsoft YaHei", 11.0, 2, c.popupItemTextSecondary)
                }
                itemY = itemY + itemHeight
            }
        }
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        let px = adjustedX
        let py = adjustedY
        x >= px && x <= px + computedWidth && y >= py && y <= py + computedHeight
    }

    public func getClickedItem(x: Float32, y: Float32, currentWidth: Float32, currentHeight: Float32): Int32 {
        let px = adjustedX
        let py = adjustedY

        var itemY: Float32 = py + Float32(4.0)
        for (i in 0..items.size) {
            let item = items[i]
            let isItemSep = item.text.size == 0 && item.shortcut.size == 0 && !item.isEnabled
            let h = if (isItemSep) { Float32(8.0) } else { itemHeight }
            if (y >= itemY && y <= itemY + h) {
                return if (isItemSep) { Int32(-1) } else { Int32(i) }
            }
            itemY = itemY + h
        }
        -1
    }

    public func handleEvent(event: Event): Bool {
        match (event.eventType) {
            case EventType.MouseMove =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        hoveredItem = getClickedItem(me.x, me.y, Float32(0.0), Float32(0.0))
                        true
                    case None => false
                }
            case EventType.MouseUp =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        let idx = getClickedItem(me.x, me.y, Float32(0.0), Float32(0.0))
                        if (idx >= 0 && idx < Int32(items.size)) {
                            let item = items[Int64(idx)]
                            if (item.isEnabled && !isItemSeparator(idx)) {
                                item.onClick()
                            }
                        }
                        true
                    case None => false
                }
            case _ => false
        }
    }

    public func contains(x: Float32, y: Float32): Bool { true }
    public func updateAnimation(tickCount: Int64): Bool { false }
    public func findLeafAt(x: Float32, y: Float32): Widget { this }
    public func getLayoutMinWidth(): Float32 { minWidth }
    public func getLayoutMinHeight(): Float32 { 100.0 }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }
}
