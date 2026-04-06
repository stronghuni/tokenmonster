import Cocoa

/// Concrete sprite definitions for all 6 stages of the Flamimon line.
/// Grid size: 32x32. Rendered at 64x64 bitmap in a 32pt NSImage.
///
/// Palette legend:
///   '.' transparent      'O' outline (deep red-black)
///   '#' body base         'x' body shadow      'o' body highlight
///   'a' flame accent      'y' flame highlight
///   'e' eye white         'p' pupil
///   'm' mouth dark        'w' wing membrane
enum ColorSprites {

    static let palette: [Character: NSColor] = [
        "O": ColorSprite.hex("#2a0a00"),
        "#": ColorSprite.hex("#ff7a28"),
        "x": ColorSprite.hex("#a13400"),
        "o": ColorSprite.hex("#ffb852"),
        "a": ColorSprite.hex("#ffdc3a"),
        "y": ColorSprite.hex("#fff4a0"),
        "e": ColorSprite.hex("#ffffff"),
        "p": ColorSprite.hex("#1a0a00"),
        "m": ColorSprite.hex("#5a1000"),
        "w": ColorSprite.hex("#c33800"),
    ]

    // Characters considered "solid body" for auto-outlining.
    private static let bodyChars: Set<Character> = ["#", "x", "o", "a", "y", "w", "e", "p", "m"]

    // MARK: - Stage 1: Egg
    static let egg: ColorSprite = {
        var a = SpriteBuilder(size: 32)
        // egg shape: elongated disc
        for y in 4..<28 {
            let halfWidth: Int = {
                let t = y - 16 // center
                // narrower at top + bottom
                if y < 8 { return 5 }
                if y < 11 { return 7 }
                if y < 15 { return 8 }
                if y < 22 { return 9 }
                if y < 25 { return 8 }
                if t >= 0 { return 7 }
                return 6
            }()
            a.rect("#", 16 - halfWidth, y, halfWidth * 2)
        }
        // highlights
        for (x, y) in [(11,8),(11,9),(12,9),(10,10),(11,10),(10,11),(11,11),(10,12),(11,12)] {
            a.set("o", x, y)
        }
        // shadows
        for (x, y) in [(21,20),(22,19),(22,20),(21,21),(22,21),(22,22),(21,22),(20,23),(21,23)] {
            a.set("x", x, y)
        }
        // fire spots (darker red to suggest pattern)
        a.rect("x", 13, 13, 2, 2)
        a.rect("x", 18, 16, 2, 2)
        a.rect("x", 14, 21, 2, 2)
        // auto outline
        a.outline("O", bodyChars: bodyChars)

        var b = a // B frame: add a small crack
        b.set("x", 15, 10)
        b.set("x", 16, 9)
        b.set("x", 16, 11)
        b.set("x", 17, 10)

        return ColorSprite(gridSize: 32, palette: palette, frames: [a.build(), b.build()])
    }()

    // MARK: - Stage 2: Baby "Flamkin"
    // Cute chibi: round blob, flame tuft, big eyes, tiny smile, tiny feet.
    static let baby: ColorSprite = {
        func base(lift: Int, jumping: Bool) -> SpriteBuilder {
            var g = SpriteBuilder(size: 32)
            // flame tuft (on top of head)
            let ft = 4 - lift
            g.set("a", 16, ft)
            g.set("a", 15, ft+1); g.set("y", 16, ft+1); g.set("a", 17, ft+1)
            g.set("a", 15, ft+2); g.set("y", 16, ft+2); g.set("a", 17, ft+2)
            g.set("a", 16, ft+3)
            // body round blob
            let cy = 18 - lift
            g.disc("#", 16, cy, 9)
            // shadow side (right+bottom)
            for y in (cy-6)...(cy+7) {
                for x in (16)...(24) {
                    if g.build().split(separator: "\n").count == 0 {} // no-op
                }
            }
            // add shadow pixels by hand along the right-bottom curve
            let shadowCells: [(Int,Int)] = [
                (22, cy-3),(23, cy-2),(24, cy-1),(24, cy),(24, cy+1),
                (23, cy+2),(23, cy+3),(22, cy+4),(22, cy+5),(21, cy+5),(20, cy+6),(19, cy+6),
            ]
            for (x, y) in shadowCells { g.set("x", x, y) }
            // highlight (top-left)
            let highlightCells: [(Int,Int)] = [
                (10, cy-2),(10, cy-1),(11, cy-3),(12, cy-4),(13, cy-5),(14, cy-5),
                (11, cy-2),
            ]
            for (x, y) in highlightCells { g.set("o", x, y) }
            // cheeks (light orange dots)
            g.set("o", 10, cy+1)
            g.set("o", 22, cy+1)
            // eyes
            if jumping {
                // closed happy eyes (horizontal dashes)
                g.rect("p", 12, cy-1, 3)
                g.rect("p", 17, cy-1, 3)
            } else {
                // open eyes: white + pupil
                g.rect("e", 12, cy-2, 3, 3)
                g.rect("e", 17, cy-2, 3, 3)
                g.set("p", 13, cy-1)
                g.set("p", 18, cy-1)
                // sparkle
                g.set("e", 13, cy-2)
                g.set("e", 18, cy-2)
            }
            // mouth
            if jumping {
                // open wide smile
                g.rect("m", 14, cy+2, 5, 2)
                g.set("#", 14, cy+2)
                g.set("#", 18, cy+2)
            } else {
                // small closed smile
                g.rect("m", 14, cy+3, 5)
            }
            // feet (tiny nubs beneath body)
            if !jumping {
                g.rect("x", 12, cy+8, 3)
                g.rect("x", 18, cy+8, 3)
                g.rect("O", 12, cy+9, 3)
                g.rect("O", 18, cy+9, 3)
            } else {
                g.rect("x", 13, cy+8, 2)
                g.rect("x", 18, cy+8, 2)
            }
            // outline
            g.outline("O", bodyChars: bodyChars)
            return g
        }
        let a = base(lift: 0, jumping: false).build()
        let b = base(lift: 2, jumping: true).build()
        return ColorSprite(gridSize: 32, palette: palette, frames: [a, b])
    }()

    // MARK: - Stage 3: Child "Flamon"
    static let child: ColorSprite = {
        func base(armsUp: Bool) -> SpriteBuilder {
            var g = SpriteBuilder(size: 32)
            // ear tufts (flame)
            g.set("a", 8, 4); g.set("a", 9, 5); g.set("y", 9, 4)
            g.set("a", 23, 4); g.set("a", 22, 5); g.set("y", 22, 4)
            // head
            g.disc("#", 16, 10, 7)
            // shadow side
            for (x,y) in [(21,7),(22,8),(22,9),(22,10),(22,11),(21,12),(20,13)] { g.set("x", x, y) }
            // highlights
            for (x,y) in [(10,7),(10,8),(11,6),(12,6)] { g.set("o", x, y) }
            // eyes
            g.rect("e", 11, 9, 3, 3)
            g.rect("e", 18, 9, 3, 3)
            g.set("p", 12, 10); g.set("p", 19, 10)
            g.set("e", 12, 9);  g.set("e", 19, 9)
            // mouth
            g.rect("m", 14, 13, 4)
            g.set("#", 15, 14); g.set("#", 16, 14)
            // body
            g.disc("#", 16, 19, 6)
            // body shadow
            for (x,y) in [(21,17),(21,18),(21,19),(21,20),(20,21),(19,22)] { g.set("x", x, y) }
            // belly highlight
            for (x,y) in [(13,17),(14,17),(12,18),(13,18),(13,19)] { g.set("o", x, y) }
            // arms
            if armsUp {
                // raised arms
                g.rect("#", 9, 13, 2, 3)
                g.rect("#", 21, 13, 2, 3)
                g.rect("#", 10, 16, 2, 2)
                g.rect("#", 20, 16, 2, 2)
            } else {
                // arms at sides
                g.rect("#", 9, 17, 2, 3)
                g.rect("#", 21, 17, 2, 3)
                g.rect("#", 9, 20, 3, 1)
                g.rect("#", 20, 20, 3, 1)
            }
            // legs
            g.rect("#", 12, 24, 3, 3)
            g.rect("#", 17, 24, 3, 3)
            g.rect("O", 11, 27, 4)
            g.rect("O", 17, 27, 4)
            // outline
            g.outline("O", bodyChars: bodyChars)
            return g
        }
        let a = base(armsUp: false).build()
        let b = base(armsUp: true).build()
        return ColorSprite(gridSize: 32, palette: palette, frames: [a, b])
    }()

    // MARK: - Stage 4: Teen "Blazon"
    static let teen: ColorSprite = {
        func base(wingUp: Bool, tailFlick: Bool) -> SpriteBuilder {
            var g = SpriteBuilder(size: 32)
            // mohawk crest (flame)
            g.rect("a", 15, 1, 2, 3)
            g.set("y", 16, 2)
            g.set("a", 14, 3); g.set("a", 17, 3)
            g.set("a", 13, 4); g.set("a", 18, 4)
            // horns
            g.set("O", 10, 4); g.set("O", 9, 5); g.set("O", 8, 6)
            g.set("O", 21, 4); g.set("O", 22, 5); g.set("O", 23, 6)
            // head
            g.disc("#", 16, 10, 6)
            for (x,y) in [(20,7),(21,8),(21,9),(21,10),(20,11),(19,12)] { g.set("x", x, y) }
            for (x,y) in [(11,7),(11,8),(12,6)] { g.set("o", x, y) }
            // fierce eyes (slit pupils)
            g.rect("e", 11, 9, 3, 2)
            g.rect("e", 18, 9, 3, 2)
            g.set("p", 12, 9); g.set("p", 12, 10)
            g.set("p", 19, 9); g.set("p", 19, 10)
            // mouth with small fang
            g.rect("m", 14, 12, 4)
            g.set("e", 15, 13); g.set("e", 16, 13)
            // neck
            g.rect("#", 13, 14, 6, 2)
            // body (taller, leaner than child)
            g.disc("#", 16, 20, 6)
            for (x,y) in [(21,17),(21,18),(21,19),(21,20),(21,21),(20,22)] { g.set("x", x, y) }
            for (x,y) in [(12,17),(11,18),(12,18),(11,19)] { g.set("o", x, y) }
            // arms extended
            g.rect("#", 8, 16, 3, 2)
            g.rect("#", 21, 16, 3, 2)
            g.rect("#", 7, 18, 2, 2)
            g.rect("#", 23, 18, 2, 2)
            // tail
            if tailFlick {
                g.set("#", 22, 18); g.set("#", 23, 17); g.set("#", 24, 16); g.set("#", 25, 15)
                g.set("a", 26, 14)
            } else {
                g.set("#", 22, 20); g.set("#", 23, 21); g.set("#", 24, 22); g.set("#", 25, 23)
                g.set("a", 26, 24)
            }
            // legs (battle stance)
            g.rect("#", 11, 24, 3, 3)
            g.rect("#", 18, 24, 3, 3)
            g.rect("O", 10, 27, 5)
            g.rect("O", 17, 27, 5)
            g.outline("O", bodyChars: bodyChars)
            return g
        }
        let a = base(wingUp: false, tailFlick: false).build()
        let b = base(wingUp: true,  tailFlick: true).build()
        return ColorSprite(gridSize: 32, palette: palette, frames: [a, b])
    }()

    // MARK: - Stage 5: Adult "Infernon"
    static let adult: ColorSprite = {
        func base(wingOpen: Bool) -> SpriteBuilder {
            var g = SpriteBuilder(size: 32)
            // curved horns
            g.set("O", 9, 2); g.set("O", 8, 3); g.set("O", 8, 4); g.set("O", 9, 5)
            g.set("O", 22, 2); g.set("O", 23, 3); g.set("O", 23, 4); g.set("O", 22, 5)
            // crest between horns
            g.set("a", 15, 3); g.set("a", 16, 3); g.set("y", 15, 2); g.set("a", 16, 2)
            // head (noble elongated)
            g.disc("#", 16, 10, 7)
            for (x,y) in [(21,7),(22,8),(22,9),(22,10),(22,11),(21,12),(20,13),(19,14)] { g.set("x", x, y) }
            for (x,y) in [(11,7),(10,8),(10,9),(11,6)] { g.set("o", x, y) }
            // sharp eyes
            g.rect("e", 11, 9, 3, 2)
            g.rect("e", 18, 9, 3, 2)
            g.set("p", 12, 9); g.set("p", 19, 9)
            // nostrils
            g.set("m", 14, 12); g.set("m", 17, 12)
            // wings
            if wingOpen {
                // open wings — large membrane triangles
                for (x,y) in [
                    (2,9),(3,9),(4,9),(2,10),(3,10),(4,10),(5,10),
                    (2,11),(3,11),(4,11),(5,11),(6,11),
                    (3,12),(4,12),(5,12),(6,12),(7,12),
                    (4,13),(5,13),(6,13),(7,13),(8,13),
                    (5,14),(6,14),(7,14),(8,14),
                ] { g.set("w", x, y) }
                for (x,y) in [
                    (27,9),(28,9),(29,9),(26,10),(27,10),(28,10),(29,10),
                    (25,11),(26,11),(27,11),(28,11),(29,11),
                    (24,12),(25,12),(26,12),(27,12),(28,12),
                    (23,13),(24,13),(25,13),(26,13),(27,13),
                    (23,14),(24,14),(25,14),(26,14),
                ] { g.set("w", x, y) }
            } else {
                // folded wings close to shoulders
                for (x,y) in [(6,10),(6,11),(7,11),(7,12),(8,12),(8,13)] { g.set("w", x, y) }
                for (x,y) in [(25,10),(25,11),(24,11),(24,12),(23,12),(23,13)] { g.set("w", x, y) }
            }
            // neck
            g.rect("#", 13, 15, 6, 2)
            // body
            g.disc("#", 16, 21, 7)
            for (x,y) in [(22,18),(22,19),(22,20),(22,21),(21,22),(20,23),(19,24)] { g.set("x", x, y) }
            for (x,y) in [(10,18),(10,19),(11,17)] { g.set("o", x, y) }
            // chest plate detail
            g.set("o", 15, 19); g.set("o", 16, 19); g.set("o", 15, 20); g.set("o", 16, 20)
            // tail
            g.set("#", 23, 22); g.set("#", 24, 23); g.set("#", 25, 24); g.set("#", 26, 25)
            g.set("a", 27, 25)
            // legs
            g.rect("#", 11, 25, 3, 4)
            g.rect("#", 18, 25, 3, 4)
            g.rect("O", 10, 29, 5)
            g.rect("O", 17, 29, 5)
            g.outline("O", bodyChars: bodyChars)
            return g
        }
        let a = base(wingOpen: false).build()
        let b = base(wingOpen: true).build()
        return ColorSprite(gridSize: 32, palette: palette, frames: [a, b])
    }()

    // MARK: - Stage 6: Ultimate "Phoenignis"
    static let ultimate: ColorSprite = {
        func base(wingsDown: Bool) -> SpriteBuilder {
            var g = SpriteBuilder(size: 32)
            // flame crown — three tall peaks
            g.set("a", 10, 1); g.set("a", 16, 0); g.set("a", 22, 1)
            g.set("y", 10, 2); g.set("y", 16, 1); g.set("y", 22, 2)
            g.set("a", 9, 3); g.set("a", 10, 3); g.set("a", 11, 3)
            g.set("a", 15, 2); g.set("a", 16, 2); g.set("a", 17, 2)
            g.set("a", 21, 3); g.set("a", 22, 3); g.set("a", 23, 3)
            // head
            g.disc("#", 16, 10, 6)
            for (x,y) in [(20,7),(21,8),(21,9),(21,10),(20,11),(19,12)] { g.set("x", x, y) }
            for (x,y) in [(11,7),(11,8),(12,6)] { g.set("o", x, y) }
            // piercing eyes
            g.rect("e", 11, 9, 3, 2)
            g.rect("e", 18, 9, 3, 2)
            g.set("p", 12, 9); g.set("p", 19, 9)
            g.set("m", 15, 13); g.set("m", 16, 13)
            // wings — full wingspan (extends to canvas edges)
            if wingsDown {
                // down-stroke: wings below horizontal
                for (x,y) in [
                    (1,14),(2,14),(3,14),(4,14),(5,14),
                    (0,15),(1,15),(2,15),(3,15),(4,15),(5,15),(6,15),
                    (0,16),(1,16),(2,16),(3,16),(4,16),(5,16),(6,16),(7,16),
                    (1,17),(2,17),(3,17),(4,17),(5,17),(6,17),(7,17),(8,17),
                    (3,18),(4,18),(5,18),(6,18),(7,18),(8,18),
                ] { g.set("w", x, y) }
                for (x,y) in [
                    (26,14),(27,14),(28,14),(29,14),(30,14),
                    (25,15),(26,15),(27,15),(28,15),(29,15),(30,15),(31,15),
                    (24,16),(25,16),(26,16),(27,16),(28,16),(29,16),(30,16),(31,16),
                    (23,17),(24,17),(25,17),(26,17),(27,17),(28,17),(29,17),(30,17),
                    (23,18),(24,18),(25,18),(26,18),(27,18),(28,18),
                ] { g.set("w", x, y) }
            } else {
                // up-stroke: wings above horizontal
                for (x,y) in [
                    (1,5),(2,5),(3,5),(4,5),(5,5),
                    (0,6),(1,6),(2,6),(3,6),(4,6),(5,6),(6,6),
                    (0,7),(1,7),(2,7),(3,7),(4,7),(5,7),(6,7),(7,7),
                    (1,8),(2,8),(3,8),(4,8),(5,8),(6,8),(7,8),(8,8),
                    (3,9),(4,9),(5,9),(6,9),(7,9),(8,9),
                ] { g.set("w", x, y) }
                for (x,y) in [
                    (26,5),(27,5),(28,5),(29,5),(30,5),
                    (25,6),(26,6),(27,6),(28,6),(29,6),(30,6),(31,6),
                    (24,7),(25,7),(26,7),(27,7),(28,7),(29,7),(30,7),(31,7),
                    (23,8),(24,8),(25,8),(26,8),(27,8),(28,8),(29,8),(30,8),
                    (23,9),(24,9),(25,9),(26,9),(27,9),(28,9),
                ] { g.set("w", x, y) }
            }
            // body
            g.rect("#", 13, 14, 6, 2)
            g.disc("#", 16, 21, 7)
            for (x,y) in [(22,18),(22,19),(22,20),(22,21),(21,22),(20,23),(19,24)] { g.set("x", x, y) }
            for (x,y) in [(10,18),(10,19),(11,17)] { g.set("o", x, y) }
            // glowing chest orb
            g.set("a", 15, 20); g.set("y", 16, 20); g.set("a", 16, 21); g.set("a", 15, 21)
            // legs
            g.rect("#", 11, 25, 3, 4)
            g.rect("#", 18, 25, 3, 4)
            g.rect("O", 10, 29, 5)
            g.rect("O", 17, 29, 5)
            g.outline("O", bodyChars: bodyChars)
            return g
        }
        let a = base(wingsDown: true).build()
        let b = base(wingsDown: false).build()
        return ColorSprite(gridSize: 32, palette: palette, frames: [a, b])
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
