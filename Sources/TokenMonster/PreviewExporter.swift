import Cocoa

enum PreviewExporter {
    static func run() {
        _ = NSApplication.shared
        let dir = URL(fileURLWithPath: "samples/previews", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let stages: [(String, Stage)] = [
            ("01_egg",      .egg),
            ("02_baby",     .baby),
            ("03_child",    .child),
            ("04_teen",     .teen),
            ("05_adult",    .adult),
            ("06_ultimate", .ultimate),
        ]
        let scale = 8   // 32px grid → 256px preview
        var allImages: [(String, NSImage)] = []
        for (name, stage) in stages {
            let sprite = ColorSprites.sprite(for: stage)
            for f in 0..<sprite.frames.count {
                let img = renderLarge(sprite: sprite, frameIndex: f, scale: scale)
                let filename = "\(name)_\(f == 0 ? "A" : "B").png"
                savePNG(img, to: dir.appendingPathComponent(filename))
                allImages.append(("\(stage.displayName) \(f == 0 ? "A" : "B")", img))
            }
        }
        let sheet = renderSheet(entries: allImages)
        savePNG(sheet, to: dir.appendingPathComponent("00_sheet.png"))
        print("Exported \(allImages.count) sprites + sheet to \(dir.path)")
    }

    private static func renderLarge(sprite: ColorSprite, frameIndex: Int, scale: Int) -> NSImage {
        let grid = sprite.grid(for: frameIndex)
        let gridSize = sprite.gridSize
        let pixelSize = gridSize * scale
        let img = NSImage(size: NSSize(width: pixelSize, height: pixelSize))
        img.lockFocus()
        NSColor(white: 0.1, alpha: 1).setFill()
        NSRect(x: 0, y: 0, width: pixelSize, height: pixelSize).fill()
        for (row, line) in grid.enumerated() {
            let y = pixelSize - (row + 1) * scale
            for (col, ch) in line.enumerated() {
                guard let color = sprite.palette[ch] else { continue }
                color.setFill()
                NSRect(x: col * scale, y: y, width: scale, height: scale).fill()
            }
        }
        img.unlockFocus()
        return img
    }

    private static func renderSheet(entries: [(String, NSImage)]) -> NSImage {
        let cols = 3
        let cellW = 270
        let cellH = 290
        let rows = (entries.count + cols - 1) / cols
        let pad = 20
        let totalW = cols * cellW + (cols + 1) * pad
        let totalH = rows * cellH + (rows + 1) * pad
        let img = NSImage(size: NSSize(width: totalW, height: totalH))
        img.lockFocus()
        NSColor(white: 0.08, alpha: 1).setFill()
        NSRect(x: 0, y: 0, width: totalW, height: totalH).fill()

        let font = NSFont.monospacedSystemFont(ofSize: 18, weight: .medium)
        let textAttrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor(white: 0.85, alpha: 1),
        ]

        for (i, entry) in entries.enumerated() {
            let col = i % cols
            let row = i / cols
            let x = pad + col * (cellW + pad)
            let yTop = pad + row * (cellH + pad)
            let cellYBottom = totalH - yTop - cellH
            NSColor(white: 0.14, alpha: 1).setFill()
            NSRect(x: x, y: cellYBottom, width: cellW, height: cellH).fill()
            // draw the sprite image centered in the cell, preserving aspect
            let sprite = entry.1
            let spriteSize: CGFloat = 240
            let sx = CGFloat(x) + (CGFloat(cellW) - spriteSize) / 2
            let sy = CGFloat(cellYBottom) + 34
            sprite.draw(in: NSRect(x: sx, y: sy, width: spriteSize, height: spriteSize))
            // label
            let label = NSAttributedString(string: entry.0, attributes: textAttrs)
            label.draw(at: NSPoint(x: CGFloat(x) + 12, y: CGFloat(cellYBottom) + 8))
        }
        img.unlockFocus()
        return img
    }

    private static func savePNG(_ image: NSImage, to url: URL) {
        guard let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let png = rep.representation(using: .png, properties: [:]) else { return }
        try? png.write(to: url)
    }
}
