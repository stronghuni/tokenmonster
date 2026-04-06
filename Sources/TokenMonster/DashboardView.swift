import Cocoa

/// Apple Music mini-player style dashboard — weekly per-project ranking with
/// ball tiers (monster/super/hyper).
final class DashboardView: NSView {
    var onMenuRequested: (() -> Void)?

    private let spriteView = NSImageView()
    private let titleLabel = NSTextField(labelWithString: "Flamimon")
    private let subtitleLabel = NSTextField(labelWithString: "알")
    private let quoteLabel = NSTextField(labelWithString: "")
    private let menuButton = NSButton(title: "•••", target: nil, action: nil)

    private let todayStat = StatBadge(caption: "오늘")
    private let totalStat = StatBadge(caption: "누적")
    private let weekStat  = StatBadge(caption: "이번 주")

    private let sectionHeader = NSTextField(labelWithString: "프로젝트별 (지난 7일)")
    private let projectsStack = NSStackView()

    private var currentStage: Stage = .egg

    init() {
        super.init(frame: NSRect(x: 0, y: 0, width: 480, height: 560))
        wantsLayer = true
        build()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func build() {
        // sprite box
        let spriteBox = NSView()
        spriteBox.wantsLayer = true
        spriteBox.layer?.cornerRadius = 14
        spriteBox.layer?.backgroundColor = NSColor(white: 0, alpha: 0.35).cgColor
        spriteBox.translatesAutoresizingMaskIntoConstraints = false
        addSubview(spriteBox)

        spriteView.imageScaling = .scaleProportionallyUpOrDown
        spriteView.translatesAutoresizingMaskIntoConstraints = false
        spriteBox.addSubview(spriteView)

        // title
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = NSColor(white: 1, alpha: 0.55)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subtitleLabel)

        menuButton.isBordered = false
        menuButton.font = .systemFont(ofSize: 14, weight: .bold)
        menuButton.contentTintColor = NSColor(white: 1, alpha: 0.55)
        menuButton.target = self
        menuButton.action = #selector(menuTapped)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(menuButton)

        // stat row
        let statStack = NSStackView(views: [todayStat, weekStat, totalStat])
        statStack.orientation = .horizontal
        statStack.distribution = .fillEqually
        statStack.spacing = 16
        statStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(statStack)

        // quote
        quoteLabel.font = .systemFont(ofSize: 11, weight: .regular)
        quoteLabel.textColor = NSColor(white: 1, alpha: 0.5)
        quoteLabel.lineBreakMode = .byTruncatingTail
        quoteLabel.maximumNumberOfLines = 2
        quoteLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(quoteLabel)

        // section header
        sectionHeader.font = .systemFont(ofSize: 11, weight: .semibold)
        sectionHeader.textColor = NSColor(white: 1, alpha: 0.5)
        sectionHeader.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sectionHeader)

        // projects stack
        projectsStack.orientation = .vertical
        projectsStack.alignment = .leading
        projectsStack.spacing = 6
        projectsStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(projectsStack)

        NSLayoutConstraint.activate([
            spriteBox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            spriteBox.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            spriteBox.widthAnchor.constraint(equalToConstant: 130),
            spriteBox.heightAnchor.constraint(equalToConstant: 130),

            spriteView.leadingAnchor.constraint(equalTo: spriteBox.leadingAnchor, constant: 8),
            spriteView.trailingAnchor.constraint(equalTo: spriteBox.trailingAnchor, constant: -8),
            spriteView.topAnchor.constraint(equalTo: spriteBox.topAnchor, constant: 8),
            spriteView.bottomAnchor.constraint(equalTo: spriteBox.bottomAnchor, constant: -8),

            menuButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            menuButton.topAnchor.constraint(equalTo: topAnchor, constant: 18),

            titleLabel.leadingAnchor.constraint(equalTo: spriteBox.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 22),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: menuButton.leadingAnchor, constant: -8),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),

            statStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            statStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            statStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 14),

            quoteLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            quoteLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            quoteLabel.topAnchor.constraint(equalTo: spriteBox.bottomAnchor, constant: 12),

            sectionHeader.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            sectionHeader.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            sectionHeader.topAnchor.constraint(equalTo: quoteLabel.bottomAnchor, constant: 14),

            projectsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            projectsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            projectsStack.topAnchor.constraint(equalTo: sectionHeader.bottomAnchor, constant: 8),
            projectsStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -18),
        ])
    }

    @objc private func menuTapped() { onMenuRequested?() }

    func apply(snapshot: UsageSnapshot, quote: String) {
        titleLabel.stringValue = "Flamimon"
        subtitleLabel.stringValue = snapshot.stage.displayName + Self.species(snapshot.stage)
        quoteLabel.stringValue = "\u{201C}" + quote + "\u{201D}"

        let weeklyTotal = snapshot.weeklyProjects.reduce(Int64(0)) { $0 + $1.weeklyTokens }
        todayStat.setValue(Self.short(snapshot.todayTokens))
        weekStat.setValue(Self.short(weeklyTotal))
        totalStat.setValue(Self.short(snapshot.totalTokens))

        // sprite
        if snapshot.stage != currentStage || spriteView.image == nil {
            currentStage = snapshot.stage
            let sprite = ColorSprites.sprite(for: snapshot.stage)
            spriteView.image = PixelRenderer.renderColor(
                sprite: sprite, frameIndex: 0, pointSize: 120, bitmapScale: 4
            )
        }

        // projects list with ball icons
        projectsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if snapshot.weeklyProjects.isEmpty {
            let l = NSTextField(labelWithString: "(지난 7일 데이터 없음)")
            l.font = .systemFont(ofSize: 12)
            l.textColor = NSColor(white: 1, alpha: 0.45)
            projectsStack.addArrangedSubview(l)
            return
        }
        for wp in snapshot.weeklyProjects.prefix(10) {
            projectsStack.addArrangedSubview(Self.makeRow(wp))
        }
    }

    private static func makeRow(_ p: WeeklyProject) -> NSView {
        let row = NSStackView()
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 10
        row.translatesAutoresizingMaskIntoConstraints = false

        let ball = NSImageView()
        ball.image = BallSprites.image(for: p.tier, pointSize: 20)
        ball.imageScaling = .scaleProportionallyUpOrDown
        ball.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ball.widthAnchor.constraint(equalToConstant: 22),
            ball.heightAnchor.constraint(equalToConstant: 22),
        ])
        row.addArrangedSubview(ball)

        let name = NSTextField(labelWithString: p.name)
        name.font = .systemFont(ofSize: 13, weight: .medium)
        name.textColor = .white
        row.addArrangedSubview(name)

        let spacer = NSView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        row.addArrangedSubview(spacer)

        let tokens = NSTextField(labelWithString: short(p.weeklyTokens))
        tokens.font = .monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        tokens.textColor = NSColor(white: 1, alpha: 0.7)
        row.addArrangedSubview(tokens)

        let tierLabel = NSTextField(labelWithString: tierName(p.tier))
        tierLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        tierLabel.textColor = tierColor(p.tier)
        row.addArrangedSubview(tierLabel)

        return row
    }

    private static func tierName(_ t: BallTier) -> String {
        switch t {
        case .monster:   return "몬스터볼"
        case .superBall: return "슈퍼볼"
        case .hyper:     return "하이퍼볼"
        }
    }
    private static func tierColor(_ t: BallTier) -> NSColor {
        switch t {
        case .monster:   return NSColor(srgbRed: 0.90, green: 0.30, blue: 0.30, alpha: 1)
        case .superBall: return NSColor(srgbRed: 0.30, green: 0.60, blue: 1.00, alpha: 1)
        case .hyper:     return NSColor(srgbRed: 1.00, green: 0.80, blue: 0.20, alpha: 1)
        }
    }
    private static func short(_ n: Int64) -> String {
        let d = Double(n)
        if d >= 1_000_000_000 { return String(format: "%.1fB", d / 1e9) }
        if d >= 1_000_000     { return String(format: "%.1fM", d / 1e6) }
        if d >= 1_000         { return String(format: "%.0fk", d / 1e3) }
        return "\(n)"
    }
    private static func species(_ s: Stage) -> String {
        switch s {
        case .egg:      return ""
        case .baby:     return "  ·  Flamkin"
        case .child:    return "  ·  Flamon"
        case .teen:     return "  ·  Blazon"
        case .adult:    return "  ·  Infernon"
        case .ultimate: return "  ·  Phoenignis"
        }
    }
}
