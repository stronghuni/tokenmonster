import Cocoa

/// Small vertical stat column: caption on top, value below.
final class StatBadge: NSView {
    private let captionLabel: NSTextField
    private let valueLabel: NSTextField

    init(caption: String) {
        self.captionLabel = NSTextField(labelWithString: caption)
        self.valueLabel = NSTextField(labelWithString: "0")
        super.init(frame: .zero)
        captionLabel.font = .systemFont(ofSize: 10, weight: .medium)
        captionLabel.textColor = NSColor(white: 1, alpha: 0.5)
        valueLabel.font = .systemFont(ofSize: 16, weight: .semibold)
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
