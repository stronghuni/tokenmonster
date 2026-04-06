import Cocoa

/// Retro game-style panel with a pixel-art double border.
/// Outer: dark (deep purple or near-black).
/// Inner: gold/cream accent.
/// Background: solid fill.
class PixelPanel: NSView {
    var background: NSColor = RetroPalette.panelBg
    var outerBorder: NSColor = RetroPalette.borderDark
    var innerBorder: NSColor = RetroPalette.borderLight
    var showInnerBorder: Bool = true
    var cornerInset: CGFloat = 0  // chamfer-like corner pixel

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        ctx.setShouldAntialias(false)
        ctx.interpolationQuality = .none

        let bounds = self.bounds
        // fill background
        background.setFill()
        NSBezierPath(rect: bounds.insetBy(dx: 2, dy: 2)).fill()

        // outer dark border (2px thick)
        outerBorder.setFill()
        // top
        NSRect(x: 0, y: bounds.height - 2, width: bounds.width, height: 2).fill()
        // bottom
        NSRect(x: 0, y: 0, width: bounds.width, height: 2).fill()
        // left
        NSRect(x: 0, y: 0, width: 2, height: bounds.height).fill()
        // right
        NSRect(x: bounds.width - 2, y: 0, width: 2, height: bounds.height).fill()

        if showInnerBorder {
            innerBorder.setFill()
            // inner 1-px accent inset by 3
            NSRect(x: 3, y: bounds.height - 4, width: bounds.width - 6, height: 1).fill()
            NSRect(x: 3, y: 3, width: bounds.width - 6, height: 1).fill()
            NSRect(x: 3, y: 3, width: 1, height: bounds.height - 6).fill()
            NSRect(x: bounds.width - 4, y: 3, width: 1, height: bounds.height - 6).fill()
        }

        // chamfered corners: remove corner pixel for pixel-art feel
        background.setFill()
        let c = cornerInset
        if c > 0 {
            NSRect(x: 0, y: 0, width: c, height: c).fill()
            NSRect(x: bounds.width - c, y: 0, width: c, height: c).fill()
            NSRect(x: 0, y: bounds.height - c, width: c, height: c).fill()
            NSRect(x: bounds.width - c, y: bounds.height - c, width: c, height: c).fill()
        }
    }
}

/// Retro palette used throughout the dashboard.
enum RetroPalette {
    static let rootBg      = NSColor(srgbRed: 0.055, green: 0.043, blue: 0.118, alpha: 1)  // #0e0b1e
    static let panelBg     = NSColor(srgbRed: 0.110, green: 0.075, blue: 0.196, alpha: 1)  // #1c1332
    static let panelBgAlt  = NSColor(srgbRed: 0.156, green: 0.110, blue: 0.275, alpha: 1)  // #281c46
    static let borderDark  = NSColor(srgbRed: 0.035, green: 0.023, blue: 0.082, alpha: 1)  // #090615
    static let borderLight = NSColor(srgbRed: 1.00,  green: 0.807, blue: 0.251, alpha: 1)  // #ffce40
    static let textPrimary = NSColor(srgbRed: 0.961, green: 0.945, blue: 0.866, alpha: 1)  // #f5f1dd
    static let textMuted   = NSColor(srgbRed: 0.635, green: 0.565, blue: 0.776, alpha: 1)  // #a290c6
    static let accentGold  = NSColor(srgbRed: 1.00,  green: 0.800, blue: 0.224, alpha: 1)  // #ffcc39
    static let accentRed   = NSColor(srgbRed: 0.933, green: 0.322, blue: 0.322, alpha: 1)  // #ee5252
    static let accentBlue  = NSColor(srgbRed: 0.365, green: 0.600, blue: 0.988, alpha: 1)  // #5d99fc
    static let accentCyan  = NSColor(srgbRed: 0.325, green: 0.863, blue: 0.831, alpha: 1)  // #53dcd4

    /// A monospace font that gives a semi-retro feel.
    static func pixelFont(size: CGFloat, weight: NSFont.Weight = .bold) -> NSFont {
        NSFont.monospacedSystemFont(ofSize: size, weight: weight)
    }
}
