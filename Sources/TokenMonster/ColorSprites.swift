import Cocoa

/// Concrete sprite definitions for all 6 stages of the Flamimon line.
/// Grid size: 22x22 (matches menubar native point size with @2x retina).
/// Each grid cell = 2 bitmap pixels at @2x = 1 point. Pixel-perfect.
enum ColorSprites {

    static let palette: [Character: NSColor] = [
        "O": ColorSprite.hex("#2a0a00"),   // outline
        "#": ColorSprite.hex("#ff7a28"),   // body base
        "x": ColorSprite.hex("#a13400"),   // body shadow
        "o": ColorSprite.hex("#ffb852"),   // body highlight
        "a": ColorSprite.hex("#ffdc3a"),   // flame
        "y": ColorSprite.hex("#fff4a0"),   // flame highlight
        "e": ColorSprite.hex("#ffffff"),   // eye white
        "p": ColorSprite.hex("#1a0a00"),   // pupil
        "m": ColorSprite.hex("#5a1000"),   // mouth
        "w": ColorSprite.hex("#c33800"),   // wing
    ]

    private static let bodyChars: Set<Character> = ["#", "x", "o", "a", "y", "w", "e", "p", "m"]
    private static let SIZE = 22

    // MARK: - Stage 1: Egg
    static let egg: ColorSprite = {
        func build(cracked: Bool) -> SpriteBuilder {
            var g = SpriteBuilder(size: SIZE)
            // elongated oval
            g.disc("#", 11, 12, 7)
            g.rect("#", 7, 4, 8, 2)
            // clean the top — make it egg-shaped
            for x in 0..<SIZE { g.set(".", x, 4) }
            g.rect("#", 8, 4, 6)
            g.rect("#", 7, 5, 8)
            // highlights (upper-left)
            g.set("o", 8,  7); g.set("o", 9,  6); g.set("o", 8,  8)
            // shadows (lower-right)
            g.set("x", 15, 14); g.set("x", 15, 15); g.set("x", 14, 16)
            // fire spots
            g.set("x", 9, 10); g.set("x", 10, 10)
            g.set("x", 13, 13)
            g.set("x", 9, 16)
            if cracked {
                g.set("p", 10, 6)
                g.set("p", 11, 7)
                g.set("p", 10, 8)
            }
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
            let dy = jumping ? -1 : 0
            // flame tuft
            g.set("a", 11, 1 + dy)
            g.set("y", 11, 2 + dy); g.set("a", 10, 2 + dy); g.set("a", 12, 2 + dy)
            g.set("a", 11, 3 + dy)
            // round blob body
            g.disc("#", 11, 12 + dy, 7)
            // shadow (lower-right)
            g.set("x", 16, 10 + dy); g.set("x", 17, 11 + dy); g.set("x", 17, 12 + dy)
            g.set("x", 17, 13 + dy); g.set("x", 16, 15 + dy); g.set("x", 15, 16 + dy)
            // highlight (upper-left)
            g.set("o", 6, 10 + dy); g.set("o", 6, 11 + dy); g.set("o", 7, 9 + dy)
            g.set("o", 8, 8 + dy)
            // eyes
            if jumping {
                // closed happy eyes (^^) as 2px dashes
                g.rect("p", 8, 11 + dy, 2)
                g.rect("p", 13, 11 + dy, 2)
            } else {
                g.rect("e", 8, 10 + dy, 2, 2)
                g.rect("e", 13, 10 + dy, 2, 2)
                g.set("p", 9, 11 + dy); g.set("p", 14, 11 + dy)
            }
            // mouth
            if jumping {
                g.rect("m", 10, 14 + dy, 3)
                g.set("#", 10, 14 + dy); g.set("#", 12, 14 + dy)
            } else {
                g.rect("m", 10, 14 + dy, 3)
            }
            // tiny feet
            if !jumping {
                g.rect("x", 8, 19, 2)
                g.rect("x", 13, 19, 2)
            } else {
                g.set("x", 9, 19); g.set("x", 13, 19)
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
            // ear flame tufts
            g.set("a", 5, 3); g.set("y", 6, 3)
            g.set("a", 16, 3); g.set("y", 15, 3)
            // head
            g.disc("#", 11, 7, 4)
            g.set("x", 14, 5); g.set("x", 15, 6); g.set("x", 15, 7); g.set("x", 14, 9)
            g.set("o", 8, 5); g.set("o", 7, 6)
            // eyes
            g.rect("e", 8, 7, 2)
            g.rect("e", 13, 7, 2)
            g.set("p", 9, 7); g.set("p", 14, 7)
            // mouth
            g.rect("m", 10, 9, 3)
            // body
            g.disc("#", 11, 13, 4)
            g.set("x", 14, 12); g.set("x", 15, 13); g.set("x", 14, 15)
            g.set("o", 7, 12); g.set("o", 8, 11)
            // arms
            if armsUp {
                g.rect("#", 5, 8, 2, 3)
                g.rect("#", 15, 8, 2, 3)
                g.set("a", 5, 7); g.set("a", 16, 7)
            } else {
                g.rect("#", 6, 12, 2, 3)
                g.rect("#", 14, 12, 2, 3)
            }
            // legs
            g.rect("#", 8, 17, 2, 2)
            g.rect("#", 12, 17, 2, 2)
            g.rect("O", 7, 19, 4)
            g.rect("O", 11, 19, 4)
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
        func build(tailFlick: Bool) -> SpriteBuilder {
            var g = SpriteBuilder(size: SIZE)
            // mohawk flame crest
            g.set("a", 11, 0); g.set("a", 10, 1); g.set("y", 11, 1); g.set("a", 12, 1)
            g.set("a", 11, 2)
            // horns angled
            g.set("O", 7, 2); g.set("O", 6, 3)
            g.set("O", 15, 2); g.set("O", 16, 3)
            // head
            g.disc("#", 11, 7, 4)
            g.set("x", 14, 5); g.set("x", 15, 6); g.set("x", 15, 7); g.set("x", 14, 9)
            g.set("o", 8, 5); g.set("o", 7, 6)
            // fierce eyes
            g.set("e", 8, 7); g.set("p", 8, 8)
            g.set("e", 14, 7); g.set("p", 14, 8)
            // fanged mouth
            g.rect("m", 10, 9, 3)
            g.set("e", 10, 9)
            // neck
            g.rect("#", 9, 11, 5)
            // body (leaner, taller)
            g.rect("#", 8, 12, 7, 4)
            g.disc("#", 11, 14, 4)
            g.set("x", 14, 13); g.set("x", 14, 14); g.set("x", 14, 15)
            g.set("o", 8, 13); g.set("o", 9, 12)
            // arms extended
            g.rect("#", 6, 12, 2, 2)
            g.rect("#", 15, 12, 2, 2)
            // tail
            if tailFlick {
                g.set("#", 16, 12); g.set("#", 17, 11); g.set("a", 18, 10)
            } else {
                g.set("#", 16, 14); g.set("#", 17, 15); g.set("a", 18, 16)
            }
            // battle-stance legs
            g.rect("#", 7, 17, 2, 2)
            g.rect("#", 13, 17, 2, 2)
            g.rect("O", 6, 19, 4)
            g.rect("O", 12, 19, 4)
            g.outline("O", bodyChars: bodyChars)
            return g
        }
        return ColorSprite(
            gridSize: SIZE, palette: palette,
            frames: [build(tailFlick: false).build(), build(tailFlick: true).build()]
        )
    }()

    // MARK: - Stage 5: Adult "Infernon"
    static let adult: ColorSprite = {
        func build(wingOpen: Bool) -> SpriteBuilder {
            var g = SpriteBuilder(size: SIZE)
            // curved horns
            g.set("O", 6, 1); g.set("O", 5, 2); g.set("O", 6, 3)
            g.set("O", 15, 1); g.set("O", 16, 2); g.set("O", 15, 3)
            // head
            g.disc("#", 11, 7, 5)
            g.set("x", 15, 5); g.set("x", 16, 6); g.set("x", 16, 7); g.set("x", 15, 9)
            g.set("o", 7, 5); g.set("o", 6, 6)
            // eyes
            g.rect("e", 8, 6, 2)
            g.rect("e", 13, 6, 2)
            g.set("p", 9, 7); g.set("p", 14, 7)
            // nostrils / mouth
            g.set("m", 10, 10); g.set("m", 12, 10)
            // wings
            if wingOpen {
                // open wings — triangles reaching outward
                for (x,y) in [(1,6),(2,6),(1,7),(2,7),(3,7),(1,8),(2,8),(3,8),(4,8),(2,9),(3,9),(4,9),(3,10),(4,10)] {
                    g.set("w", x, y)
                }
                for (x,y) in [(20,6),(19,6),(20,7),(19,7),(18,7),(20,8),(19,8),(18,8),(17,8),(19,9),(18,9),(17,9),(18,10),(17,10)] {
                    g.set("w", x, y)
                }
            } else {
                // folded wings close to shoulders
                for (x,y) in [(3,8),(4,8),(4,9),(3,9)] { g.set("w", x, y) }
                for (x,y) in [(17,8),(18,8),(17,9),(18,9)] { g.set("w", x, y) }
            }
            // body
            g.disc("#", 11, 14, 5)
            g.set("x", 15, 12); g.set("x", 16, 13); g.set("x", 15, 14); g.set("x", 15, 15)
            g.set("o", 7, 12); g.set("o", 6, 13)
            // chest plate highlight
            g.set("o", 10, 13); g.set("o", 11, 13)
            // tail
            g.set("#", 16, 15); g.set("#", 17, 16); g.set("a", 18, 17)
            // legs
            g.rect("#", 7, 17, 2, 2)
            g.rect("#", 13, 17, 2, 2)
            g.rect("O", 6, 19, 4)
            g.rect("O", 12, 19, 4)
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
        func build(wingsDown: Bool) -> SpriteBuilder {
            var g = SpriteBuilder(size: SIZE)
            // flame crown (3 peaks)
            g.set("a", 6, 0); g.set("a", 11, 0); g.set("a", 16, 0)
            g.set("y", 6, 1); g.set("y", 11, 1); g.set("y", 16, 1)
            g.set("a", 5, 2); g.set("a", 7, 2)
            g.set("a", 10, 2); g.set("a", 12, 2)
            g.set("a", 15, 2); g.set("a", 17, 2)
            // head
            g.disc("#", 11, 7, 4)
            g.set("x", 14, 5); g.set("x", 15, 6); g.set("x", 14, 9)
            g.set("o", 8, 5); g.set("o", 7, 6)
            // piercing eyes
            g.set("e", 8, 7); g.set("p", 8, 7)
            g.set("e", 14, 7); g.set("p", 14, 7)
            // sharp mouth
            g.set("m", 10, 9); g.set("m", 12, 9)
            // wings span full width
            if wingsDown {
                // wings angled down (spread wide from shoulders)
                for (x,y) in [
                    (0,9),(1,9),(2,9),
                    (0,10),(1,10),(2,10),(3,10),
                    (0,11),(1,11),(2,11),(3,11),(4,11),
                    (1,12),(2,12),(3,12),(4,12),
                    (2,13),(3,13),(4,13),
                ] { g.set("w", x, y) }
                for (x,y) in [
                    (21,9),(20,9),(19,9),
                    (21,10),(20,10),(19,10),(18,10),
                    (21,11),(20,11),(19,11),(18,11),(17,11),
                    (20,12),(19,12),(18,12),(17,12),
                    (19,13),(18,13),(17,13),
                ] { g.set("w", x, y) }
            } else {
                // wings angled up (beat)
                for (x,y) in [
                    (0,4),(1,4),(2,4),
                    (0,5),(1,5),(2,5),(3,5),
                    (0,6),(1,6),(2,6),(3,6),(4,6),
                    (1,7),(2,7),(3,7),(4,7),
                    (2,8),(3,8),(4,8),
                ] { g.set("w", x, y) }
                for (x,y) in [
                    (21,4),(20,4),(19,4),
                    (21,5),(20,5),(19,5),(18,5),
                    (21,6),(20,6),(19,6),(18,6),(17,6),
                    (20,7),(19,7),(18,7),(17,7),
                    (19,8),(18,8),(17,8),
                ] { g.set("w", x, y) }
            }
            // chest + body
            g.rect("#", 9, 11, 5)
            g.disc("#", 11, 14, 4)
            g.set("x", 14, 13); g.set("x", 14, 14); g.set("x", 14, 15)
            // glowing chest orb
            g.set("a", 10, 13); g.set("y", 11, 13); g.set("a", 11, 14)
            // legs
            g.rect("#", 7, 17, 2, 2)
            g.rect("#", 13, 17, 2, 2)
            g.rect("O", 6, 19, 4)
            g.rect("O", 12, 19, 4)
            g.outline("O", bodyChars: bodyChars)
            return g
        }
        return ColorSprite(
            gridSize: SIZE, palette: palette,
            frames: [build(wingsDown: true).build(), build(wingsDown: false).build()]
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
