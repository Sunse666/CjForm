package cjform

import std.collection.*

public class ComboBox <: Widget {
    private var items: ArrayList<String>
    private var selectedIndex: Int32
    private var isOpen: Bool
    private var isHovered: Bool
    private var hoveredItemIndex: Int32
    private var buttonHeight: Float32
    private var dropDownMaxHeight: Float32
    private var itemHeight: Float32
    private var onSelectionChanged: Option<(Int32, String) -> Unit>
    private var layoutFrame: Option<LayoutFrame>
    private var parentWindow: Option<Window>

    public init() {
        this.items = ArrayList<String>()
        this.selectedIndex = -1
        this.isOpen = false
        this.isHovered = false
        this.hoveredItemIndex = -1
        this.buttonHeight = 30.0
        this.dropDownMaxHeight = 200.0
        this.itemHeight = 26.0
        this.onSelectionChanged = None<(Int32, String) -> Unit>
        this.layoutFrame = None
        this.parentWindow = None<Window>
    }

    public func setItems(items: ArrayList<String>): Unit {
        this.items = items
        this.selectedIndex = -1
    }

    public func setOnSelectionChanged(callback: (Int32, String) -> Unit): Unit {
        this.onSelectionChanged = Some<(Int32, String) -> Unit>(callback)
    }

    public func getSelectedIndex(): Int32 { selectedIndex }

    public func setParentWindow(win: Window): Unit { this.parentWindow = Some(win) }

    private func getSelectedLabel(): String {
        if (selectedIndex >= 0 && selectedIndex < Int32(items.size)) {
            items[Int64(selectedIndex)]
        } else {
            ""
        }
    }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        if (isOpen) {
            match (parentWindow) {
                case Some(win) =>
                    if (!win.hasOverlay()) { isOpen = false; hoveredItemIndex = -1 }
                case None => ()
            }
        }

        let frameX = match (layoutFrame) { case Some(f) => f.x; case None => Float32(0.0) }
        let frameY = match (layoutFrame) { case Some(f) => f.y; case None => Float32(0.0) }
        let frameW = match (layoutFrame) { case Some(f) => f.width; case None => Float32(200.0) }
        let c = Theme.colors()
        let bgColor = if (isHovered) { c.buttonHover } else { c.inputBg }
        canvas.fillRoundedRect(frameX, frameY, frameW, buttonHeight, 4.0, bgColor)
        canvas.drawRoundedRect(frameX, frameY, frameW, buttonHeight, 4.0, 1.0, c.inputBorder)
        let label = getSelectedLabel()
        if (label.size > 0) {
            canvas.drawTextAligned(frameX + 8.0, frameY, frameW - 28.0, buttonHeight, label, "Microsoft YaHei", 13.0, 0, c.textPrimary)
        }
        let arrowX = frameX + frameW - 18.0
        let arrowY = frameY + buttonHeight / 2.0 - 3.0
        canvas.drawLine(arrowX, arrowY, arrowX + 8.0, arrowY, 1.5, c.textSecondary)
        canvas.drawLine(arrowX + 2.0, arrowY + 3.0, arrowX + 6.0, arrowY + 3.0, 1.5, c.textSecondary)
        canvas.drawLine(arrowX + 4.0, arrowY + 6.0, arrowX + 4.0, arrowY + 6.0, 1.5, c.textSecondary)
        if (isOpen) {
            let (dropX, dropY) = getDropDownPosition(frameY)
            paintDropdown(canvas, initialWidth, initialHeight, currentWidth, currentHeight, dropX, dropY)
        }
    }

    public func paintDropdown(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32, dropX: Float32, dropY: Float32): Unit {
        let c = Theme.colors()
        let count = items.size
        let dropH = if (Float32(count) * itemHeight > dropDownMaxHeight) { dropDownMaxHeight } else { Float32(count) * itemHeight }

        canvas.drawShadow(dropX, dropY, Float32(200.0), dropH, 4.0, 6.0, 0.0, 4.0, c.shadow)
        canvas.fillRoundedRect(dropX, dropY, Float32(200.0), dropH, 4.0, c.popupBg)
        canvas.drawRoundedRect(dropX, dropY, Float32(200.0), dropH, 4.0, 1.0, c.popupBorder)

        for (i in 0..count) {
            let itemY = dropY + Float32(i) * itemHeight
            let itemIdx = Int32(i)
            if (itemIdx == hoveredItemIndex || itemIdx == selectedIndex) {
                canvas.fillRoundedRect(dropX + 2.0, itemY + 1.0, Float32(196.0), itemHeight - 2.0, 3.0, c.popupItemHover)
            }
            let textColor = if (itemIdx == selectedIndex) { c.accent } else { c.popupItemText }
            canvas.drawTextAligned(dropX + 8.0, itemY, Float32(184.0), itemHeight, items[i], "Microsoft YaHei", 13.0, 0, textColor)
        }
    }

    public func hitTestDropdown(x: Float32, y: Float32, dropX: Float32, dropY: Float32): Bool {
        let count = items.size
        let dropH = if (Float32(count) * itemHeight > dropDownMaxHeight) { dropDownMaxHeight } else { Float32(count) * itemHeight }
        x >= dropX && x <= dropX + Float32(200.0) && y >= dropY && y <= dropY + dropH
    }

    public func handleDropdownClick(x: Float32, y: Float32, dropX: Float32, dropY: Float32): Bool {
        let relY = y - dropY
        let idx = Int32(relY / itemHeight)
        if (idx >= 0 && idx < Int32(items.size)) {
            selectedIndex = idx
            match (onSelectionChanged) {
                case Some(cb) => cb(selectedIndex, items[Int64(selectedIndex)])
                case None => ()
            }
            return true
        }
        false
    }

    public func getDropDownPosition(frameY: Float32): (Float32, Float32) {
        let frameX = match (layoutFrame) { case Some(f) => f.x; case None => Float32(0.0) }
        (frameX, frameY + buttonHeight + 2.0)
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        match (layoutFrame) {
            case Some(f) =>
                let inButton = x >= f.x && x <= f.x + f.width && y >= f.y && y <= f.y + buttonHeight
                if (inButton) { return true }
                if (isOpen) {
                    let (dropX, dropY) = getDropDownPosition(f.y)
                    return hitTestDropdown(x, y, dropX, dropY)
                }
                false
            case None => false
        }
    }

    public func handleEvent(event: Event): Bool {
        if (isOpen) {
            return handleOpenEvent(event)
        }
        match (event.eventType) {
            case EventType.MouseEnter =>
                isHovered = true
                true
            case EventType.MouseLeave =>
                isHovered = false
                true
            case EventType.MouseUp =>
                openDropdown()
                true
            case _ => false
        }
    }

    private func openDropdown(): Unit {
        isOpen = true
        hoveredItemIndex = selectedIndex
        match (parentWindow) {
            case Some(win) => win.showOverlay(this)
            case None => ()
        }
    }

    private func closeDropdown(): Unit {
        isOpen = false
        hoveredItemIndex = -1
        match (parentWindow) {
            case Some(win) => win.dismissOverlay()
            case None => ()
        }
    }

    private func handleOpenEvent(event: Event): Bool {
        let frameX = match (layoutFrame) { case Some(f) => f.x; case None => Float32(0.0) }
        let frameY = match (layoutFrame) { case Some(f) => f.y; case None => Float32(0.0) }
        let (dropX, dropY) = getDropDownPosition(frameY)

        match (event.eventType) {
            case EventType.MouseMove =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        if (hitTestDropdown(me.x, me.y, dropX, dropY)) {
                            let relY = me.y - dropY
                            hoveredItemIndex = Int32(relY / itemHeight)
                        } else {
                            hoveredItemIndex = -1
                        }
                    case None => ()
                }
                true
            case EventType.MouseUp =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        if (hitTestDropdown(me.x, me.y, dropX, dropY)) {
                            handleDropdownClick(me.x, me.y, dropX, dropY)
                        }
                        closeDropdown()
                    case None => closeDropdown()
                }
                true
            case _ => false
        }
    }

    public func contains(x: Float32, y: Float32): Bool { true }
    public func updateAnimation(tickCount: Int64): Bool { false }
    public func findLeafAt(x: Float32, y: Float32): Widget { this }
    public func getLayoutMinWidth(): Float32 { 160.0 }
    public func getLayoutMinHeight(): Float32 { buttonHeight }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }
}
