import Cocoa

enum PreviewExporter {
    static func run() {
        _ = NSApplication.shared
        let scale = 16
        let dir = URL(fileURLWithPath: "samples/previews", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let sprites: [(String, [[Int]])] = [
            ("01_egg",         PixelSprites.eggA),
            ("02_baby_A",      PixelSprites.babyA),
            ("02_baby_B",      PixelSprites.babyB),
            ("03_child_A",     PixelSprites.childA),
            ("03_child_B",     PixelSprites.childB),
            ("04_teen_A",      PixelSprites.teenA),
            ("04_teen_B",      PixelSprites.teenB),
            ("05_adult_A",     PixelSprites.adultA),
            ("05_adult_B",     PixelSprites.adultB),
            ("06_ultimate_A",  PixelSprites.ultimateA),
            ("06_ultimate_B",  PixelSprites.ultimateB),
        ]
        for (name, grid) in sprites {
            let img = renderPreview(grid: grid, scale: scale)
            savePNG(img, to: dir.appendingPathComponent("\(name).png"))
        }
        let sheet = renderSheet(sprites: sprites, scale: scale)
        savePNG(sheet, to: dir.appendingPathComponent("00_sheet.png"))
        print("Exported \(sprites.count) previews + sheet to \(dir.path)")
    }

    private static func renderPreview(grid: [[Int]], scale: Int) -> NSImage {
        let side = 22 * scale
        let img = NSImage(size: NSSize(width: side, height: side))
        img.lockFocus()
        NSColor(white: 0.12, alpha: 1).setFill()
        NSRect(x: 0, y: 0, width: side, height: side).fill()
        NSColor.white.setFill()
        for (row, line) in grid.enumerated() {
            let y = 22 - 1 - row
            for (col, v) in line.enumerated() where v == 1 {
                NSRect(x: col * scale, y: y * scale, width: scale, height: scale).fill()
            }
        }
        img.unlockFocus()
        return img
    }

    private static func renderSheet(sprites: [(String, [[Int]])], scale: Int) -> NSImage {
        let cell = 22 * scale
        let pad = 24
        let labelH = 30
        let cols = 4
        let rows = (sprites.count + cols - 1) / cols
        let totalW = cols * cell + (cols + 1) * pad
        let totalH = rows * (cell + labelH) + (rows + 1) * pad
        let img = NSImage(size: NSSize(width: totalW, height: totalH))
        img.lockFocus()
        NSColor(white: 0.08, alpha: 1).setFill()
        NSRect(x: 0, y: 0, width: totalW, height: totalH).fill()

        let font = NSFont.monospacedSystemFont(ofSize: 18, weight: .medium)
        let textAttrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor(white: 0.7, alpha: 1),
        ]

        for (i, entry) in sprites.enumerated() {
            let col = i % cols
            let row = i / cols
            let x = pad + col * (cell + pad)
            let yTop = pad + row * (cell + labelH + pad)
            let cellYBottom = totalH - yTop - cell

            NSColor(white: 0.15, alpha: 1).setFill()
            NSRect(x: x - 2, y: cellYBottom - 2, width: cell + 4, height: cell + 4).fill()

            NSColor.white.setFill()
            for (r, line) in entry.1.enumerated() {
                let py = 22 - 1 - r
                for (c, v) in line.enumerated() where v == 1 {
                    NSRect(x: x + c * scale, y: cellYBottom + py * scale, width: scale, height: scale).fill()
                }
            }
            let label = entry.0
            let str = NSAttributedString(string: label, attributes: textAttrs)
            str.draw(at: NSPoint(x: x, y: cellYBottom - 26))
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
