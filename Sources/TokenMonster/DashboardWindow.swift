import Cocoa

final class DashboardWindowController: NSWindowController {
    private let stageLabel = NSTextField(labelWithString: "")
    private let totalLabel = NSTextField(labelWithString: "")
    private let todayLabel = NSTextField(labelWithString: "")
    private let speedLabel = NSTextField(labelWithString: "")
    private let costLabel  = NSTextField(labelWithString: "")
    private let projectsList = NSTextField(wrappingLabelWithString: "")

    init() {
        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 520),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered, defer: false
        )
        win.title = "Token Monster"
        win.isReleasedWhenClosed = false
        win.center()
        super.init(window: win)

        let container = NSStackView()
        container.orientation = .vertical
        container.alignment = .leading
        container.spacing = 10
        container.edgeInsets = NSEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        container.translatesAutoresizingMaskIntoConstraints = false

        let title = NSTextField(labelWithString: "🥚 Token Monster")
        title.font = .systemFont(ofSize: 22, weight: .bold)
        container.addArrangedSubview(title)

        stageLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        [stageLabel, totalLabel, todayLabel, speedLabel, costLabel].forEach {
            $0.textColor = .labelColor
            container.addArrangedSubview($0)
        }

        let sep1 = NSBox(); sep1.boxType = .separator
        sep1.translatesAutoresizingMaskIntoConstraints = false
        container.addArrangedSubview(sep1)

        let projHeader = NSTextField(labelWithString: "프로젝트별 누적")
        projHeader.font = .systemFont(ofSize: 14, weight: .semibold)
        container.addArrangedSubview(projHeader)

        projectsList.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        projectsList.textColor = .secondaryLabelColor
        container.addArrangedSubview(projectsList)

        win.contentView = container
        NSLayoutConstraint.activate([
            sep1.widthAnchor.constraint(equalTo: container.widthAnchor, constant: -48),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func apply(snapshot: UsageSnapshot) {
        stageLabel.stringValue = "Flamimon (\(snapshot.stage.displayName))"
        totalLabel.stringValue = "누적 (몬스터)  \(Self.fmt(snapshot.totalTokens)) 토큰"
        todayLabel.stringValue = "오늘           \(Self.fmt(snapshot.todayTokens)) 토큰"
        speedLabel.stringValue = "속도           \(Self.fmt(Int64(snapshot.tokensPerMinute))) tok/min"
        costLabel.stringValue  = String(format: "예상 누적 비용  $%.2f", snapshot.totalCostUSD)

        let lines = snapshot.projects.prefix(20).map { p in
            String(format: "%-30@  %@", p.name as NSString, Self.fmt(p.tokens) as NSString)
        }.joined(separator: "\n")
        projectsList.stringValue = lines.isEmpty ? "(데이터 없음)" : lines
    }

    func show() {
        NSApp.activate(ignoringOtherApps: true)
        showWindow(nil)
        window?.makeKeyAndOrderFront(nil)
    }

    private static func fmt(_ n: Int64) -> String {
        let f = NumberFormatter(); f.numberStyle = .decimal
        return f.string(from: NSNumber(value: n)) ?? "\(n)"
    }
}
