import Cocoa

enum PixelRenderer {
    /// Renders a ColorSprite frame as a crisp pixel-art NSImage via lockFocus.
    /// The resulting image is exactly `pointSize` points; on retina the
    /// backing store is @2x automatically, giving 2 physical pixels per grid cell
    /// when pointSize == gridSize.
    static func renderColor(sprite: ColorSprite,
                            frameIndex: Int,
                            pointSize: CGFloat,
                            bitmapScale: Int = 2) -> NSImage {
        let grid = sprite.grid(for: frameIndex)
        let cellSize = pointSize / CGFloat(sprite.gridSize)
        let img = NSImage(size: NSSize(width: pointSize, height: pointSize))
        img.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .none
        NSColor.clear.setFill()
        NSRect(x: 0, y: 0, width: pointSize, height: pointSize).fill()

        for (row, line) in grid.enumerated() {
            let y = pointSize - CGFloat(row + 1) * cellSize
            for (col, ch) in line.enumerated() {
                guard let color = sprite.palette[ch] else { continue }
                color.setFill()
                NSRect(x: CGFloat(col) * cellSize, y: y, width: cellSize, height: cellSize).fill()
            }
        }
        img.unlockFocus()
        return img
    }
}
