import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    var controller: StatusItemController!
    var tracker: TokenTracker!
    var dashboard: DashboardWindowController!
    private var latestSnapshot: UsageSnapshot?

    func applicationDidFinishLaunching(_ notification: Notification) {
        controller = StatusItemController()
        controller.start()
        dashboard = DashboardWindowController()

        tracker = TokenTracker()
        tracker.onUpdate = { [weak self] snapshot in
            self?.latestSnapshot = snapshot
            self?.controller.apply(snapshot: snapshot)
            self?.dashboard.apply(snapshot: snapshot)
        }
        controller.onReset = { [weak self] in
            self?.tracker.resetBaseline()
        }
        controller.onForceEvolve = { [weak self] in
            self?.tracker.forceEvolveNextStage()
        }
        controller.onOpenDashboard = { [weak self] in
            self?.dashboard.show()
        }
        tracker.onEvolution = { [weak self] from, to in
            DispatchQueue.main.async {
                EvolutionFX.playHaptic()
                self?.controller.animator.playEvolutionFlash()
                self?.controller.flashHint("✨ \(from.displayName) → \(to.displayName)!")
            }
        }
        tracker.start()
    }
}
