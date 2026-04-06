import Cocoa

final class SpriteAnimator {
    weak var statusButton: NSStatusBarButton?
    static let menubarPointSize: CGFloat = 32

    private var frames: [NSImage] = []
    private var frameIndex = 0
    private var timer: Timer?
    private var baseInterval: TimeInterval = 0.3
    private var speedMultiplier: Double = 1.0
    private var currentStage: Stage?

    func setStage(_ stage: Stage) {
        guard stage != currentStage else { return }
        currentStage = stage
        let sprite = ColorSprites.sprite(for: stage)
        frames = (0..<sprite.frames.count).map { idx in
            PixelRenderer.renderColor(
                sprite: sprite,
                frameIndex: idx,
                pointSize: Self.menubarPointSize,
                bitmapScale: 2
            )
        }
        frameIndex = 0
        restart()
    }

    func setTokensPerMinute(_ tpm: Double) {
        let mult: Double
        switch tpm {
        case 0..<500:        mult = 1.0
        case 500..<2_000:    mult = 1.8
        case 2_000..<5_000:  mult = 2.8
        case 5_000..<10_000: mult = 4.0
        default:             mult = 6.0
        }
        if abs(mult - speedMultiplier) > 0.01 {
            speedMultiplier = mult
            restart()
        }
    }

    /// Shakes the icon left-right for 3 seconds on evolution.
    func playEvolutionShake() {
        guard let btn = statusButton, !frames.isEmpty else { return }
        timer?.invalidate()
        let base = frames[frameIndex % frames.count]
        let shakeFrames: [NSImage] = [
            Self.shifted(base, dx: -2),
            base,
            Self.shifted(base, dx: 2),
            base,
        ]
        var count = 0
        let interval: TimeInterval = 0.08
        let ticks = Int(3.0 / interval)
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] t in
            btn.image = shakeFrames[count % shakeFrames.count]
            count += 1
            if count >= ticks {
                t.invalidate()
                self?.restart()
            }
        }
    }

    private static func shifted(_ img: NSImage, dx: Int) -> NSImage {
        let size = img.size
        let out = NSImage(size: size)
        out.lockFocus()
        img.draw(at: NSPoint(x: CGFloat(dx), y: 0),
                 from: NSRect(origin: .zero, size: size),
                 operation: .copy, fraction: 1)
        out.unlockFocus()
        return out
    }

    private func restart() {
        timer?.invalidate()
        let interval = baseInterval / speedMultiplier
        let t = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
            guard let self, !self.frames.isEmpty else { return }
            self.statusButton?.image = self.frames[self.frameIndex % self.frames.count]
            self.frameIndex += 1
        }
        timer = t
        RunLoop.main.add(t, forMode: .common)
        statusButton?.image = frames[frameIndex % max(frames.count, 1)]
    }
}
