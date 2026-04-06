import Cocoa

enum EvolutionFX {
    /// Sustained haptic pulses for 3 seconds on Force Touch trackpads.
    static func playHaptic() {
        let mgr = NSHapticFeedbackManager.defaultPerformer
        let pulseInterval: TimeInterval = 0.15
        let totalDuration: TimeInterval = 3.0
        let totalPulses = Int(totalDuration / pulseInterval)  // ~20
        var count = 0
        mgr.perform(.levelChange, performanceTime: .now)
        Timer.scheduledTimer(withTimeInterval: pulseInterval, repeats: true) { t in
            mgr.perform(.levelChange, performanceTime: .now)
            count += 1
            if count >= totalPulses - 1 { t.invalidate() }
        }
    }
}
