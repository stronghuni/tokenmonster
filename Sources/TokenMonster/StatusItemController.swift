import Cocoa

final class StatusItemController {
    let statusItem: NSStatusItem
    let animator = SpriteAnimator()
    var onReset: (() -> Void)?
    var onForceEvolve: (() -> Void)?
    var onOpenDashboard: (() -> Void)?
    private let menu = NSMenu()

    private let stageItem  = NSMenuItem(title: "🥚 Flamimon (알)", action: nil, keyEquivalent: "")
    private let hintItem   = NSMenuItem(title: MonsterQuotes.random(), action: nil, keyEquivalent: "")
    private var quoteTimer: Timer?
    private let totalItem  = NSMenuItem(title: "누적  0 토큰", action: nil, keyEquivalent: "")
    private let todayItem  = NSMenuItem(title: "오늘  0 토큰", action: nil, keyEquivalent: "")
    private let tpmItem    = NSMenuItem(title: "속도  0 tok/min", action: nil, keyEquivalent: "")
    private let projectsHeader = NSMenuItem(title: "프로젝트별 (상위 5)", action: nil, keyEquivalent: "")

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        animator.statusButton = statusItem.button
        buildMenu()
        statusItem.menu = menu
    }

    func start() {
        animator.setStage(.egg)
        // Rotate the monster's quote every 20 seconds while idle.
        let t = Timer(timeInterval: 20, repeats: true) { [weak self] _ in
            guard let self else { return }
            if !self.hintItem.title.hasPrefix("✨") {
                self.hintItem.title = MonsterQuotes.random()
            }
        }
        quoteTimer = t
        RunLoop.main.add(t, forMode: .common)
    }

    private func buildMenu() {
        [stageItem, hintItem, totalItem, todayItem, tpmItem, projectsHeader].forEach {
            $0.isEnabled = false
        }
        menu.addItem(stageItem)
        menu.addItem(hintItem)
        menu.addItem(.separator())
        menu.addItem(totalItem)
        menu.addItem(todayItem)
        menu.addItem(tpmItem)
        menu.addItem(.separator())
        menu.addItem(projectsHeader)
        menu.addItem(.separator())
        let loginItem = NSMenuItem(title: "로그인 시 자동 실행", action: #selector(toggleLogin), keyEquivalent: "")
        loginItem.target = self
        loginItem.state = LaunchAtLogin.isEnabled ? .on : .off
        menu.addItem(loginItem)
        menu.addItem(.separator())
        let dashItem = NSMenuItem(title: "대시보드 열기…", action: #selector(openDashboard), keyEquivalent: "d")
        dashItem.target = self
        menu.addItem(dashItem)
        menu.addItem(.separator())
        let debugHeader = NSMenuItem(title: "디버그", action: nil, keyEquivalent: "")
        debugHeader.isEnabled = false
        menu.addItem(debugHeader)
        let forceItem = NSMenuItem(title: "   강제 진화 (다음 단계)", action: #selector(forceEvolve), keyEquivalent: "")
        forceItem.target = self
        menu.addItem(forceItem)
        let resetItem = NSMenuItem(title: "   새 알 받기 (처음부터)", action: #selector(reset), keyEquivalent: "")
        resetItem.target = self
        menu.addItem(resetItem)
        menu.addItem(.separator())
        let quitItem = NSMenuItem(title: "종료", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
    }

    @objc private func forceEvolve() {
        onForceEvolve?()
    }

    @objc private func toggleLogin(_ sender: NSMenuItem) {
        let newState: NSControl.StateValue = (sender.state == .on) ? .off : .on
        LaunchAtLogin.setEnabled(newState == .on)
        sender.state = newState
    }

    @objc private func openDashboard() {
        onOpenDashboard?()
    }

    @objc private func quit() { NSApp.terminate(nil) }

    /// Temporarily overrides the hint text for 5 seconds (used on evolution),
    /// then returns to a random monster quote.
    func flashHint(_ text: String) {
        DispatchQueue.main.async {
            self.hintItem.title = text
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if self.hintItem.title == text {
                    self.hintItem.title = MonsterQuotes.random()
                }
            }
        }
    }

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

    func apply(snapshot: UsageSnapshot) {
        DispatchQueue.main.async {
            self.stageItem.title = "🥚 Flamimon (\(snapshot.stage.displayName))"
            self.totalItem.title = "누적  \(Self.fmt(snapshot.totalTokens)) 토큰"
            self.todayItem.title = "오늘  \(Self.fmt(snapshot.todayTokens)) 토큰"
            self.tpmItem.title   = "속도  \(Self.fmt(Int64(snapshot.tokensPerMinute))) tok/min"

            self.rebuildProjectRows(snapshot.projects)
            self.animator.setStage(snapshot.stage)
            self.animator.setTokensPerMinute(snapshot.tokensPerMinute)
        }
    }

    private func rebuildProjectRows(_ projects: [(name: String, tokens: Int64)]) {
        guard let headerIdx = menu.items.firstIndex(of: projectsHeader) else { return }
        while menu.items.count > headerIdx + 1, !menu.items[headerIdx + 1].isSeparatorItem {
            menu.removeItem(at: headerIdx + 1)
        }
        if projects.isEmpty {
            let placeholder = NSMenuItem(title: "  (아직 데이터 없음)", action: nil, keyEquivalent: "")
            placeholder.isEnabled = false
            menu.insertItem(placeholder, at: headerIdx + 1)
            return
        }
        for (i, p) in projects.prefix(5).enumerated() {
            let item = NSMenuItem(title: "  \(p.name)  —  \(Self.fmt(p.tokens))", action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.insertItem(item, at: headerIdx + 1 + i)
        }
    }

    private static func hint(for stage: Stage) -> String {
        switch stage {
        case .egg:      return "뭔가 꿈틀거린다…"
        case .baby:     return "아직 어리지만 건강해 보여."
        case .child:    return "호기심이 많아졌어."
        case .teen:     return "점점 강해지고 있다."
        case .adult:    return "이제 웬만한 건 문제없어."
        case .ultimate: return "전설의 존재가 되었다."
        }
    }

    private static func fmt(_ n: Int64) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f.string(from: NSNumber(value: n)) ?? "\(n)"
    }
}
