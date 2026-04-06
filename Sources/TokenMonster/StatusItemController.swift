import Cocoa

final class StatusItemController: NSObject {
    let statusItem: NSStatusItem
    let animator = SpriteAnimator()

    var onReset: (() -> Void)?
    var onForceEvolve: (() -> Void)?

    private let popover = NSPopover()
    private let dashboardView = DashboardView()
    private let dashboardVC = NSViewController()
    private var latestSnapshot: UsageSnapshot?

    override init() {
        statusItem = NSStatusBar.system.statusItem(withLength: SpriteAnimator.menubarPointSize)
        super.init()
        animator.statusButton = statusItem.button

        dashboardVC.view = dashboardView
        popover.contentViewController = dashboardVC
        popover.behavior = .transient
        popover.animates = true

        dashboardView.onMenuRequested = { [weak self] in self?.showActionsMenu() }

        if let btn = statusItem.button {
            btn.target = self
            btn.action = #selector(buttonClicked(_:))
            btn.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    func start() {
        animator.setStage(.egg)
    }

    // MARK: - Popover

    @objc private func buttonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp {
            showActionsMenu()
            return
        }
        togglePopover()
    }

    private func togglePopover() {
        guard let btn = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            if let snap = latestSnapshot {
                dashboardView.apply(snapshot: snap, quote: MonsterQuotes.random())
            }
            popover.show(relativeTo: btn.bounds, of: btn, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    // MARK: - Action menu (from ••• button or right-click)

    private func showActionsMenu() {
        let menu = NSMenu()

        let login = NSMenuItem(title: "로그인 시 자동 실행", action: #selector(toggleLogin), keyEquivalent: "")
        login.target = self
        login.state = LaunchAtLogin.isEnabled ? .on : .off
        menu.addItem(login)

        menu.addItem(.separator())

        let debugHeader = NSMenuItem(title: "디버그", action: nil, keyEquivalent: "")
        debugHeader.isEnabled = false
        menu.addItem(debugHeader)

        let force = NSMenuItem(title: "  강제 진화 (다음 단계)", action: #selector(forceEvolve), keyEquivalent: "")
        force.target = self
        menu.addItem(force)

        let reset = NSMenuItem(title: "  새 알 받기 (처음부터)", action: #selector(reset), keyEquivalent: "")
        reset.target = self
        menu.addItem(reset)

        menu.addItem(.separator())

        let quit = NSMenuItem(title: "종료", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func quit() { NSApp.terminate(nil) }

    @objc private func toggleLogin(_ sender: NSMenuItem) {
        let newState: NSControl.StateValue = (sender.state == .on) ? .off : .on
        LaunchAtLogin.setEnabled(newState == .on)
    }

    @objc private func forceEvolve() { onForceEvolve?() }

    @objc private func reset() {
        let alert = NSAlert()
        alert.messageText = "새 알을 받으시겠어요?"
        alert.informativeText = "지금 몬스터는 사라지고, 앞으로 사용하는 토큰만 새 몬스터가 먹게 됩니다."
        alert.addButton(withTitle: "새로 시작")
        alert.addButton(withTitle: "취소")
        NSApp.activate(ignoringOtherApps: true)
        if alert.runModal() == .alertFirstButtonReturn {
            onReset?()
        }
    }

    // MARK: - Data

    func apply(snapshot: UsageSnapshot) {
        latestSnapshot = snapshot
        DispatchQueue.main.async {
            self.animator.setStage(snapshot.stage)
            self.animator.setTokensPerMinute(snapshot.tokensPerMinute)
            if self.popover.isShown {
                self.dashboardView.apply(snapshot: snapshot, quote: MonsterQuotes.random())
            }
        }
    }

    func flashHint(_ text: String) {
        // used on evolution — just refresh if visible
        if popover.isShown, let snap = latestSnapshot {
            dashboardView.apply(snapshot: snap, quote: text)
        }
    }
}
