import Cocoa

enum EvolutionFX {
    /// Triple haptic pulse ("두근두근두근") on Force Touch trackpads.
    static func playHaptic() {
        let mgr = NSHapticFeedbackManager.defaultPerformer
        var count = 0
        mgr.perform(.levelChange, performanceTime: .now)
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { t in
            mgr.perform(.levelChange, performanceTime: .now)
            count += 1
            if count >= 2 { t.invalidate() }
        }
    }
}
