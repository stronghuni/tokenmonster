import Cocoa

/// High-resolution (48x48) sprites used in the dashboard popover.
/// Menubar still uses the compact 22x22 versions in `ColorSprites`.
///
/// Palette legend:
///   '.' transparent        'O' dark outline
///   '#' body base           'x' body shadow        'o' body highlight
///   'b' belly/pale          'a' flame mid          'y' flame highlight
///   'e' eye white           'p' pupil              'm' mouth dark
///   'r' blush/red accent    'w' wing membrane      'k' horn black
enum LargeSprites {
    static let palette: [Character: NSColor] = [
        "O": ColorSprite.hex("#2a0a00"),
        "#": ColorSprite.hex("#ff7a28"),
        "x": ColorSprite.hex("#a13400"),
        "o": ColorSprite.hex("#ffb852"),
        "b": ColorSprite.hex("#ffd878"),
        "a": ColorSprite.hex("#ffdc3a"),
        "y": ColorSprite.hex("#fff4a0"),
        "e": ColorSprite.hex("#ffffff"),
        "p": ColorSprite.hex("#1a0a00"),
        "m": ColorSprite.hex("#5a1000"),
        "r": ColorSprite.hex("#ff4d4d"),
        "w": ColorSprite.hex("#c33800"),
        "k": ColorSprite.hex("#3a1a00"),
    ]

    private static let bodyChars: Set<Character> = [
        "#", "x", "o", "b", "a", "y", "e", "p", "m", "r", "w", "k"
    ]
    private static let SIZE = 48

    // MARK: - Helpers

    private static func drawEye(_ g: inout SpriteBuilder, cx: Int, cy: Int, lookRight: Bool = false) {
        // 5x5 eye with 3x3 pupil + 1px sparkle
        g.rect("e", cx - 2, cy - 2, 5, 5)
        let px = lookRight ? cx : cx - 1
        g.rect("p", px, cy - 1, 2, 3)
        g.set("e", px, cy - 1)  // sparkle
    }

    private static func drawBlinkingEye(_ g: inout SpriteBuilder, cx: Int, cy: Int) {
        // ^^ closed eye
        g.rect("p", cx - 2, cy, 5)
        g.rect("p", cx - 1, cy - 1, 3)
        g.set("p", cx, cy - 2)
    }

    private static func drawFlame(_ g: inout SpriteBuilder, cx: Int, baseY: Int, height: Int) {
        // teardrop flame with yellow core
        for i in 0..<height {
            let y = baseY - i
            let w: Int
            switch i {
            case 0, 1: w = 5
            case 2: w = 4
            case 3: w = 3
            case 4: w = 2
            default: w = 1
            }
            g.rect("a", cx - w/2, y, w)
        }
        // inner highlight
        for i in 1..<(height - 1) {
            g.set("y", cx, baseY - i)
        }
    }

    private static func shadeOrb(_ g: inout SpriteBuilder, cx: Int, cy: Int, r: Int) {
        // Adds shadow on lower-right quadrant + highlight on upper-left quadrant
        // Requires the base '#' to already be drawn.
        for y in (cy - r)...(cy + r) {
            for x in (cx - r)...(cx + r) {
                let dx = x - cx, dy = y - cy
                let d = dx * dx + dy * dy
                guard d <= r * r + r / 2 else { continue }
                // shadow crescent
                if dx + dy >= (r - 2) {
                    g.set("x", x, y)
                }
                // deeper outer shadow
                if dx + dy >= (r - 1) && d >= (r - 2) * (r - 2) {
                    g.set("x", x, y)
                }
                // highlight
                if -dx + (-dy) >= (r - 3) && d <= (r - 2) * (r - 2) {
                    g.set("o", x, y)
                }
            }
        }
    }

    // MARK: - Stage 1: Egg

    static let egg: ColorSprite = {
        func build(cracked: Bool) -> SpriteBuilder {
            var g = SpriteBuilder(size: SIZE)
            // egg oval: two stacked discs
            g.disc("#", 24, 22, 14)
            g.disc("#", 24, 28, 16)
            // cleanup sharp top
            for x in 0..<SIZE { g.set(".", x, 6) }
            // smooth top with small disc
            for y in 8..<14 {
                let w: Int
                switch y {
                case 8: w = 8
                case 9: w = 12
                case 10: w = 14
                case 11: w = 15
                case 12: w = 15
                default: w = 16
                }
                g.rect("#", 24 - w / 2, y, w)
            }
            shadeOrb(&g, cx: 24, cy: 26, r: 16)
            // fire spots on shell
            g.rect("x", 14, 18, 3, 3)
            g.rect("x", 30, 24, 3, 3)
            g.rect("x", 18, 34, 4, 3)
            g.rect("x", 29, 36, 3, 2)
            if cracked {
                g.set("p", 22, 14); g.set("p", 23, 15)
                g.set("p", 24, 14); g.set("p", 25, 15)
                g.set("p", 23, 16); g.set("p", 26, 16)
            }
            // belly highlight on bottom (light yellow)
            g.rect("b", 18, 38, 12, 2)
            g.outline("O", bodyChars: bodyChars)
            return g
        }
        return ColorSprite(
            gridSize: SIZE, palette: palette,
            frames: [build(cracked: false).build(), build(cracked: true).build()]
        )
    }()

    // MARK: - Stage 2: Baby "Flamkin"

    static let baby: ColorSprite = {
        func build(jumping: Bool) -> SpriteBuilder {
            var g = SpriteBuilder(size: SIZE)
            let dy = jumping ? -3 : 0

            // Body disc (large chibi head-body)
            g.disc("#", 24, 26 + dy, 17)
            shadeOrb(&g, cx: 24, cy: 26 + dy, r: 17)

            // Belly cream patch
            g.disc("b", 24, 32 + dy, 8)

            // Flame tuft on top (tall, layered)
            drawFlame(&g, cx: 24, baseY: 11 + dy, height: 8)

            // Eyes (big, with sparkle)
            if jumping {
                drawBlinkingEye(&g, cx: 17, cy: 24 + dy)
                drawBlinkingEye(&g, cx: 31, cy: 24 + dy)
            } else {
                drawEye(&g, cx: 17, cy: 24 + dy)
                drawEye(&g, cx: 31, cy: 24 + dy)
            }

            // Blush dots
            g.rect("r", 12, 30 + dy, 3, 2)
            g.rect("r", 33, 30 + dy, 3, 2)

            // Mouth
            if jumping {
                // wide open smile
                g.rect("m", 20, 34 + dy, 8, 3)
                g.set("#", 20, 34 + dy); g.set("#", 27, 34 + dy)
                g.rect("m", 21, 35 + dy, 6)
                g.set("e", 22, 35 + dy); g.set("e", 25, 35 + dy)  // teeth highlights
            } else {
                // small happy smile
                g.rect("m", 20, 35 + dy, 8)
                g.set("m", 19, 34 + dy); g.set("m", 28, 34 + dy)
            }

            // Tiny feet
            if !jumping {
                g.rect("x", 15, 42, 5, 3)
                g.rect("x", 28, 42, 5, 3)
                g.set("#", 15, 42); g.set("#", 28, 42)
            } else {
                g.rect("x", 17, 41, 4, 2)
                g.rect("x", 27, 41, 4, 2)
            }

            g.outline("O", bodyChars: bodyChars)
            return g
        }
        return ColorSprite(
            gridSize: SIZE, palette: palette,
            frames: [build(jumping: false).build(), build(jumping: true).build()]
        )
    }()

    // MARK: - Stage 3: Child "Flamon"

    static let child: ColorSprite = {
        func build(armsUp: Bool) -> SpriteBuilder {
            var g = SpriteBuilder(size: SIZE)

            // ear-tuft flames
            drawFlame(&g, cx: 12, baseY: 11, height: 6)
            drawFlame(&g, cx: 36, baseY: 11, height: 6)

            // head (large round)
            g.disc("#", 24, 17, 11)
            shadeOrb(&g, cx: 24, cy: 17, r: 11)
            g.disc("b", 24, 22, 6) // belly/chin highlight

            // eyes
            if armsUp {
                drawBlinkingEye(&g, cx: 18, cy: 15)
                drawBlinkingEye(&g, cx: 30, cy: 15)
            } else {
                drawEye(&g, cx: 18, cy: 15)
                drawEye(&g, cx: 30, cy: 15)
            }

            // mouth
            g.rect("m", 21, 24, 6)
            g.set("m", 22, 25); g.set("m", 25, 25)

            // blush
            g.rect("r", 13, 20, 3, 2)
            g.rect("r", 32, 20, 3, 2)

            // neck
            g.rect("#", 19, 28, 10, 2)

            // body (wider below)
            g.disc("#", 24, 34, 10)
            shadeOrb(&g, cx: 24, cy: 34, r: 10)
            g.disc("b", 24, 36, 5)

            // arms
            if armsUp {
                // reaching up (celebration)
                g.rect("#", 11, 14, 3, 6)
                g.rect("#", 34, 14, 3, 6)
                g.rect("#", 11, 20, 4, 3)
                g.rect("#", 33, 20, 4, 3)
                g.set("a", 12, 12); g.set("a", 35, 12)
            } else {
                // at sides
                g.rect("#", 12, 30, 3, 6)
                g.rect("#", 33, 30, 3, 6)
                g.rect("#", 11, 34, 4, 3)
                g.rect("#", 33, 34, 4, 3)
            }

            // legs
            g.rect("#", 17, 42, 5, 4)
            g.rect("#", 26, 42, 5, 4)
            g.rect("x", 16, 45, 6, 2)
            g.rect("x", 26, 45, 6, 2)

            g.outline("O", bodyChars: bodyChars)
            return g
        }
        return ColorSprite(
            gridSize: SIZE, palette: palette,
            frames: [build(armsUp: false).build(), build(armsUp: true).build()]
        )
    }()

    // MARK: - Stage 4: Teen "Blazon"

    static let teen: ColorSprite = {
        func build(pose: Int) -> SpriteBuilder {
            var g = SpriteBuilder(size: SIZE)

            // mohawk flame crest (tall center)
            drawFlame(&g, cx: 24, baseY: 5, height: 9)

            // side horns (curved outward)
            for (x, y) in [(13, 6), (13, 7), (12, 8), (11, 9), (11, 10)] { g.set("k", x, y) }
            for (x, y) in [(34, 6), (34, 7), (35, 8), (36, 9), (36, 10)] { g.set("k", x, y) }

            // head
            g.disc("#", 24, 17, 11)
            shadeOrb(&g, cx: 24, cy: 17, r: 11)
            g.disc("b", 24, 22, 5)

            // fierce slanted eyes
            g.rect("e", 15, 14, 5, 3)
            g.rect("e", 28, 14, 5, 3)
            g.rect("p", 16, 15, 3, 2)
            g.rect("p", 29, 15, 3, 2)
            // slant mark
            g.set("O", 14, 13); g.set("O", 15, 12)
            g.set("O", 33, 13); g.set("O", 32, 12)

            // fanged mouth
            g.rect("m", 21, 24, 6, 2)
            g.set("e", 22, 25); g.set("e", 25, 25)

            // neck
            g.rect("#", 18, 28, 12, 2)

            // broad body
            g.disc("#", 24, 36, 12)
            shadeOrb(&g, cx: 24, cy: 36, r: 12)
            g.disc("b", 24, 38, 6)

            // arms (extended wide)
            if pose == 0 {
                g.rect("#", 9, 30, 4, 6)
                g.rect("#", 35, 30, 4, 6)
                g.rect("#", 8, 35, 4, 3)
                g.rect("#", 36, 35, 4, 3)
            } else {
                g.rect("#", 10, 28, 4, 6)
                g.rect("#", 34, 28, 4, 6)
                g.rect("#", 9, 33, 4, 3)
                g.rect("#", 35, 33, 4, 3)
            }

            // curled tail with flame tip
            if pose == 0 {
                g.rect("#", 37, 34, 3, 2)
                g.rect("#", 39, 32, 3, 2)
                g.rect("#", 41, 30, 2, 2)
                drawFlame(&g, cx: 42, baseY: 28, height: 4)
            } else {
                g.rect("#", 37, 36, 3, 2)
                g.rect("#", 39, 38, 3, 2)
                g.rect("#", 41, 40, 2, 2)
                drawFlame(&g, cx: 43, baseY: 40, height: 3)
            }

            // battle stance legs
            g.rect("#", 15, 43, 5, 4)
            g.rect("#", 28, 43, 5, 4)
            g.rect("x", 14, 46, 7)
            g.rect("x", 27, 46, 7)

            g.outline("O", bodyChars: bodyChars)
            return g
        }
        return ColorSprite(
            gridSize: SIZE, palette: palette,
            frames: [build(pose: 0).build(), build(pose: 1).build()]
        )
    }()

    // MARK: - Stage 5: Adult "Infernon"

    static let adult: ColorSprite = {
        func build(wingOpen: Bool) -> SpriteBuilder {
            var g = SpriteBuilder(size: SIZE)

            // large curved horns
            for (x, y) in [(12, 3), (11, 4), (11, 5), (11, 6), (12, 7), (13, 7)] { g.set("k", x, y) }
            for (x, y) in [(35, 3), (36, 4), (36, 5), (36, 6), (35, 7), (34, 7)] { g.set("k", x, y) }

            // head
            g.disc("#", 24, 15, 11)
            shadeOrb(&g, cx: 24, cy: 15, r: 11)
            g.disc("b", 24, 20, 5)

            // piercing eyes
            g.rect("e", 15, 13, 5, 3)
            g.rect("e", 28, 13, 5, 3)
            g.rect("p", 17, 14, 2, 2)
            g.rect("p", 30, 14, 2, 2)

            // snout/nostrils
            g.rect("m", 22, 21, 4)
            g.set("p", 22, 22); g.set("p", 25, 22)

            // neck/shoulders
            g.rect("#", 17, 26, 14, 3)

            // wings (behind shoulders)
            if wingOpen {
                // spread wings — large triangles
                for (x, y) in [
                    (3, 12),(2, 13),(1, 14),(1, 15),(2, 16),(3, 17),(3, 18),
                    (4, 12),(4, 13),(3, 14),(3, 15),(4, 16),(4, 17),(4, 18),
                    (5, 13),(5, 14),(5, 15),(5, 16),(5, 17),(5, 18),
                    (6, 14),(6, 15),(6, 16),(6, 17),
                    (7, 15),(7, 16),(7, 17),
                    (8, 16),(8, 17),
                ] { g.set("w", x, y) }
                for (x, y) in [
                    (44, 12),(45, 13),(46, 14),(46, 15),(45, 16),(44, 17),(44, 18),
                    (43, 12),(43, 13),(44, 14),(44, 15),(43, 16),(43, 17),(43, 18),
                    (42, 13),(42, 14),(42, 15),(42, 16),(42, 17),(42, 18),
                    (41, 14),(41, 15),(41, 16),(41, 17),
                    (40, 15),(40, 16),(40, 17),
                    (39, 16),(39, 17),
                ] { g.set("w", x, y) }
            } else {
                // folded wings close to body
                for (x, y) in [
                    (7, 14),(7, 15),(8, 14),(8, 15),(8, 16),(9, 15),(9, 16),(9, 17),
                    (10, 16),(10, 17),(10, 18),
                ] { g.set("w", x, y) }
                for (x, y) in [
                    (40, 14),(40, 15),(39, 14),(39, 15),(39, 16),(38, 15),(38, 16),(38, 17),
                    (37, 16),(37, 17),(37, 18),
                ] { g.set("w", x, y) }
            }

            // broad body (chest)
            g.disc("#", 24, 34, 12)
            shadeOrb(&g, cx: 24, cy: 34, r: 12)
            g.disc("b", 24, 36, 6)

            // chest plate markings
            g.set("a", 22, 32); g.set("a", 25, 32)
            g.set("a", 22, 35); g.set("a", 25, 35)
            g.set("y", 23, 33); g.set("y", 24, 33)

            // tail (dragon, curved right)
            g.rect("#", 36, 38, 3, 2)
            g.rect("#", 39, 40, 3, 2)
            g.rect("#", 41, 42, 3, 2)
            drawFlame(&g, cx: 44, baseY: 42, height: 4)

            // legs
            g.rect("#", 15, 42, 5, 5)
            g.rect("#", 28, 42, 5, 5)
            g.rect("x", 14, 46, 7)
            g.rect("x", 27, 46, 7)

            g.outline("O", bodyChars: bodyChars)
            return g
        }
        return ColorSprite(
            gridSize: SIZE, palette: palette,
            frames: [build(wingOpen: false).build(), build(wingOpen: true).build()]
        )
    }()

    // MARK: - Stage 6: Ultimate "Phoenignis"

    static let ultimate: ColorSprite = {
        func build(wingsUp: Bool) -> SpriteBuilder {
            var g = SpriteBuilder(size: SIZE)

            // flame crown — three peaks
            drawFlame(&g, cx: 16, baseY: 6, height: 6)
            drawFlame(&g, cx: 24, baseY: 4, height: 8)
            drawFlame(&g, cx: 32, baseY: 6, height: 6)

            // head
            g.disc("#", 24, 16, 10)
            shadeOrb(&g, cx: 24, cy: 16, r: 10)
            g.disc("b", 24, 20, 5)

            // piercing narrow eyes
            g.rect("e", 16, 14, 5, 2)
            g.rect("e", 27, 14, 5, 2)
            g.rect("p", 18, 15, 2, 1)
            g.rect("p", 29, 15, 2, 1)

            // sharp mouth
            g.rect("m", 22, 21, 4)
            g.set("m", 21, 22); g.set("m", 25, 22)

            // neck/shoulder
            g.rect("#", 17, 25, 14, 3)

            // MASSIVE wings (fill canvas edges)
            if wingsUp {
                // up stroke — wings reach top corners
                for (x, y) in [
                    (0, 4),(1, 4),(2, 4),
                    (0, 5),(1, 5),(2, 5),(3, 5),(4, 5),
                    (0, 6),(1, 6),(2, 6),(3, 6),(4, 6),(5, 6),
                    (1, 7),(2, 7),(3, 7),(4, 7),(5, 7),(6, 7),
                    (2, 8),(3, 8),(4, 8),(5, 8),(6, 8),(7, 8),
                    (3, 9),(4, 9),(5, 9),(6, 9),(7, 9),(8, 9),
                    (4,10),(5,10),(6,10),(7,10),(8,10),
                    (5,11),(6,11),(7,11),(8,11),
                    (6,12),(7,12),(8,12),
                ] { g.set("w", x, y) }
                for (x, y) in [
                    (47, 4),(46, 4),(45, 4),
                    (47, 5),(46, 5),(45, 5),(44, 5),(43, 5),
                    (47, 6),(46, 6),(45, 6),(44, 6),(43, 6),(42, 6),
                    (46, 7),(45, 7),(44, 7),(43, 7),(42, 7),(41, 7),
                    (45, 8),(44, 8),(43, 8),(42, 8),(41, 8),(40, 8),
                    (44, 9),(43, 9),(42, 9),(41, 9),(40, 9),(39, 9),
                    (43,10),(42,10),(41,10),(40,10),(39,10),
                    (42,11),(41,11),(40,11),(39,11),
                    (41,12),(40,12),(39,12),
                ] { g.set("w", x, y) }
            } else {
                // down stroke — wings below horizontal
                for (x, y) in [
                    (2, 18),(3, 18),(4, 18),(5, 18),(6, 18),(7, 18),(8, 18),
                    (1, 19),(2, 19),(3, 19),(4, 19),(5, 19),(6, 19),(7, 19),(8, 19),(9, 19),
                    (0, 20),(1, 20),(2, 20),(3, 20),(4, 20),(5, 20),(6, 20),(7, 20),(8, 20),(9, 20),
                    (0, 21),(1, 21),(2, 21),(3, 21),(4, 21),(5, 21),(6, 21),(7, 21),(8, 21),
                    (1, 22),(2, 22),(3, 22),(4, 22),(5, 22),(6, 22),(7, 22),
                    (2, 23),(3, 23),(4, 23),(5, 23),(6, 23),
                    (3, 24),(4, 24),(5, 24),
                ] { g.set("w", x, y) }
                for (x, y) in [
                    (45, 18),(44, 18),(43, 18),(42, 18),(41, 18),(40, 18),(39, 18),
                    (46, 19),(45, 19),(44, 19),(43, 19),(42, 19),(41, 19),(40, 19),(39, 19),(38, 19),
                    (47, 20),(46, 20),(45, 20),(44, 20),(43, 20),(42, 20),(41, 20),(40, 20),(39, 20),(38, 20),
                    (47, 21),(46, 21),(45, 21),(44, 21),(43, 21),(42, 21),(41, 21),(40, 21),(39, 21),
                    (46, 22),(45, 22),(44, 22),(43, 22),(42, 22),(41, 22),(40, 22),
                    (45, 23),(44, 23),(43, 23),(42, 23),(41, 23),
                    (44, 24),(43, 24),(42, 24),
                ] { g.set("w", x, y) }
            }

            // body
            g.disc("#", 24, 34, 12)
            shadeOrb(&g, cx: 24, cy: 34, r: 12)
            g.disc("b", 24, 36, 6)

            // glowing chest orb
            g.rect("a", 22, 32, 4, 4)
            g.rect("y", 23, 33, 2, 2)

            // regal tail
            g.rect("#", 36, 38, 3, 2)
            g.rect("#", 38, 40, 3, 2)
            g.rect("#", 40, 42, 3, 2)
            drawFlame(&g, cx: 43, baseY: 42, height: 5)

            // legs
            g.rect("#", 15, 42, 5, 5)
            g.rect("#", 28, 42, 5, 5)
            g.rect("x", 14, 46, 7)
            g.rect("x", 27, 46, 7)

            g.outline("O", bodyChars: bodyChars)
            return g
        }
        return ColorSprite(
            gridSize: SIZE, palette: palette,
            frames: [build(wingsUp: false).build(), build(wingsUp: true).build()]
        )
    }()

    static func sprite(for stage: Stage) -> ColorSprite {
        switch stage {
        case .egg:      return egg
        case .baby:     return baby
        case .child:    return child
        case .teen:     return teen
        case .adult:    return adult
        case .ultimate: return ultimate
        }
    }
}
