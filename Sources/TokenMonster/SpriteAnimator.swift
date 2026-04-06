import Cocoa

final class SpriteAnimator {
    weak var statusButton: NSStatusBarButton?

    private var frames: [NSImage] = []
    private var frameIndex = 0
    private var timer: Timer?
    private var baseInterval: TimeInterval = 0.22
    private var speedMultiplier: Double = 1.0
    private var currentStage: Stage?

    /// Builds a 4-frame breathing cycle from two source grids:
    /// A(bob=0) → A(bob=1, lifted) → B(bob=0) → B(bob=-1, squashed)
    /// This gives an actual "jumping/breathing" feel in tight canvas.
    private static func breathe(_ a: [[Int]], _ b: [[Int]]) -> [NSImage] {
        [
            PixelRenderer.render(grid: a, yBob: 0),
            PixelRenderer.render(grid: a, yBob: 1),
            PixelRenderer.render(grid: b, yBob: 0),
            PixelRenderer.render(grid: b, yBob: -1),
        ]
    }

    func setStage(_ stage: Stage) {
        guard stage != currentStage else { return }
        currentStage = stage

        switch stage {
        case .egg:
            // Egg just wobbles left-right (6 frames for smoother motion)
            frames = [
                PixelRenderer.render(grid: PixelSprites.eggA, rotationDegrees: -8),
                PixelRenderer.render(grid: PixelSprites.eggA, rotationDegrees: -4),
                PixelRenderer.render(grid: PixelSprites.eggA, rotationDegrees:  0),
                PixelRenderer.render(grid: PixelSprites.eggA, rotationDegrees:  4),
                PixelRenderer.render(grid: PixelSprites.eggA, rotationDegrees:  8),
                PixelRenderer.render(grid: PixelSprites.eggA, rotationDegrees:  0),
            ]
        case .baby:    frames = Self.breathe(PixelSprites.babyA,     PixelSprites.babyB)
        case .child:   frames = Self.breathe(PixelSprites.childA,    PixelSprites.childB)
        case .teen:    frames = Self.breathe(PixelSprites.teenA,     PixelSprites.teenB)
        case .adult:   frames = Self.breathe(PixelSprites.adultA,    PixelSprites.adultB)
        case .ultimate:frames = Self.breathe(PixelSprites.ultimateA, PixelSprites.ultimateB)
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

    /// Shakes the status icon left-right for 3 seconds (no blink).
    /// Used for evolution feedback together with haptics.
    func playEvolutionShake() {
        guard let btn = statusButton, !frames.isEmpty else { return }
        timer?.invalidate()
        let base = frames[frameIndex % frames.count]
        let shakeFrames: [NSImage] = [
            Self.shifted(base, dx: -1),
            base,
            Self.shifted(base, dx: 1),
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
        let out = NSImage(size: NSSize(width: 22, height: 22))
        out.lockFocus()
        img.draw(at: NSPoint(x: CGFloat(dx), y: 0),
                 from: NSRect(origin: .zero, size: img.size),
                 operation: .copy, fraction: 1)
        out.unlockFocus()
        out.isTemplate = true
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
