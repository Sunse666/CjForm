package cjform

import std.collection.*

public class Popover <: Widget {
    private var content: Widget
    private var anchorX: Float32
    private var anchorY: Float32
    private var prefWidth: Float32
    private var prefHeight: Float32
    private var cornerRadius: Float32
    private var shadowBlur: Float32
    private var layoutFrame: Option<LayoutFrame>

    public init(content: Widget, anchorX: Float32, anchorY: Float32, width: Float32, height: Float32) {
        this.content = content
        this.anchorX = anchorX
        this.anchorY = anchorY
        this.prefWidth = width
        this.prefHeight = height
        this.cornerRadius = 6.0
        this.shadowBlur = 8.0
        this.layoutFrame = None
    }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        let c = Theme.colors()
        var popX = anchorX + 4.0
        var popY = anchorY + 4.0
        if (popX + prefWidth > Float32(currentWidth)) { popX = anchorX - prefWidth - 4.0 }
        if (popY + prefHeight > Float32(currentHeight)) { popY = anchorY - prefHeight - 4.0 }
        if (popX < 0.0) { popX = 4.0 }
        if (popY < 0.0) { popY = 4.0 }

        canvas.drawShadow(popX, popY, prefWidth, prefHeight, cornerRadius, shadowBlur, 0.0, 4.0, c.shadow)
        canvas.fillRoundedRect(popX, popY, prefWidth, prefHeight, cornerRadius, c.popupBg)
        canvas.drawRoundedRect(popX, popY, prefWidth, prefHeight, cornerRadius, 1.0, c.popupBorder)
        content.setLayoutFrame(LayoutFrame(popX + 4.0, popY + 4.0, prefWidth - 8.0, prefHeight - 8.0))
        content.paint(canvas, initialWidth, initialHeight, currentWidth, currentHeight)
        content.clearLayoutFrame()
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        content.hitTest(x, y, initialWidth, initialHeight, currentWidth, currentHeight)
    }

    public func handleEvent(event: Event): Bool {
        match (event.eventType) {
            case EventType.MouseUp | EventType.MouseDown =>
                content.handleEvent(event)
            case _ => false
        }
    }

    public func contains(x: Float32, y: Float32): Bool { true }
    public func updateAnimation(tickCount: Int64): Bool { false }

    public func findLeafAt(x: Float32, y: Float32): Widget {
        if (content.hitTest(x, y, Float32(0.0), Float32(0.0), Float32(0.0), Float32(0.0))) {
            return content.findLeafAt(x, y)
        }
        this
    }

    public func getLayoutMinWidth(): Float32 { prefWidth }
    public func getLayoutMinHeight(): Float32 { prefHeight }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }
}
