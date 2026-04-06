import Cocoa

/// Apple Music mini-player style dashboard.
/// Borderless, rounded, dark blur; left = big monster sprite; right = stats.
final class DashboardWindowController: NSWindowController {
    private let spriteView = NSImageView()
    private let titleLabel = NSTextField(labelWithString: "Flamimon")
    private let subtitleLabel = NSTextField(labelWithString: "알")
    private let closeDots = NSButton(title: "•••", target: nil, action: nil)

    // stat badges (replaces play/prev/next buttons)
    private let todayStat = StatBadge(caption: "오늘")
    private let totalStat = StatBadge(caption: "누적")
    private let costStat  = StatBadge(caption: "비용")

    // progress bar + timings
    private let progress = NSView()
    private let progressFill = NSView()
    private let leftTime  = NSTextField(labelWithString: "0")
    private let rightTime = NSTextField(labelWithString: "0")

    private var currentStage: Stage = .egg

    init() {
        let frame = NSRect(x: 0, y: 0, width: 720, height: 280)
        let win = NSWindow(
            contentRect: frame,
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        win.isReleasedWhenClosed = false
        win.titleVisibility = .hidden
        win.titlebarAppearsTransparent = true
        win.standardWindowButton(.miniaturizeButton)?.isHidden = true
        win.standardWindowButton(.zoomButton)?.isHidden = true
        win.standardWindowButton(.closeButton)?.isHidden = true
        win.isMovableByWindowBackground = true
        win.backgroundColor = .clear
        win.hasShadow = true
        win.isOpaque = false
        win.center()
        super.init(window: win)

        // Root rounded blur container
        let root = NSVisualEffectView(frame: frame)
        root.material = .hudWindow
        root.state = .active
        root.blendingMode = .behindWindow
        root.wantsLayer = true
        root.layer?.cornerRadius = 22
        root.layer?.masksToBounds = true
        root.layer?.borderWidth = 0.5
        root.layer?.borderColor = NSColor(white: 1, alpha: 0.08).cgColor
        win.contentView = root

        buildSubviews(in: root)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func buildSubviews(in root: NSView) {
        // Sprite panel (left)
        let spriteBox = NSView()
        spriteBox.wantsLayer = true
        spriteBox.layer?.cornerRadius = 14
        spriteBox.layer?.backgroundColor = NSColor(white: 0, alpha: 0.35).cgColor
        spriteBox.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(spriteBox)

        spriteView.imageScaling = .scaleProportionallyUpOrDown
        spriteView.translatesAutoresizingMaskIntoConstraints = false
        spriteBox.addSubview(spriteView)

        // Title (right)
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(titleLabel)

        subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = NSColor(white: 1, alpha: 0.6)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(subtitleLabel)

        // Close dots
        closeDots.isBordered = false
        closeDots.font = .systemFont(ofSize: 14, weight: .bold)
        closeDots.contentTintColor = NSColor(white: 1, alpha: 0.5)
        closeDots.target = self
        closeDots.action = #selector(closeWindow)
        closeDots.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(closeDots)

        // Stat row (replaces play controls)
        let statStack = NSStackView(views: [todayStat, totalStat, costStat])
        statStack.orientation = .horizontal
        statStack.distribution = .fillEqually
        statStack.spacing = 24
        statStack.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(statStack)

        // Progress track + fill
        progress.wantsLayer = true
        progress.layer?.backgroundColor = NSColor(white: 1, alpha: 0.15).cgColor
        progress.layer?.cornerRadius = 3
        progress.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(progress)

        progressFill.wantsLayer = true
        progressFill.layer?.backgroundColor = NSColor.systemBlue.cgColor
        progressFill.layer?.cornerRadius = 3
        progressFill.translatesAutoresizingMaskIntoConstraints = false
        progress.addSubview(progressFill)

        // Time labels
        [leftTime, rightTime].forEach {
            $0.font = .monospacedDigitSystemFont(ofSize: 13, weight: .medium)
            $0.textColor = NSColor(white: 1, alpha: 0.6)
            $0.translatesAutoresizingMaskIntoConstraints = false
            root.addSubview($0)
        }

        // Layout
        NSLayoutConstraint.activate([
            // sprite box
            spriteBox.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 24),
            spriteBox.topAnchor.constraint(equalTo: root.topAnchor, constant: 24),
            spriteBox.bottomAnchor.constraint(equalTo: root.bottomAnchor, constant: -24),
            spriteBox.widthAnchor.constraint(equalTo: spriteBox.heightAnchor),

            spriteView.topAnchor.constraint(equalTo: spriteBox.topAnchor, constant: 10),
            spriteView.leadingAnchor.constraint(equalTo: spriteBox.leadingAnchor, constant: 10),
            spriteView.trailingAnchor.constraint(equalTo: spriteBox.trailingAnchor, constant: -10),
            spriteView.bottomAnchor.constraint(equalTo: spriteBox.bottomAnchor, constant: -10),

            // title row
            titleLabel.leadingAnchor.constraint(equalTo: spriteBox.trailingAnchor, constant: 24),
            titleLabel.topAnchor.constraint(equalTo: root.topAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: closeDots.leadingAnchor, constant: -12),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            closeDots.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -20),
            closeDots.topAnchor.constraint(equalTo: root.topAnchor, constant: 24),

            // stat stack
            statStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            statStack.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -24),
            statStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 22),

            // progress bar
            progress.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            progress.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -24),
            progress.topAnchor.constraint(equalTo: statStack.bottomAnchor, constant: 22),
            progress.heightAnchor.constraint(equalToConstant: 6),

            progressFill.leadingAnchor.constraint(equalTo: progress.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progress.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progress.bottomAnchor),
            // width set dynamically

            leftTime.leadingAnchor.constraint(equalTo: progress.leadingAnchor),
            leftTime.topAnchor.constraint(equalTo: progress.bottomAnchor, constant: 8),
            rightTime.trailingAnchor.constraint(equalTo: progress.trailingAnchor),
            rightTime.topAnchor.constraint(equalTo: progress.bottomAnchor, constant: 8),
        ])

        progressFillWidth = progressFill.widthAnchor.constraint(equalToConstant: 0)
        progressFillWidth?.isActive = true
    }

    private var progressFillWidth: NSLayoutConstraint?

    @objc private func closeWindow() {
        window?.orderOut(nil)
    }

    func apply(snapshot: UsageSnapshot) {
        DispatchQueue.main.async {
            self.titleLabel.stringValue = "Flamimon"
            self.subtitleLabel.stringValue = snapshot.stage.displayName + Self.hint(for: snapshot.stage)

            self.todayStat.setValue(Self.short(snapshot.todayTokens))
            self.totalStat.setValue(Self.short(snapshot.totalTokens))
            self.costStat.setValue(String(format: "$%.1f", snapshot.totalCostUSD))

            self.leftTime.stringValue = "오늘 \(Self.short(snapshot.todayTokens))"
            self.rightTime.stringValue = String(format: "%.0f tok/min", snapshot.tokensPerMinute)

            // activity progress: map tokensPerMinute onto a visual bar (0 → 10000 tpm)
            let capped = min(snapshot.tokensPerMinute, 10_000)
            let ratio = capped / 10_000
            let totalWidth = self.progress.bounds.width
            self.progressFillWidth?.constant = totalWidth * CGFloat(ratio)

            // update sprite
            if snapshot.stage != self.currentStage || self.spriteView.image == nil {
                self.currentStage = snapshot.stage
                let sprite = ColorSprites.sprite(for: snapshot.stage)
                self.spriteView.image = PixelRenderer.renderColor(
                    sprite: sprite, frameIndex: 0, pointSize: 220, bitmapScale: 4
                )
            }
        }
    }

    func show() {
        NSApp.activate(ignoringOtherApps: true)
        showWindow(nil)
        window?.makeKeyAndOrderFront(nil)
    }

    private static func short(_ n: Int64) -> String {
        let d = Double(n)
        if d >= 1_000_000_000 { return String(format: "%.1fB", d / 1e9) }
        if d >= 1_000_000     { return String(format: "%.1fM", d / 1e6) }
        if d >= 1_000         { return String(format: "%.0fk", d / 1e3) }
        return "\(n)"
    }

    private static func hint(for stage: Stage) -> String {
        switch stage {
        case .egg:      return "  ·  뭔가 꿈틀거린다"
        case .baby:     return "  ·  Flamkin"
        case .child:    return "  ·  Flamon"
        case .teen:     return "  ·  Blazon"
        case .adult:    return "  ·  Infernon"
        case .ultimate: return "  ·  Phoenignis"
        }
    }
}

/// Small vertical stat column: caption on top, value below.
final class StatBadge: NSView {
    private let captionLabel: NSTextField
    private let valueLabel: NSTextField

    init(caption: String) {
        self.captionLabel = NSTextField(labelWithString: caption)
        self.valueLabel = NSTextField(labelWithString: "0")
        super.init(frame: .zero)
        captionLabel.font = .systemFont(ofSize: 11, weight: .medium)
        captionLabel.textColor = NSColor(white: 1, alpha: 0.5)
        valueLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        valueLabel.textColor = .white

        let stack = NSStackView(views: [captionLabel, valueLabel])
        stack.orientation = .vertical
        stack.alignment = .centerX
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func setValue(_ s: String) { valueLabel.stringValue = s }
}
