import Cocoa

/// Multi-color pixel sprite defined by a character-map DSL.
///
/// Usage:
///   let sprite = ColorSprite(
///       gridSize: 40,
///       palette: [
///           "O": ColorSprite.hex("#2a0e00"),   // outline
///           "#": ColorSprite.hex("#ff7a28"),   // body base
///           "o": ColorSprite.hex("#ffc44d"),   // highlight
///           "x": ColorSprite.hex("#a03800"),   // shadow
///           "e": ColorSprite.hex("#ffffff"),   // eye white
///           "p": ColorSprite.hex("#1a0a00"),   // pupil
///           "m": ColorSprite.hex("#5a1a00"),   // mouth
///       ],
///       frames: [frameAString, frameBString]
///   )
struct ColorSprite {
    let gridSize: Int
    let palette: [Character: NSColor]
    let frames: [String]

    static func hex(_ hex: String) -> NSColor {
        var s = hex
        if s.hasPrefix("#") { s.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: s).scanHexInt64(&rgb)
        let r = CGFloat((rgb >> 16) & 0xff) / 255
        let g = CGFloat((rgb >>  8) & 0xff) / 255
        let b = CGFloat( rgb        & 0xff) / 255
        return NSColor(srgbRed: r, green: g, blue: b, alpha: 1)
    }

    /// Parses a frame string into a 2D character grid, ignoring whitespace-only lines.
    func grid(for frameIndex: Int) -> [[Character]] {
        let raw = frames[frameIndex]
        var rows: [[Character]] = []
        for line in raw.split(separator: "\n", omittingEmptySubsequences: false) {
            let chars = Array(line)
            if chars.isEmpty { continue }
            rows.append(chars)
        }
        return rows
    }
}
