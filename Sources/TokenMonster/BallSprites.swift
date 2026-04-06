import Cocoa

/// Pokeball-style tier icons: monster / super / hyper.
/// Rendered as 16x16 ColorSprites and cached as NSImage.
enum BallSprites {
    private static let SIZE = 16

    private static func baseCircle(_ top: Character, _ bottom: Character) -> SpriteBuilder {
        var g = SpriteBuilder(size: SIZE)
        let cx = 8, cy = 8, r = 7
        for y in 0..<SIZE {
            for x in 0..<SIZE {
                let dx = x - cx, dy = y - cy
                let d = dx*dx + dy*dy
                if d <= r*r + r/2 {
                    if y < cy { g.set(top, x, y) }
                    else if y > cy { g.set(bottom, x, y) }
                    else { g.set("O", x, y) }  // horizontal band at center
                }
            }
        }
        // center button (small white circle with outline)
        g.set("O", 6, 7); g.set("O", 7, 7); g.set("O", 8, 7); g.set("O", 9, 7)
        g.set("O", 6, 8); g.set("e", 7, 8); g.set("e", 8, 8); g.set("O", 9, 8)
        g.set("O", 6, 9); g.set("O", 7, 9); g.set("O", 8, 9); g.set("O", 9, 9)
        // outline sweep
        g.outline("O", bodyChars: [top, bottom, "O", "e", "S", "L"])
        return g
    }

    static let monster: ColorSprite = {
        let g = baseCircle("R", "W")
        return ColorSprite(
            gridSize: SIZE,
            palette: [
                "R": ColorSprite.hex("#e63232"),
                "W": ColorSprite.hex("#f5f5f5"),
                "O": ColorSprite.hex("#111111"),
                "e": ColorSprite.hex("#ffffff"),
            ],
            frames: [g.build()]
        )
    }()

    static let superBall: ColorSprite = {
        var g = baseCircle("B", "W")
        // red stripe on top hemisphere
        g.set("R", 4, 3); g.set("R", 5, 3); g.set("R", 6, 3)
        g.set("R", 9, 3); g.set("R", 10, 3); g.set("R", 11, 3)
        g.set("R", 3, 4); g.set("R", 12, 4)
        return ColorSprite(
            gridSize: SIZE,
            palette: [
                "B": ColorSprite.hex("#2d67c2"),
                "W": ColorSprite.hex("#f5f5f5"),
                "R": ColorSprite.hex("#e63232"),
                "O": ColorSprite.hex("#111111"),
                "e": ColorSprite.hex("#ffffff"),
            ],
            frames: [g.build()]
        )
    }()

    static let hyper: ColorSprite = {
        var g = baseCircle("K", "W")
        // yellow H stripes on black top
        g.set("Y", 3, 3); g.set("Y", 4, 3)
        g.set("Y", 11, 3); g.set("Y", 12, 3)
        g.set("Y", 4, 4); g.set("Y", 11, 4)
        g.set("Y", 4, 5); g.set("Y", 11, 5)
        return ColorSprite(
            gridSize: SIZE,
            palette: [
                "K": ColorSprite.hex("#222222"),
                "W": ColorSprite.hex("#f5f5f5"),
                "Y": ColorSprite.hex("#ffcb29"),
                "O": ColorSprite.hex("#000000"),
                "e": ColorSprite.hex("#ffffff"),
            ],
            frames: [g.build()]
        )
    }()

    static func image(for tier: BallTier, pointSize: CGFloat = 18) -> NSImage {
        let sprite: ColorSprite
        switch tier {
        case .monster:   sprite = monster
        case .superBall: sprite = superBall
        case .hyper:     sprite = hyper
        }
        return PixelRenderer.renderColor(sprite: sprite, frameIndex: 0, pointSize: pointSize)
    }
}
