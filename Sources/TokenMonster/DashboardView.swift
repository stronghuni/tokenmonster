import Cocoa

/// RunCat-inspired dashboard: muted dark gray, two cards (left info + right
/// action bar), subtle separators, clean system typography.
final class DashboardView: NSView {
    var onMenuRequested: (() -> Void)?
    var onForceEvolve: (() -> Void)?
    var onReset: (() -> Void)?
    var onToggleLogin: (() -> Void)?
    var onQuit: (() -> Void)?

    // header
    private let spriteView = NSImageView()
    private let titleLabel = NSTextField(labelWithString: "Flamimon")
    private let subtitleLabel = NSTextField(labelWithString: "알")

    // stats
    private let todayRow = InfoRow(caption: "오늘")
    private let weekRow  = InfoRow(caption: "이번 주")
    private let totalRow = InfoRow(caption: "누적")
    private let costRow  = InfoRow(caption: "비용")

    // quote
    private let quoteLabel = NSTextField(labelWithString: "")

    // projects
    private let projectsHeader = NSTextField(labelWithString: "프로젝트별 · 지난 7일")
    private let projectsStack = NSStackView()

    private var currentStage: Stage = .egg

    init() {
        super.init(frame: NSRect(x: 0, y: 0, width: 560, height: 540))
        wantsLayer = true
        layer?.backgroundColor = Palette.root.cgColor
        build()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func build() {
        // ===== LEFT CARD (info + projects) =====
        let leftCard = cardView()
        addSubview(leftCard)

        // header: sprite + name stack
        let spriteBox = NSView()
        spriteBox.wantsLayer = true
        spriteBox.layer?.cornerRadius = 8
        spriteBox.layer?.backgroundColor = Palette.spriteBg.cgColor
        spriteBox.translatesAutoresizingMaskIntoConstraints = false
        leftCard.addSubview(spriteBox)

        spriteView.imageScaling = .scaleProportionallyUpOrDown
        spriteView.translatesAutoresizingMaskIntoConstraints = false
        spriteBox.addSubview(spriteView)

        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = Palette.textPrimary
        titleLabel.drawsBackground = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        leftCard.addSubview(titleLabel)

        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = Palette.textSecondary
        subtitleLabel.drawsBackground = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        leftCard.addSubview(subtitleLabel)

        // stat rows (vertical stack)
        let statStack = NSStackView(views: [todayRow, weekRow, totalRow, costRow])
        statStack.orientation = .vertical
        statStack.alignment = .leading
        statStack.spacing = 6
        statStack.translatesAutoresizingMaskIntoConstraints = false
        leftCard.addSubview(statStack)

        // separator
        let sep1 = separator()
        leftCard.addSubview(sep1)

        // quote
        quoteLabel.font = .systemFont(ofSize: 12, weight: .regular)
        quoteLabel.textColor = Palette.textSecondary
        quoteLabel.maximumNumberOfLines = 2
        quoteLabel.lineBreakMode = .byTruncatingTail
        quoteLabel.drawsBackground = false
        quoteLabel.translatesAutoresizingMaskIntoConstraints = false
        quoteLabel.cell?.wraps = true
        leftCard.addSubview(quoteLabel)

        // separator
        let sep2 = separator()
        leftCard.addSubview(sep2)

        // projects header
        projectsHeader.font = .systemFont(ofSize: 11, weight: .medium)
        projectsHeader.textColor = Palette.textTertiary
        projectsHeader.drawsBackground = false
        projectsHeader.translatesAutoresizingMaskIntoConstraints = false
        leftCard.addSubview(projectsHeader)

        projectsStack.orientation = .vertical
        projectsStack.alignment = .leading
        projectsStack.spacing = 4
        projectsStack.translatesAutoresizingMaskIntoConstraints = false
        leftCard.addSubview(projectsStack)

        // ===== RIGHT CARD (vertical action buttons) =====
        let rightStack = NSStackView()
        rightStack.orientation = .vertical
        rightStack.alignment = .centerX
        rightStack.spacing = 8
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rightStack)

        let btnMonster = ActionButton(symbol: "pawprint.fill", label: "몬스터")
        let btnEvolve  = ActionButton(symbol: "sparkles",      label: "강제 진화")
        let btnNewEgg  = ActionButton(symbol: "arrow.clockwise", label: "새 알")
        let btnLogin   = ActionButton(symbol: "power",         label: "자동 실행")
        let btnQuit    = ActionButton(symbol: "xmark",         label: "종료")

        btnEvolve.onClick  = { [weak self] in self?.onForceEvolve?() }
        btnNewEgg.onClick  = { [weak self] in self?.onReset?() }
        btnLogin.onClick   = { [weak self] in self?.onToggleLogin?() }
        btnQuit.onClick    = { [weak self] in self?.onQuit?() }
        btnMonster.onClick = { [weak self] in self?.onMenuRequested?() }

        [btnMonster, btnEvolve, btnNewEgg, btnLogin, btnQuit].forEach {
            rightStack.addArrangedSubview($0)
            $0.widthAnchor.constraint(equalToConstant: 80).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 70).isActive = true
        }

        // ===== layout =====
        let pad: CGFloat = 14
        NSLayoutConstraint.activate([
            // left card fills all but right column
            leftCard.leadingAnchor.constraint(equalTo: leadingAnchor, constant: pad),
            leftCard.topAnchor.constraint(equalTo: topAnchor, constant: pad),
            leftCard.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -pad),
            leftCard.trailingAnchor.constraint(equalTo: rightStack.leadingAnchor, constant: -10),

            // right stack
            rightStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -pad),
            rightStack.topAnchor.constraint(equalTo: topAnchor, constant: pad),

            // sprite box
            spriteBox.leadingAnchor.constraint(equalTo: leftCard.leadingAnchor, constant: 14),
            spriteBox.topAnchor.constraint(equalTo: leftCard.topAnchor, constant: 14),
            spriteBox.widthAnchor.constraint(equalToConstant: 64),
            spriteBox.heightAnchor.constraint(equalToConstant: 64),

            spriteView.topAnchor.constraint(equalTo: spriteBox.topAnchor, constant: 4),
            spriteView.leadingAnchor.constraint(equalTo: spriteBox.leadingAnchor, constant: 4),
            spriteView.trailingAnchor.constraint(equalTo: spriteBox.trailingAnchor, constant: -4),
            spriteView.bottomAnchor.constraint(equalTo: spriteBox.bottomAnchor, constant: -4),

            // title + subtitle
            titleLabel.leadingAnchor.constraint(equalTo: spriteBox.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: spriteBox.topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: leftCard.trailingAnchor, constant: -14),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),

            // stat stack below sprite
            statStack.leadingAnchor.constraint(equalTo: leftCard.leadingAnchor, constant: 14),
            statStack.trailingAnchor.constraint(equalTo: leftCard.trailingAnchor, constant: -14),
            statStack.topAnchor.constraint(equalTo: spriteBox.bottomAnchor, constant: 14),

            // separator 1
            sep1.leadingAnchor.constraint(equalTo: leftCard.leadingAnchor, constant: 14),
            sep1.trailingAnchor.constraint(equalTo: leftCard.trailingAnchor, constant: -14),
            sep1.topAnchor.constraint(equalTo: statStack.bottomAnchor, constant: 12),
            sep1.heightAnchor.constraint(equalToConstant: 1),

            // quote
            quoteLabel.leadingAnchor.constraint(equalTo: leftCard.leadingAnchor, constant: 14),
            quoteLabel.trailingAnchor.constraint(equalTo: leftCard.trailingAnchor, constant: -14),
            quoteLabel.topAnchor.constraint(equalTo: sep1.bottomAnchor, constant: 10),

            // separator 2
            sep2.leadingAnchor.constraint(equalTo: leftCard.leadingAnchor, constant: 14),
            sep2.trailingAnchor.constraint(equalTo: leftCard.trailingAnchor, constant: -14),
            sep2.topAnchor.constraint(equalTo: quoteLabel.bottomAnchor, constant: 10),
            sep2.heightAnchor.constraint(equalToConstant: 1),

            // projects header
            projectsHeader.leadingAnchor.constraint(equalTo: leftCard.leadingAnchor, constant: 14),
            projectsHeader.topAnchor.constraint(equalTo: sep2.bottomAnchor, constant: 10),

            projectsStack.leadingAnchor.constraint(equalTo: leftCard.leadingAnchor, constant: 14),
            projectsStack.trailingAnchor.constraint(equalTo: leftCard.trailingAnchor, constant: -14),
            projectsStack.topAnchor.constraint(equalTo: projectsHeader.bottomAnchor, constant: 6),
            projectsStack.bottomAnchor.constraint(lessThanOrEqualTo: leftCard.bottomAnchor, constant: -14),
        ])
    }

    private func cardView() -> NSView {
        let v = NSView()
        v.wantsLayer = true
        v.layer?.cornerRadius = 10
        v.layer?.backgroundColor = Palette.card.cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    private func separator() -> NSView {
        let v = NSView()
        v.wantsLayer = true
        v.layer?.backgroundColor = Palette.separator.cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    func apply(snapshot: UsageSnapshot, quote: String) {
        titleLabel.stringValue = "Flamimon"
        subtitleLabel.stringValue = "Lv. \(snapshot.stage.rawValue + 1)  ·  \(snapshot.stage.displayName)"
        quoteLabel.stringValue = "\u{201C}\(quote)\u{201D}"

        let weeklyTotal = snapshot.weeklyProjects.reduce(Int64(0)) { $0 + $1.weeklyTokens }
        todayRow.setValue(Self.short(snapshot.todayTokens) + " 토큰")
        weekRow.setValue(Self.short(weeklyTotal) + " 토큰")
        totalRow.setValue(Self.short(snapshot.totalTokens) + " 토큰")
        costRow.setValue(String(format: "$%.2f", snapshot.totalCostUSD))

        // sprite
        if snapshot.stage != currentStage || spriteView.image == nil {
            currentStage = snapshot.stage
            let s = LargeSprites.sprite(for: snapshot.stage)
            spriteView.image = PixelRenderer.renderColor(
                sprite: s, frameIndex: 0, pointSize: 60, bitmapScale: 2
            )
        }

        // project rows
        projectsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if snapshot.weeklyProjects.isEmpty {
            let l = NSTextField(labelWithString: "데이터를 모으는 중…")
            l.font = .systemFont(ofSize: 12)
            l.textColor = Palette.textTertiary
            l.drawsBackground = false
            projectsStack.addArrangedSubview(l)
            return
        }
        for wp in snapshot.weeklyProjects.prefix(6) {
            projectsStack.addArrangedSubview(ProjectRow(project: wp))
        }
    }

    private static func short(_ n: Int64) -> String {
        let d = Double(n)
        if d >= 1_000_000_000 { return String(format: "%.1fB", d / 1e9) }
        if d >= 1_000_000     { return String(format: "%.1fM", d / 1e6) }
        if d >= 1_000         { return String(format: "%.0fk", d / 1e3) }
        return "\(n)"
    }
}

// MARK: - Palette
enum Palette {
    static let root           = NSColor(srgbRed: 0.16, green: 0.16, blue: 0.17, alpha: 1)
    static let card           = NSColor(srgbRed: 0.22, green: 0.22, blue: 0.23, alpha: 1)
    static let cardHover      = NSColor(srgbRed: 0.27, green: 0.27, blue: 0.28, alpha: 1)
    static let spriteBg       = NSColor(srgbRed: 0.12, green: 0.12, blue: 0.13, alpha: 1)
    static let separator      = NSColor(white: 1, alpha: 0.08)
    static let textPrimary    = NSColor(white: 1, alpha: 0.96)
    static let textSecondary  = NSColor(white: 1, alpha: 0.62)
    static let textTertiary   = NSColor(white: 1, alpha: 0.42)
    static let accentBlue     = NSColor(srgbRed: 0.30, green: 0.58, blue: 0.96, alpha: 1)
    static let accentRed      = NSColor(srgbRed: 0.90, green: 0.35, blue: 0.35, alpha: 1)
    static let accentYellow   = NSColor(srgbRed: 0.98, green: 0.78, blue: 0.24, alpha: 1)
}

// MARK: - InfoRow (caption ——— value)
final class InfoRow: NSView {
    private let captionLabel: NSTextField
    private let valueLabel: NSTextField

    init(caption: String) {
        self.captionLabel = NSTextField(labelWithString: caption)
        self.valueLabel = NSTextField(labelWithString: "0")
        super.init(frame: .zero)
        captionLabel.font = .systemFont(ofSize: 12, weight: .regular)
        captionLabel.textColor = Palette.textSecondary
        captionLabel.drawsBackground = false
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(captionLabel)

        valueLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        valueLabel.textColor = Palette.textPrimary
        valueLabel.drawsBackground = false
        valueLabel.alignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(valueLabel)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 18),
            captionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            captionLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            widthAnchor.constraint(greaterThanOrEqualToConstant: 240),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func setValue(_ s: String) { valueLabel.stringValue = s }
}

// MARK: - ProjectRow (ball icon · name · tokens)
final class ProjectRow: NSView {
    init(project: WeeklyProject) {
        super.init(frame: .zero)
        let ball = NSImageView()
        ball.image = BallSprites.image(for: project.tier, pointSize: 18)
        ball.imageScaling = .scaleProportionallyUpOrDown
        ball.translatesAutoresizingMaskIntoConstraints = false

        let name = NSTextField(labelWithString: project.name)
        name.font = .systemFont(ofSize: 12, weight: .medium)
        name.textColor = Palette.textPrimary
        name.drawsBackground = false
        name.translatesAutoresizingMaskIntoConstraints = false
        name.lineBreakMode = .byTruncatingTail

        let tokens = NSTextField(labelWithString: Self.short(project.weeklyTokens))
        tokens.font = .monospacedDigitSystemFont(ofSize: 11, weight: .medium)
        tokens.textColor = Palette.textSecondary
        tokens.drawsBackground = false
        tokens.alignment = .right
        tokens.translatesAutoresizingMaskIntoConstraints = false

        addSubview(ball); addSubview(name); addSubview(tokens)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 22),

            ball.leadingAnchor.constraint(equalTo: leadingAnchor),
            ball.centerYAnchor.constraint(equalTo: centerYAnchor),
            ball.widthAnchor.constraint(equalToConstant: 20),
            ball.heightAnchor.constraint(equalToConstant: 20),

            name.leadingAnchor.constraint(equalTo: ball.trailingAnchor, constant: 8),
            name.centerYAnchor.constraint(equalTo: centerYAnchor),

            tokens.trailingAnchor.constraint(equalTo: trailingAnchor),
            tokens.centerYAnchor.constraint(equalTo: centerYAnchor),
            tokens.leadingAnchor.constraint(greaterThanOrEqualTo: name.trailingAnchor, constant: 8),
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
}

// MARK: - ActionButton (SF Symbol + label, vertical card)
final class ActionButton: NSView {
    var onClick: (() -> Void)?
    private let icon = NSImageView()
    private let label = NSTextField(labelWithString: "")
    private var tracking: NSTrackingArea?
    private var hovered = false { didSet { updateAppearance() } }

    init(symbol: String, label text: String) {
        super.init(frame: .zero)
        wantsLayer = true
        layer?.cornerRadius = 8
        layer?.backgroundColor = Palette.card.cgColor

        if let img = NSImage(systemSymbolName: symbol, accessibilityDescription: text) {
            let config = NSImage.SymbolConfiguration(pointSize: 22, weight: .regular)
            icon.image = img.withSymbolConfiguration(config)
        }
        icon.contentTintColor = Palette.textPrimary
        icon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(icon)

        label.stringValue = text
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = Palette.textSecondary
        label.alignment = .center
        label.drawsBackground = false
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: centerXAnchor),
            icon.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            icon.widthAnchor.constraint(equalToConstant: 26),
            icon.heightAnchor.constraint(equalToConstant: 26),

            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 6),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -4),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let tracking { removeTrackingArea(tracking) }
        let t = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(t)
        tracking = t
    }

    override func mouseEntered(with event: NSEvent) { hovered = true }
    override func mouseExited(with event: NSEvent)  { hovered = false }
    override func mouseDown(with event: NSEvent) { onClick?() }

    private func updateAppearance() {
        layer?.backgroundColor = (hovered ? Palette.cardHover : Palette.card).cgColor
    }
}
