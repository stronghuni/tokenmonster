import Foundation

/// Mutable 2D character grid builder for authoring color sprites.
/// Use `.set/.rect/.disc/.circle` to draw, then `.build()` for a frame string.
struct SpriteBuilder {
    private var rows: [[Character]]
    let size: Int

    init(size: Int, fill: Character = ".") {
        self.size = size
        rows = Array(repeating: Array(repeating: fill, count: size), count: size)
    }

    mutating func set(_ c: Character, _ x: Int, _ y: Int) {
        guard y >= 0, y < size, x >= 0, x < size else { return }
        rows[y][x] = c
    }

    mutating func rect(_ c: Character, _ x: Int, _ y: Int, _ w: Int, _ h: Int = 1) {
        for dy in 0..<h { for dx in 0..<w { set(c, x+dx, y+dy) } }
    }

    /// Filled disc centered at (cx,cy).
    mutating func disc(_ c: Character, _ cx: Int, _ cy: Int, _ r: Int) {
        for y in max(0, cy-r)...min(size-1, cy+r) {
            for x in max(0, cx-r)...min(size-1, cx+r) {
                let dx = x - cx, dy = y - cy
                if dx*dx + dy*dy <= r*r + r/2 {
                    rows[y][x] = c
                }
            }
        }
    }

    /// Circle outline (1-pixel stroke).
    mutating func circle(_ c: Character, _ cx: Int, _ cy: Int, _ r: Int) {
        let outer = r*r + r/2
        let inner = (r-1)*(r-1) + (r-1)/2
        for y in max(0, cy-r)...min(size-1, cy+r) {
            for x in max(0, cx-r)...min(size-1, cx+r) {
                let dx = x - cx, dy = y - cy
                let d = dx*dx + dy*dy
                if d <= outer && d > inner {
                    rows[y][x] = c
                }
            }
        }
    }

    /// Draw a line from (x1,y1) to (x2,y2) using Bresenham.
    mutating func line(_ c: Character, _ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int) {
        var x1 = x1, y1 = y1
        let dx = abs(x2 - x1), dy = -abs(y2 - y1)
        let sx = x1 < x2 ? 1 : -1
        let sy = y1 < y2 ? 1 : -1
        var err = dx + dy
        while true {
            set(c, x1, y1)
            if x1 == x2 && y1 == y2 { break }
            let e2 = 2 * err
            if e2 >= dy { err += dy; x1 += sx }
            if e2 <= dx { err += dx; y1 += sy }
        }
    }

    /// Apply auto-outline: wherever a `body` cell is adjacent to transparent,
    /// place an outline character on the transparent side.
    mutating func outline(_ outlineChar: Character, bodyChars: Set<Character>, background: Character = ".") {
        var newRows = rows
        for y in 0..<size {
            for x in 0..<size {
                guard rows[y][x] == background else { continue }
                let neighbors: [(Int,Int)] = [(-1,0),(1,0),(0,-1),(0,1)]
                for (dx, dy) in neighbors {
                    let nx = x+dx, ny = y+dy
                    if nx >= 0, nx < size, ny >= 0, ny < size,
                       bodyChars.contains(rows[ny][nx]) {
                        newRows[y][x] = outlineChar
                        break
                    }
                }
            }
        }
        rows = newRows
    }

    func build() -> String {
        rows.map { String($0) }.joined(separator: "\n")
    }
}
