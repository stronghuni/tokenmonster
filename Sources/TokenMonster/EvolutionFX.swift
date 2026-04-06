import Cocoa

enum EvolutionFX {
    /// Sustained haptic pulses for ~3 seconds on Force Touch trackpads.
    /// Uses .common run loop mode so the timer keeps firing even while a
    /// menu is open or the app is inactive.
    static func playHaptic() {
        let mgr = NSHapticFeedbackManager.defaultPerformer
        let pulseInterval: TimeInterval = 0.15
        let totalDuration: TimeInterval = 3.0
        let totalPulses = Int(totalDuration / pulseInterval)  // ~20

        // Fire one immediately so you feel *something* right away.
        mgr.perform(.levelChange, performanceTime: .now)
        NSLog("TokenMonster: evolution haptic start (pulses=\(totalPulses))")

        var count = 0
        let timer = Timer(timeInterval: pulseInterval, repeats: true) { t in
            NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .now)
            count += 1
            if count >= totalPulses - 1 {
                t.invalidate()
                NSLog("TokenMonster: evolution haptic end")
            }
        }
        RunLoop.main.add(timer, forMode: .common)

        // Audible fallback for non-Force-Touch hardware
        NSSound.beep()
    }
}
