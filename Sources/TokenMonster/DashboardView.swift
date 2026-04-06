import Cocoa

/// Retro game-style dashboard (Pokémon/RPG menu vibe) shown inside an NSPopover.
final class DashboardView: NSView {
    var onMenuRequested: (() -> Void)?

    private let root = PixelPanel()
    private let spritePanel = PixelPanel()
    private let spriteView = NSImageView()

    private let namePanel = PixelPanel()
    private let titleLabel = NSTextField(labelWithString: "FLAMIMON")
    private let subtitleLabel = NSTextField(labelWithString: "LV. 1 · EGG")

    private let todayStat = PixelStatBox(caption: "TODAY")
    private let weekStat  = PixelStatBox(caption: "THIS WEEK")
    private let totalStat = PixelStatBox(caption: "ALL TIME")

    private let quotePanel = PixelPanel()
    private let quoteLabel = NSTextField(labelWithString: "")

    private let listPanel = PixelPanel()
    private let listHeader = NSTextField(labelWithString: "▸ PROJECTS · LAST 7 DAYS")
    private let listStack = NSStackView()

    private let menuButton = NSButton(title: "≡", target: nil, action: nil)

    private var currentStage: Stage = .egg

    init() {
        super.init(frame: NSRect(x: 0, y: 0, width: 520, height: 600))
        wantsLayer = true
        layer?.backgroundColor = RetroPalette.rootBg.cgColor
        build()
    }
    required init?(coder: NSCoder) { fatalError() }

    override var isFlipped: Bool { false }

    private func build() {
        // root panel fills everything with the pixel frame
        root.background = RetroPalette.rootBg
        root.outerBorder = RetroPalette.borderDark
        root.innerBorder = RetroPalette.borderLight
        root.translatesAutoresizingMaskIntoConstraints = false
        addSubview(root)

        // sprite panel (square, inner frame, darker bg)
        spritePanel.background = RetroPalette.panelBg
        spritePanel.outerBorder = RetroPalette.borderDark
        spritePanel.innerBorder = RetroPalette.accentGold
        spritePanel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(spritePanel)

        spriteView.imageScaling = .scaleProportionallyUpOrDown
        spriteView.translatesAutoresizingMaskIntoConstraints = false
        spritePanel.addSubview(spriteView)

        // name panel (right of sprite)
        namePanel.background = RetroPalette.panelBg
        namePanel.outerBorder = RetroPalette.borderDark
        namePanel.innerBorder = RetroPalette.borderLight
        namePanel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(namePanel)

        titleLabel.font = RetroPalette.pixelFont(size: 18, weight: .black)
        titleLabel.textColor = RetroPalette.accentGold
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.drawsBackground = false
        namePanel.addSubview(titleLabel)

        subtitleLabel.font = RetroPalette.pixelFont(size: 11, weight: .semibold)
        subtitleLabel.textColor = RetroPalette.textMuted
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.drawsBackground = false
        namePanel.addSubview(subtitleLabel)

        // menu button inside name panel (right corner)
        menuButton.isBordered = false
        menuButton.font = RetroPalette.pixelFont(size: 18, weight: .heavy)
        menuButton.contentTintColor = RetroPalette.accentGold
        menuButton.target = self
        menuButton.action = #selector(menuTapped)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        namePanel.addSubview(menuButton)

        // stats row
        [todayStat, weekStat, totalStat].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        // quote panel
        quotePanel.background = RetroPalette.panelBgAlt
        quotePanel.outerBorder = RetroPalette.borderDark
        quotePanel.innerBorder = RetroPalette.accentCyan
        quotePanel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(quotePanel)

        quoteLabel.font = RetroPalette.pixelFont(size: 11, weight: .medium)
        quoteLabel.textColor = RetroPalette.textPrimary
        quoteLabel.maximumNumberOfLines = 3
        quoteLabel.lineBreakMode = .byWordWrapping
        quoteLabel.cell?.wraps = true
        quoteLabel.cell?.isScrollable = false
        quoteLabel.translatesAutoresizingMaskIntoConstraints = false
        quoteLabel.drawsBackground = false
        quotePanel.addSubview(quoteLabel)

        // list panel
        listPanel.background = RetroPalette.panelBg
        listPanel.outerBorder = RetroPalette.borderDark
        listPanel.innerBorder = RetroPalette.borderLight
        listPanel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(listPanel)

        listHeader.font = RetroPalette.pixelFont(size: 11, weight: .black)
        listHeader.textColor = RetroPalette.accentGold
        listHeader.translatesAutoresizingMaskIntoConstraints = false
        listHeader.drawsBackground = false
        listPanel.addSubview(listHeader)

        listStack.orientation = .vertical
        listStack.alignment = .leading
        listStack.spacing = 4
        listStack.translatesAutoresizingMaskIntoConstraints = false
        listPanel.addSubview(listStack)

        // layout
        let pad: CGFloat = 14
        NSLayoutConstraint.activate([
            root.leadingAnchor.constraint(equalTo: leadingAnchor),
            root.trailingAnchor.constraint(equalTo: trailingAnchor),
            root.topAnchor.constraint(equalTo: topAnchor),
            root.bottomAnchor.constraint(equalTo: bottomAnchor),

            // sprite panel (top-left)
            spritePanel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: pad),
            spritePanel.topAnchor.constraint(equalTo: topAnchor, constant: pad),
            spritePanel.widthAnchor.constraint(equalToConstant: 140),
            spritePanel.heightAnchor.constraint(equalToConstant: 140),

            spriteView.leadingAnchor.constraint(equalTo: spritePanel.leadingAnchor, constant: 10),
            spriteView.trailingAnchor.constraint(equalTo: spritePanel.trailingAnchor, constant: -10),
            spriteView.topAnchor.constraint(equalTo: spritePanel.topAnchor, constant: 10),
            spriteView.bottomAnchor.constraint(equalTo: spritePanel.bottomAnchor, constant: -10),

            // name panel (top-right, same height as sprite)
            namePanel.leadingAnchor.constraint(equalTo: spritePanel.trailingAnchor, constant: 10),
            namePanel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -pad),
            namePanel.topAnchor.constraint(equalTo: topAnchor, constant: pad),
            namePanel.heightAnchor.constraint(equalToConstant: 66),

            titleLabel.leadingAnchor.constraint(equalTo: namePanel.leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: namePanel.topAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: menuButton.leadingAnchor, constant: -6),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),

            menuButton.trailingAnchor.constraint(equalTo: namePanel.trailingAnchor, constant: -10),
            menuButton.centerYAnchor.constraint(equalTo: namePanel.centerYAnchor),
            menuButton.widthAnchor.constraint(equalToConstant: 22),

            // stats row: below namePanel, same width
            todayStat.leadingAnchor.constraint(equalTo: namePanel.leadingAnchor),
            todayStat.topAnchor.constraint(equalTo: namePanel.bottomAnchor, constant: 8),
            todayStat.heightAnchor.constraint(equalToConstant: 60),

            weekStat.leadingAnchor.constraint(equalTo: todayStat.trailingAnchor, constant: 8),
            weekStat.topAnchor.constraint(equalTo: todayStat.topAnchor),
            weekStat.bottomAnchor.constraint(equalTo: todayStat.bottomAnchor),
            weekStat.widthAnchor.constraint(equalTo: todayStat.widthAnchor),

            totalStat.leadingAnchor.constraint(equalTo: weekStat.trailingAnchor, constant: 8),
            totalStat.topAnchor.constraint(equalTo: todayStat.topAnchor),
            totalStat.bottomAnchor.constraint(equalTo: todayStat.bottomAnchor),
            totalStat.widthAnchor.constraint(equalTo: todayStat.widthAnchor),
            totalStat.trailingAnchor.constraint(equalTo: namePanel.trailingAnchor),

            // quote panel (full width, below sprite + stats)
            quotePanel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: pad),
            quotePanel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -pad),
            quotePanel.topAnchor.constraint(equalTo: spritePanel.bottomAnchor, constant: 10),
            quotePanel.heightAnchor.constraint(equalToConstant: 54),

            quoteLabel.leadingAnchor.constraint(equalTo: quotePanel.leadingAnchor, constant: 12),
            quoteLabel.trailingAnchor.constraint(equalTo: quotePanel.trailingAnchor, constant: -12),
            quoteLabel.topAnchor.constraint(equalTo: quotePanel.topAnchor, constant: 8),
            quoteLabel.bottomAnchor.constraint(equalTo: quotePanel.bottomAnchor, constant: -8),

            // list panel (fills the rest)
            listPanel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: pad),
            listPanel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -pad),
            listPanel.topAnchor.constraint(equalTo: quotePanel.bottomAnchor, constant: 10),
            listPanel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -pad),

            listHeader.leadingAnchor.constraint(equalTo: listPanel.leadingAnchor, constant: 12),
            listHeader.topAnchor.constraint(equalTo: listPanel.topAnchor, constant: 10),

            listStack.leadingAnchor.constraint(equalTo: listPanel.leadingAnchor, constant: 10),
            listStack.trailingAnchor.constraint(equalTo: listPanel.trailingAnchor, constant: -10),
            listStack.topAnchor.constraint(equalTo: listHeader.bottomAnchor, constant: 8),
            listStack.bottomAnchor.constraint(lessThanOrEqualTo: listPanel.bottomAnchor, constant: -10),
        ])
    }

    @objc private func menuTapped() { onMenuRequested?() }

    func apply(snapshot: UsageSnapshot, quote: String) {
        titleLabel.stringValue = "FLAMIMON"
        subtitleLabel.stringValue = "LV. \(snapshot.stage.rawValue + 1) · " + Self.stageEN(snapshot.stage)
        quoteLabel.stringValue = "\u{201C}\(quote)\u{201D}"

        let weeklyTotal = snapshot.weeklyProjects.reduce(Int64(0)) { $0 + $1.weeklyTokens }
        todayStat.setValue(Self.short(snapshot.todayTokens))
        weekStat.setValue(Self.short(weeklyTotal))
        totalStat.setValue(Self.short(snapshot.totalTokens))

        // sprite — use HIGH-RES (48x48) version for dashboard
        if snapshot.stage != currentStage || spriteView.image == nil {
            currentStage = snapshot.stage
            let s = LargeSprites.sprite(for: snapshot.stage)
            spriteView.image = PixelRenderer.renderColor(
                sprite: s, frameIndex: 0, pointSize: 120, bitmapScale: 2
            )
        }

        // projects
        listStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if snapshot.weeklyProjects.isEmpty {
            let l = NSTextField(labelWithString: "  (NO DATA — keep using Claude Code)")
            l.font = RetroPalette.pixelFont(size: 11, weight: .medium)
            l.textColor = RetroPalette.textMuted
            l.drawsBackground = false
            listStack.addArrangedSubview(l)
            return
        }
        for (idx, wp) in snapshot.weeklyProjects.prefix(8).enumerated() {
            listStack.addArrangedSubview(PixelProjectRow(project: wp, zebra: idx % 2 == 1))
        }
    }

    private static func short(_ n: Int64) -> String {
        let d = Double(n)
        if d >= 1_000_000_000 { return String(format: "%.1fB", d / 1e9) }
        if d >= 1_000_000     { return String(format: "%.1fM", d / 1e6) }
        if d >= 1_000         { return String(format: "%.0fk", d / 1e3) }
        return "\(n)"
    }
    private static func stageEN(_ s: Stage) -> String {
        switch s {
        case .egg:      return "EGG"
        case .baby:     return "FLAMKIN"
        case .child:    return "FLAMON"
        case .teen:     return "BLAZON"
        case .adult:    return "INFERNON"
        case .ultimate: return "PHOENIGNIS"
        }
    }
}

// MARK: - Pixel stat box (single number with caption)
final class PixelStatBox: PixelPanel {
    private let captionLabel: NSTextField
    private let valueLabel: NSTextField

    init(caption: String) {
        self.captionLabel = NSTextField(labelWithString: caption)
        self.valueLabel = NSTextField(labelWithString: "0")
        super.init(frame: .zero)
        background = RetroPalette.panelBgAlt
        outerBorder = RetroPalette.borderDark
        innerBorder = RetroPalette.accentGold
        wantsLayer = true

        captionLabel.font = RetroPalette.pixelFont(size: 9, weight: .heavy)
        captionLabel.textColor = RetroPalette.textMuted
        captionLabel.drawsBackground = false
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(captionLabel)

        valueLabel.font = RetroPalette.pixelFont(size: 18, weight: .black)
        valueLabel.textColor = RetroPalette.textPrimary
        valueLabel.drawsBackground = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.alignment = .center
        addSubview(valueLabel)

        NSLayoutConstraint.activate([
            captionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            captionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 6),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -6),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func setValue(_ s: String) { valueLabel.stringValue = s }
}

// MARK: - Pixel project row (ball icon + name + tokens + tier)
final class PixelProjectRow: NSView {
    init(project: WeeklyProject, zebra: Bool) {
        super.init(frame: .zero)
        wantsLayer = true
        layer?.backgroundColor = (zebra ? RetroPalette.panelBgAlt : RetroPalette.panelBg).cgColor
        layer?.cornerRadius = 2

        let ball = NSImageView()
        ball.image = BallSprites.image(for: project.tier, pointSize: 26)
        ball.imageScaling = .scaleProportionallyUpOrDown
        ball.translatesAutoresizingMaskIntoConstraints = false

        let name = NSTextField(labelWithString: project.name.uppercased())
        name.font = RetroPalette.pixelFont(size: 12, weight: .bold)
        name.textColor = RetroPalette.textPrimary
        name.drawsBackground = false
        name.translatesAutoresizingMaskIntoConstraints = false
        name.lineBreakMode = .byTruncatingTail

        let tokens = NSTextField(labelWithString: Self.short(project.weeklyTokens))
        tokens.font = RetroPalette.pixelFont(size: 12, weight: .heavy)
        tokens.textColor = RetroPalette.accentGold
        tokens.alignment = .right
        tokens.drawsBackground = false
        tokens.translatesAutoresizingMaskIntoConstraints = false

        let tierLabel = NSTextField(labelWithString: Self.tierTag(project.tier))
        tierLabel.font = RetroPalette.pixelFont(size: 9, weight: .black)
        tierLabel.textColor = Self.tierColor(project.tier)
        tierLabel.drawsBackground = false
        tierLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(ball)
        addSubview(name)
        addSubview(tokens)
        addSubview(tierLabel)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 30),

            ball.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            ball.centerYAnchor.constraint(equalTo: centerYAnchor),
            ball.widthAnchor.constraint(equalToConstant: 26),
            ball.heightAnchor.constraint(equalToConstant: 26),

            name.leadingAnchor.constraint(equalTo: ball.trailingAnchor, constant: 10),
            name.centerYAnchor.constraint(equalTo: centerYAnchor),

            tierLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            tierLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            tokens.trailingAnchor.constraint(equalTo: tierLabel.leadingAnchor, constant: -10),
            tokens.centerYAnchor.constraint(equalTo: centerYAnchor),

            name.trailingAnchor.constraint(lessThanOrEqualTo: tokens.leadingAnchor, constant: -10),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    private static func short(_ n: Int64) -> String {
        let d = Double(n)
        if d >= 1_000_000_000 { return String(format: "%.1fB", d / 1e9) }
        if d >= 1_000_000     { return String(format: "%.1fM", d / 1e6) }
        if d >= 1_000         { return String(format: "%.0fk", d / 1e3) }
        return "\(n)"
    }
    private static func tierTag(_ t: BallTier) -> String {
        switch t {
        case .monster:   return "MONSTER"
        case .superBall: return "SUPER"
        case .hyper:     return "HYPER"
        }
    }
    private static func tierColor(_ t: BallTier) -> NSColor {
        switch t {
        case .monster:   return RetroPalette.accentRed
        case .superBall: return RetroPalette.accentBlue
        case .hyper:     return RetroPalette.accentGold
        }
    }
}
