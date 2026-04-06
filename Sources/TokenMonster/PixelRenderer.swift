import Cocoa

enum PixelRenderer {
    /// Renders a 22x22 grid to a template NSImage.
    /// rotationDegrees rotates around the bottom-center (for egg wobble).
    static func render(grid: [[Int]], rotationDegrees: CGFloat = 0) -> NSImage {
        let size = NSSize(width: 22, height: 22)
        let image = NSImage(size: size)
        image.lockFocus()
        defer { image.unlockFocus() }

        guard let ctx = NSGraphicsContext.current?.cgContext else { return image }

        ctx.saveGState()
        // rotate around bottom-center of the 22x22 canvas
        // NSImage origin is bottom-left, bottom-center = (11, 3)
        ctx.translateBy(x: 11, y: 3)
        ctx.rotate(by: rotationDegrees * .pi / 180)
        ctx.translateBy(x: -11, y: -3)

        ctx.setFillColor(NSColor.black.cgColor)
        for (row, line) in grid.enumerated() {
            // SVG-style top-down row → flip to NSImage bottom-up y
            let y = 22 - 1 - row
            for (col, v) in line.enumerated() where v == 1 {
                ctx.fill(CGRect(x: col, y: y, width: 1, height: 1))
            }
        }
        ctx.restoreGState()

        image.isTemplate = true
        return image
    }
}
