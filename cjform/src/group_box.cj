package cjform

public class GroupBox <: Widget {
    private var title: String
    private var content: Option<Widget>
    private var layoutFrame: Option<LayoutFrame>

    public init(title: String) {
        this.title = title
        this.content = None<Widget>
        this.layoutFrame = None
    }

    public func setContent(widget: Widget): Unit { this.content = Some(widget) }
    public func getContent(): Option<Widget> { content }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        let (x, y, w, h) = getFrame()
        let c = Theme.colors()
        let titleH: Float32 = 22.0
        let halfTitle: Float32 = titleH / Float32(2.0)
        let titleW = canvas.measureTextWidth(title, "Microsoft YaHei", Float32(13.0))
        let lineY = y + halfTitle
        canvas.drawLine(x + Float32(8.0), lineY, x + Float32(12.0), lineY, Float32(1.0), c.border)
        let gapEnd = x + Float32(16.0) + titleW
        canvas.drawLine(gapEnd, lineY, x + w - Float32(8.0), lineY, Float32(1.0), c.border)
        canvas.drawText(x + Float32(14.0), y, title, "Microsoft YaHei", Float32(13.0), c.textPrimary)
        canvas.drawLine(x + Float32(8.0), lineY, x + Float32(8.0), y + h - Float32(8.0), Float32(1.0), c.border)
        canvas.drawLine(x + w - Float32(8.0), lineY, x + w - Float32(8.0), y + h - Float32(8.0), Float32(1.0), c.border)
        canvas.drawLine(x + Float32(8.0), y + h - Float32(8.0), x + w - Float32(8.0), y + h - Float32(8.0), Float32(1.0), c.border)
        let contentX = x + Float32(12.0)
        let contentY = y + titleH + Float32(4.0)
        let contentW = w - Float32(24.0)
        let contentH = h - titleH - Float32(12.0)
        match (content) {
            case Some(child) =>
                if (contentW > Float32(0.0) && contentH > Float32(0.0)) {
                    child.setLayoutFrame(LayoutFrame(contentX, contentY, contentW, contentH))
                    child.paint(canvas, initialWidth, initialHeight, currentWidth, currentHeight)
                }
            case None => ()
        }
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        match (layoutFrame) { case Some(f) => x >= f.x && x <= f.x + f.width && y >= f.y && y <= f.y + f.height; case None => false }
    }

    public func handleEvent(event: Event): Bool {
        match (content) {
            case Some(child) => child.handleEvent(event)
            case None => false
        }
    }

    private func getFrame(): (Float32, Float32, Float32, Float32) {
        match (layoutFrame) { case Some(f) => (f.x, f.y, f.width, f.height); case None => (Float32(0.0), Float32(0.0), Float32(200.0), Float32(100.0)) }
    }

    public func contains(x: Float32, y: Float32): Bool { true }
    public func updateAnimation(tickCount: Int64): Bool {
        match (content) { case Some(c) => c.updateAnimation(tickCount); case None => false }
    }
    public func getLayoutMinWidth(): Float32 { Float32(100.0) }
    public func getLayoutMinHeight(): Float32 { Float32(60.0) }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }

    public func findLeafAt(x: Float32, y: Float32): Widget {
        match (content) {
            case Some(child) =>
                if (child.hitTest(x, y, 0.0, 0.0, 0.0, 0.0)) {
                    child.findLeafAt(x, y)
                } else { this }
            case None => this
        }
    }
}
