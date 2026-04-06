import Cocoa

/// Apple Music mini-player style dashboard content, used inside an NSPopover
/// shown directly below the menubar icon.
final class DashboardView: NSView {

    // exposed callbacks
    var onMenuRequested: (() -> Void)?

    // widgets
    private let spriteView = NSImageView()
    private let titleLabel = NSTextField(labelWithString: "Flamimon")
    private let subtitleLabel = NSTextField(labelWithString: "알")
    private let quoteLabel = NSTextField(labelWithString: "")
    private let menuButton = NSButton(title: "•••", target: nil, action: nil)

    private let todayStat = StatBadge(caption: "오늘")
    private let totalStat = StatBadge(caption: "누적")
    private let costStat  = StatBadge(caption: "비용")

    private let progressTrack = NSView()
    private let progressFill  = NSView()
    private let leftTime  = NSTextField(labelWithString: "0")
    private let rightTime = NSTextField(labelWithString: "0")

    private let projectsHeader = NSTextField(labelWithString: "프로젝트별 (상위 5)")
    private let projectsStack  = NSStackView()

    private var progressFillWidth: NSLayoutConstraint?
    private var currentStage: Stage = .egg

    init() {
        super.init(frame: NSRect(x: 0, y: 0, width: 560, height: 480))
        wantsLayer = true
        build()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func build() {
        // sprite box (left, square)
        let spriteBox = NSView()
        spriteBox.wantsLayer = true
        spriteBox.layer?.cornerRadius = 14
        spriteBox.layer?.backgroundColor = NSColor(white: 0, alpha: 0.35).cgColor
        spriteBox.translatesAutoresizingMaskIntoConstraints = false
        addSubview(spriteBox)

        spriteView.imageScaling = .scaleProportionallyUpOrDown
        spriteView.translatesAutoresizingMaskIntoConstraints = false
        spriteBox.addSubview(spriteView)

        // title block
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
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
        let statStack = NSStackView(views: [todayStat, totalStat, costStat])
        statStack.orientation = .horizontal
        statStack.distribution = .fillEqually
        statStack.spacing = 20
        statStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(statStack)

        // progress bar
        progressTrack.wantsLayer = true
        progressTrack.layer?.backgroundColor = NSColor(white: 1, alpha: 0.15).cgColor
        progressTrack.layer?.cornerRadius = 3
        progressTrack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressTrack)

        progressFill.wantsLayer = true
        progressFill.layer?.backgroundColor = NSColor.systemBlue.cgColor
        progressFill.layer?.cornerRadius = 3
        progressFill.translatesAutoresizingMaskIntoConstraints = false
        progressTrack.addSubview(progressFill)

        [leftTime, rightTime].forEach {
            $0.font = .monospacedDigitSystemFont(ofSize: 12, weight: .medium)
            $0.textColor = NSColor(white: 1, alpha: 0.55)
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        // quote line
        quoteLabel.font = .systemFont(ofSize: 12, weight: .regular)
        quoteLabel.textColor = NSColor(white: 1, alpha: 0.5)
        quoteLabel.lineBreakMode = .byTruncatingTail
        quoteLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(quoteLabel)

        // projects
        projectsHeader.font = .systemFont(ofSize: 11, weight: .semibold)
        projectsHeader.textColor = NSColor(white: 1, alpha: 0.55)
        projectsHeader.translatesAutoresizingMaskIntoConstraints = false
        addSubview(projectsHeader)

        projectsStack.orientation = .vertical
        projectsStack.alignment = .leading
        projectsStack.spacing = 3
        projectsStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(projectsStack)

        NSLayoutConstraint.activate([
            // sprite box
            spriteBox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            spriteBox.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            spriteBox.widthAnchor.constraint(equalToConstant: 150),
            spriteBox.heightAnchor.constraint(equalToConstant: 150),

            spriteView.leadingAnchor.constraint(equalTo: spriteBox.leadingAnchor, constant: 8),
            spriteView.trailingAnchor.constraint(equalTo: spriteBox.trailingAnchor, constant: -8),
            spriteView.topAnchor.constraint(equalTo: spriteBox.topAnchor, constant: 8),
            spriteView.bottomAnchor.constraint(equalTo: spriteBox.bottomAnchor, constant: -8),

            // menu button
            menuButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            menuButton.topAnchor.constraint(equalTo: topAnchor, constant: 18),

            // title
            titleLabel.leadingAnchor.constraint(equalTo: spriteBox.trailingAnchor, constant: 18),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 22),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: menuButton.leadingAnchor, constant: -10),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),

            // stat row
            statStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            statStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            statStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 18),

            // progress
            progressTrack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            progressTrack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            progressTrack.topAnchor.constraint(equalTo: statStack.bottomAnchor, constant: 18),
            progressTrack.heightAnchor.constraint(equalToConstant: 6),

            progressFill.leadingAnchor.constraint(equalTo: progressTrack.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progressTrack.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressTrack.bottomAnchor),

            leftTime.leadingAnchor.constraint(equalTo: progressTrack.leadingAnchor),
            leftTime.topAnchor.constraint(equalTo: progressTrack.bottomAnchor, constant: 6),
            rightTime.trailingAnchor.constraint(equalTo: progressTrack.trailingAnchor),
            rightTime.topAnchor.constraint(equalTo: progressTrack.bottomAnchor, constant: 6),

            // quote
            quoteLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            quoteLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            quoteLabel.topAnchor.constraint(equalTo: spriteBox.bottomAnchor, constant: 14),

            // projects
            projectsHeader.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            projectsHeader.topAnchor.constraint(equalTo: quoteLabel.bottomAnchor, constant: 14),
            projectsHeader.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),

            projectsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22),
            projectsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            projectsStack.topAnchor.constraint(equalTo: projectsHeader.bottomAnchor, constant: 6),
            projectsStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -18),
        ])

        progressFillWidth = progressFill.widthAnchor.constraint(equalToConstant: 0)
        progressFillWidth?.isActive = true
    }

    @objc private func menuTapped() { onMenuRequested?() }

    func apply(snapshot: UsageSnapshot, quote: String) {
        titleLabel.stringValue = "Flamimon"
        subtitleLabel.stringValue = snapshot.stage.displayName + Self.species(snapshot.stage)
        quoteLabel.stringValue = "\u{201C}" + quote + "\u{201D}"

        todayStat.setValue(Self.short(snapshot.todayTokens))
        totalStat.setValue(Self.short(snapshot.totalTokens))
        costStat.setValue(String(format: "$%.1f", snapshot.totalCostUSD))

        leftTime.stringValue = "오늘 \(Self.short(snapshot.todayTokens))"
        rightTime.stringValue = String(format: "%.0f tok/min", snapshot.tokensPerMinute)

        let capped = min(snapshot.tokensPerMinute, 10_000)
        let ratio = capped / 10_000
        let totalWidth = progressTrack.bounds.width > 0 ? progressTrack.bounds.width : 360
        progressFillWidth?.constant = totalWidth * CGFloat(ratio)

        // sprite
        if snapshot.stage != currentStage || spriteView.image == nil {
            currentStage = snapshot.stage
            let sprite = ColorSprites.sprite(for: snapshot.stage)
            spriteView.image = PixelRenderer.renderColor(
                sprite: sprite, frameIndex: 0, pointSize: 140, bitmapScale: 4
            )
        }

        // projects
        projectsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if snapshot.projects.isEmpty {
            let p = NSTextField(labelWithString: "(데이터 없음)")
            p.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
            p.textColor = NSColor(white: 1, alpha: 0.45)
            projectsStack.addArrangedSubview(p)
        } else {
            for proj in snapshot.projects.prefix(5) {
                let line = NSTextField(labelWithString:
                    "\(proj.name)  —  \(Self.short(proj.tokens))")
                line.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
                line.textColor = NSColor(white: 1, alpha: 0.7)
                projectsStack.addArrangedSubview(line)
            }
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
