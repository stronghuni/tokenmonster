import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    var controller: StatusItemController!
    var tracker: TokenTracker!

    func applicationDidFinishLaunching(_ notification: Notification) {
        controller = StatusItemController()
        controller.start()

        tracker = TokenTracker()
        tracker.onUpdate = { [weak self] snapshot in
            self?.controller.apply(snapshot: snapshot)
        }
        controller.onReset = { [weak self] in
            self?.tracker.resetBaseline()
        }
        controller.onForceEvolve = { [weak self] in
            self?.tracker.forceEvolveNextStage()
        }
        tracker.onEvolution = { [weak self] from, to in
            DispatchQueue.main.async {
                EvolutionFX.playHaptic()
                self?.controller.animator.playEvolutionShake()
                self?.controller.flashHint("✨ \(from.displayName) → \(to.displayName)!")
            }
        }
        tracker.start()
    }
}
