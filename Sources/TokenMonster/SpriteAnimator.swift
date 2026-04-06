import Cocoa

final class SpriteAnimator {
    weak var statusButton: NSStatusBarButton?

    private var frames: [NSImage] = []
    private var frameIndex = 0
    private var timer: Timer?
    private var baseInterval: TimeInterval = 0.4
    private var speedMultiplier: Double = 1.0
    private var currentStage: Stage?

    func setStage(_ stage: Stage) {
        guard stage != currentStage else { return }
        currentStage = stage

        switch stage {
        case .egg:
            frames = [
                PixelRenderer.render(grid: PixelSprites.eggA, rotationDegrees: -6),
                PixelRenderer.render(grid: PixelSprites.eggA, rotationDegrees:  0),
                PixelRenderer.render(grid: PixelSprites.eggA, rotationDegrees:  6),
                PixelRenderer.render(grid: PixelSprites.eggA, rotationDegrees:  0),
            ]
        case .baby:
            frames = [ PixelRenderer.render(grid: PixelSprites.babyA),
                       PixelRenderer.render(grid: PixelSprites.babyB) ]
        case .child:
            frames = [ PixelRenderer.render(grid: PixelSprites.childA),
                       PixelRenderer.render(grid: PixelSprites.childB) ]
        case .teen:
            frames = [ PixelRenderer.render(grid: PixelSprites.teenA),
                       PixelRenderer.render(grid: PixelSprites.teenB) ]
        case .adult:
            frames = [ PixelRenderer.render(grid: PixelSprites.adultA),
                       PixelRenderer.render(grid: PixelSprites.adultB) ]
        case .ultimate:
            frames = [ PixelRenderer.render(grid: PixelSprites.ultimateA),
                       PixelRenderer.render(grid: PixelSprites.ultimateB) ]
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

    /// Briefly flashes the status icon by inverting + scaling.
    /// Used for evolution feedback together with haptics.
    func playEvolutionFlash() {
        guard let btn = statusButton, !frames.isEmpty else { return }
        // Blink 6 times by toggling image alpha/tint
        let baseImage = frames[frameIndex % frames.count]
        var count = 0
        Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { t in
            count += 1
            btn.appearsDisabled = (count % 2 == 0) ? false : true
            if count >= 10 {
                btn.appearsDisabled = false
                t.invalidate()
                btn.image = baseImage
            }
        }
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
