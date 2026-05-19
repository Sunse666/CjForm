package memory_game

import cjform.*
import std.collection.*
import std.random.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    let win = Window("Memory Match Game", 640, 640)
    win.setMinSize(500, 550)
    win.setBackgroundColor(Color.rgb(35, 38, 45))

    let game = GameWidget()
    game.setLayoutFrame(LayoutFrame(0.0, 0.0, 640.0, 640.0))
    win.addWidget(game)

    win.show()
    win.run()
    Int64(0)
}

// ---- Card Widget ----

class Card <: Widget {
    public let pairId: Int32
    public let symbol: String
    public let color: Color
    public var isFaceUp: Bool
    public var isMatched: Bool
    public var onClick: Option<() -> Unit>
    private var layoutFrame: Option<LayoutFrame>

    public init(pairId: Int32, symbol: String, color: Color) {
        this.pairId = pairId; this.symbol = symbol; this.color = color
        this.isFaceUp = false; this.isMatched = false
        this.onClick = None<() -> Unit>; this.layoutFrame = None
    }

    public func paint(canvas: Canvas, iw: Float32, ih: Float32, cw: Float32, ch: Float32): Unit {
        match (layoutFrame) {
            case Some(f) =>
                if (isMatched) { return }
                if (isFaceUp) {
                    canvas.fillRoundedRect(f.x, f.y, f.width, f.height, Float32(8.0), color)
                    canvas.drawRoundedRect(f.x, f.y, f.width, f.height, Float32(8.0), Float32(2.0), Color.WHITE)
                    canvas.drawTextAligned(f.x, f.y, f.width, f.height, symbol, "Segoe UI Symbol", Float32(30.0), 1, Color.WHITE)
                } else {
                    canvas.fillRoundedRect(f.x, f.y, f.width, f.height, Float32(8.0), Color.rgb(55, 58, 65))
                    canvas.drawRoundedRect(f.x, f.y, f.width, f.height, Float32(8.0), Float32(1.5), Color.rgb(100, 105, 110))
                    canvas.drawTextAligned(f.x, f.y, f.width, f.height, "?", "Segoe UI Symbol", Float32(24.0), 1, Color.rgb(130, 135, 140))
                }
            case None => ()
        }
    }

    public func hitTest(x: Float32, y: Float32, iw: Float32, ih: Float32, cw: Float32, ch: Float32): Bool {
        match (layoutFrame) {
            case Some(f) => !isMatched && x >= f.x && x <= f.x + f.width && y >= f.y && y <= f.y + f.height
            case None => false
        }
    }
    public func handleEvent(event: Event): Bool {
        match (event.eventType) {
            case EventType.MouseDown => match (onClick) { case Some(cb) => cb(); true; case None => false }
            case _ => false
        }
    }
    public func contains(x: Float32, y: Float32): Bool { true }
    public func updateAnimation(tickCount: Int64): Bool { false }
    public func findLeafAt(x: Float32, y: Float32): Widget { this }
    public func getLayoutMinWidth(): Float32 { Float32(80.0) }
    public func getLayoutMinHeight(): Float32 { Float32(100.0) }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }
}

// ---- Game Widget ----

public class GameWidget <: Widget {
    private var cards: ArrayList<Card>
    private var flipped: ArrayList<Int32>
    private var matchCount: Int32
    private var isLocked: Bool
    private var lockStartTime: Int64
    private var matchPending: Bool
    private var matchStartTime: Int64
    private var matchCards: ArrayList<Int32>
    private var statusText: String
    private var layoutFrame: Option<LayoutFrame>
    // timer
    private var gameStartTime: Int64
    private var timeLimitMs: Int64
    private var remainingMs: Int64
    private var isTimeUp: Bool

    public init() {
        this.cards = ArrayList<Card>()
        this.flipped = ArrayList<Int32>()
        this.matchCount = 0
        this.isLocked = false
        this.lockStartTime = 0
        this.matchPending = false
        this.matchStartTime = 0
        this.matchCards = ArrayList<Int32>()
        this.statusText = "Match 12 pairs in 60 seconds!"
        this.layoutFrame = None
        this.gameStartTime = ffi_getTickCount()
        this.timeLimitMs = 60000
        this.remainingMs = 60000
        this.isTimeUp = false

        let symbols = ["♠", "♥", "♦", "♣", "★", "●", "◆", "▲", "■", "✦", "✧", "◉"]
        let colors = [
            Color.rgb(220, 70, 70), Color.rgb(220, 70, 70),
            Color.rgb(70, 140, 220), Color.rgb(70, 140, 220),
            Color.rgb(70, 180, 90), Color.rgb(70, 180, 90),
            Color.rgb(210, 155, 50), Color.rgb(210, 155, 50),
            Color.rgb(160, 80, 200), Color.rgb(160, 80, 200),
            Color.rgb(60, 180, 180), Color.rgb(60, 180, 180),
            Color.rgb(225, 120, 60), Color.rgb(225, 120, 60),
            Color.rgb(120, 150, 190), Color.rgb(120, 150, 190),
            Color.rgb(200, 90, 140), Color.rgb(200, 90, 140),
            Color.rgb(110, 180, 110), Color.rgb(110, 180, 110),
            Color.rgb(185, 160, 80), Color.rgb(185, 160, 80),
            Color.rgb(140, 100, 200), Color.rgb(140, 100, 200),
        ]

        var pool = ArrayList<Card>()
        for (i in 0..12) {
            pool.add(Card(Int32(i), symbols[i], colors[Int64(i * 2)]))
            pool.add(Card(Int32(i), symbols[i], colors[Int64(i * 2)]))
        }
        pool.add(Card(Int32(12), "☆", Color.rgb(255, 200, 50)))

        let rng = Random()
        var shuffled = ArrayList<Card>()
        var n = pool.size
        while (n > 0) {
            let ri = rng.nextFloat64() * Float64(n)
            var idx = Int64(ri)
            if (idx >= n) { idx = Int64(n - 1) }
            shuffled.add(pool[idx])
            pool[idx] = pool[Int64(n - 1)]
            n = n - 1
        }
        this.cards = shuffled

        for (i in 0..shuffled.size) {
            let si = Int32(i)
            shuffled[Int64(i)].onClick = Some<() -> Unit>({ => onCardClick(si) })
        }
    }

    private func onCardClick(index: Int32): Unit {
        if (isLocked || matchPending || isTimeUp) { return }
        if (matchCount >= 12) { return }
        if (index < 0 || index >= Int32(cards.size)) { return }
        let card = cards[Int64(index)]
        if (card.isFaceUp || card.isMatched) { return }

        if (card.pairId == 12) {
            card.isFaceUp = true
            var targetIdx: Int32 = -1
            for (i in 0..cards.size) {
                let c = cards[i]
                if (c.isFaceUp && !c.isMatched && c.pairId != 12 && Int32(i) != index) {
                    targetIdx = Int32(i); break
                }
            }
            if (targetIdx >= 0) {
                jokerMatch(targetIdx)
                matchCards.add(index)
            } else {
                flipped.add(index)
            }
            return
        }

        var hasJoker: Bool = false
        var jokerIdx: Int32 = -1
        for (fi in flipped) {
            if (cards[Int64(fi)].pairId == 12) { hasJoker = true; jokerIdx = fi; break }
        }
        if (hasJoker) {
            card.isFaceUp = true
            jokerMatch(index)
            matchCards.add(jokerIdx)
            flipped = ArrayList<Int32>()
            return
        }

        card.isFaceUp = true
        var otherIdx: Int32 = -1
        for (i in 0..flipped.size) {
            if (flipped[i] != index) { otherIdx = flipped[i]; break }
        }

        if (otherIdx >= 0) {
            let other = cards[Int64(otherIdx)]
            if (other.pairId == card.pairId) {
                matchCards = ArrayList<Int32>()
                matchCards.add(otherIdx)
                matchCards.add(index)
                matchPending = true
                matchStartTime = ffi_getTickCount()
                flipped = ArrayList<Int32>()
            } else {
                flipped.add(index)
                isLocked = true
                lockStartTime = ffi_getTickCount()
            }
        } else {
            flipped.add(index)
        }
    }

    private func jokerMatch(targetIdx: Int32): Unit {
        let tp = cards[Int64(targetIdx)].pairId
        for (i in 0..cards.size) {
            let c = cards[i]
            if (Int32(i) != targetIdx && !c.isMatched && c.pairId == tp) {
                c.isFaceUp = true
                matchCards = ArrayList<Int32>()
                matchCards.add(targetIdx)
                matchCards.add(Int32(i))
                matchPending = true
                matchStartTime = ffi_getTickCount()
                break
            }
        }
    }

    public func paint(canvas: Canvas, iw: Float32, ih: Float32, cw: Float32, ch: Float32): Unit {
        let (x, y, w, h) = getFrame()
        let c = Theme.colors()

        // ---- Header ----
        let headerY = y + Float32(12.0)
        canvas.drawTextAligned(x, headerY, w, Float32(22.0), "Memory Match Game", "Microsoft YaHei", Float32(18.0), 1, c.accent)

        // ---- Timer bar ----
        let barY = headerY + Float32(26.0)
        let barH = Float32(8.0)
        let barW = Float32(300.0)
        let barX = x + (w - barW) / Float32(2.0)
        let ratio = clampF(Float32(remainingMs) / Float32(timeLimitMs), 0.0, 1.0)
        let fillW = barW * ratio

        // track
        canvas.fillRoundedRect(barX, barY, barW, barH, Float32(4.0), c.bgTertiary)
        // fill — changes color as time runs out
        let fillColor = if (ratio > 0.5) { c.accent } else if (ratio > 0.25) { c.warning } else { c.danger }
        if (fillW > 1.0) {
            canvas.fillRoundedRect(barX, barY, fillW, barH, Float32(4.0), fillColor)
        }

        // time text
        let secs = remainingMs / 1000
        let timeText = "${secs}s"
        let timeTextColor = if (ratio > 0.25) { c.textSecondary } else { c.danger }
        canvas.drawTextAligned(barX + barW + Float32(12.0), barY - Float32(3.0), Float32(50.0), Float32(14.0), timeText, "Microsoft YaHei", Float32(14.0), 0, timeTextColor)

        // status line
        canvas.drawTextAligned(x, barY + Float32(16.0), w, Float32(16.0), statusText, "Microsoft YaHei", Float32(12.0), 1, c.textSecondary)

        // ---- Card grid ----
        let cardW = Float32(80.0)
        let cardH = Float32(100.0)
        let gap = Float32(10.0)
        let gridW = cardW * Float32(5.0) + gap * Float32(4.0)
        let startX = x + (w - gridW) / Float32(2.0)
        let startY = barY + Float32(42.0)

        for (row in 0..5) {
            for (col in 0..5) {
                let card = cards[Int64(row * 5 + col)]
                let cx = startX + Float32(col) * (cardW + gap)
                let cy = startY + Float32(row) * (cardH + gap)
                card.setLayoutFrame(LayoutFrame(cx, cy, cardW, cardH))
                card.paint(canvas, iw, ih, cw, ch)
            }
        }

        // ---- End screen overlay ----
        if (isTimeUp || matchCount >= 12) {
            let overlayH = Float32(160.0)
            let overlayY = y + (h - overlayH) / Float32(2.0)
            canvas.fillRoundedRect(x + Float32(40.0), overlayY, w - Float32(80.0), overlayH, Float32(12.0), Color.rgba(30, 32, 38, 240))
            canvas.drawRoundedRect(x + Float32(40.0), overlayY, w - Float32(80.0), overlayH, Float32(12.0), Float32(2.0), c.accent)

            let resultText = if (matchCount >= 12) { "YOU WIN!" } else { "TIME'S UP" }
            let resultColor = if (matchCount >= 12) { c.success } else { c.danger }
            canvas.drawTextAligned(x, overlayY + Float32(28.0), w, Float32(36.0), resultText, "Microsoft YaHei", Float32(28.0), 1, resultColor)

            let detailText = "Matched ${matchCount} / 12 pairs"
            canvas.drawTextAligned(x, overlayY + Float32(70.0), w, Float32(20.0), detailText, "Microsoft YaHei", Float32(15.0), 1, c.textSecondary)

            let hintText = "Close window and re-run to play again"
            canvas.drawTextAligned(x, overlayY + Float32(100.0), w, Float32(18.0), hintText, "Microsoft YaHei", Float32(12.0), 1, c.textTertiary)
        }
    }

    public func hitTest(x: Float32, y: Float32, iw: Float32, ih: Float32, cw: Float32, ch: Float32): Bool {
        match (layoutFrame) { case Some(f) => x >= f.x && x <= f.x + f.width && y >= f.y && y <= f.y + f.height; case None => true }
    }

    public func handleEvent(event: Event): Bool {
        if (isTimeUp || matchCount >= 12) { return false }
        match (event.eventType) {
            case EventType.MouseDown =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        layoutCards()
                        for (i in 0..cards.size) {
                            if (cards[i].hitTest(me.x, me.y, Float32(640.0), Float32(640.0), Float32(640.0), Float32(640.0))) {
                                onCardClick(Int32(i)); return true
                            }
                        }
                        false
                    case None => false
                }
            case _ => false
        }
    }

    private func layoutCards(): Unit {
        let (x, y, w, _) = getFrame()
        let cardW = Float32(80.0); let cardH = Float32(100.0); let gap = Float32(10.0)
        let gridW = cardW * Float32(5.0) + gap * Float32(4.0)
        let startX = x + (w - gridW) / Float32(2.0)
        let startY = y + Float32(12.0) + Float32(26.0) + Float32(8.0) + Float32(16.0) + Float32(42.0)
        for (row in 0..5) {
            for (col in 0..5) {
                let cx = startX + Float32(col) * (cardW + gap)
                let cy = startY + Float32(row) * (cardH + gap)
                cards[Int64(row * 5 + col)].setLayoutFrame(LayoutFrame(cx, cy, cardW, cardH))
            }
        }
    }

    public func contains(x: Float32, y: Float32): Bool { true }

    public func updateAnimation(tickCount: Int64): Bool {
        // Timer
        remainingMs = timeLimitMs - (tickCount - gameStartTime)
        if (remainingMs < 0) { remainingMs = 0 }
        if (remainingMs <= 0 && !isTimeUp && matchCount < 12) {
            isTimeUp = true
            for (c in cards) { c.isFaceUp = false }
            statusText = "Time's up! Matched ${matchCount}/12 pairs."
        }
        if (matchCount >= 12) {
            statusText = "You Win! All pairs matched!"
        }

        // Match delay
        if (matchPending) {
            if (tickCount - matchStartTime > 400) {
                for (i in 0..matchCards.size) { cards[Int64(matchCards[i])].isMatched = true }
                matchCount = matchCount + 1
                matchCards = ArrayList<Int32>()
                matchPending = false
            }
            return true
        }

        // Flip-back delay
        if (isLocked && lockStartTime > 0) {
            if (tickCount - lockStartTime > 800) {
                for (i in 0..flipped.size) {
                    let c = cards[Int64(flipped[i])]
                    if (!c.isMatched) { c.isFaceUp = false }
                }
                flipped = ArrayList<Int32>()
                isLocked = false
            }
            return true
        }

        // Keep timer running
        if (!isTimeUp && matchCount < 12) { return true }
        false
    }

    public func findLeafAt(x: Float32, y: Float32): Widget {
        for (i in 0..cards.size) {
            if (cards[i].hitTest(x, y, 0.0, 0.0, 0.0, 0.0)) { return cards[i] }
        }
        this
    }

    private func getFrame(): (Float32, Float32, Float32, Float32) {
        match (layoutFrame) { case Some(f) => (f.x, f.y, f.width, f.height); case None => (0.0, 0.0, 640.0, 640.0) }
    }

    private func clampF(v: Float32, lo: Float32, hi: Float32): Float32 {
        if (v < lo) { lo } else if (v > hi) { hi } else { v }
    }

    public func getLayoutMinWidth(): Float32 { Float32(500.0) }
    public func getLayoutMinHeight(): Float32 { Float32(580.0) }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }
}
