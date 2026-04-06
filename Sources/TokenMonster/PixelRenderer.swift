import Cocoa

enum PixelRenderer {
    /// Renders a ColorSprite frame as a crisp pixel-art NSImage.
    /// - pointSize: NSImage size in points (menubar uses ~22 or 32).
    /// - bitmapScale: multiplier for backing bitmap (2 = Retina crisp).
    /// Each character cell becomes `bitmapScale` physical pixels.
    static func renderColor(sprite: ColorSprite,
                            frameIndex: Int,
                            pointSize: CGFloat,
                            bitmapScale: Int = 2) -> NSImage {
        let grid = sprite.grid(for: frameIndex)
        let gridSize = sprite.gridSize
        let pixelSize = gridSize * bitmapScale

        guard let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: pixelSize,
            pixelsHigh: pixelSize,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 32
        ) else {
            return NSImage(size: NSSize(width: pointSize, height: pointSize))
        }
        rep.size = NSSize(width: pointSize, height: pointSize)

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
        NSGraphicsContext.current?.imageInterpolation = .none
        NSColor.clear.setFill()
        NSRect(x: 0, y: 0, width: pixelSize, height: pixelSize).fill()

        for (row, line) in grid.enumerated() {
            // flip Y: grid row 0 = top, bitmap y=0 = bottom
            let baseY = pixelSize - (row + 1) * bitmapScale
            for (col, ch) in line.enumerated() {
                guard let color = sprite.palette[ch] else { continue }
                color.setFill()
                let baseX = col * bitmapScale
                NSRect(x: baseX, y: baseY, width: bitmapScale, height: bitmapScale).fill()
            }
        }

        NSGraphicsContext.restoreGraphicsState()

        let img = NSImage(size: NSSize(width: pointSize, height: pointSize))
        img.addRepresentation(rep)
        return img
    }
}
