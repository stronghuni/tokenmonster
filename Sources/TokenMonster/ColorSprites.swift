import Cocoa

/// Menubar sprites — clean 22x22 template (single-color silhouette, RunCat-style).
/// Each stage has 4 frames for a continuous tail-wag cycle.
/// Rendered with `isTemplate = true` so macOS inverts for dark/light menubar.
enum ColorSprites {

    static let palette: [Character: NSColor] = [
        "#": NSColor.black,  // template — system inverts based on appearance
    ]

    private static let bodyChars: Set<Character> = ["#"]
    private static let SIZE = 22

    // MARK: - Stage 1: Egg (wobble only, no tail)
    static let egg: ColorSprite = {
        func build(_ highlight: Bool) -> SpriteBuilder {
            var g = SpriteBuilder(size: SIZE)
            // oval body
            g.rect("#", 9, 3, 4)
            g.rect("#", 8, 4, 6)
            g.rect("#", 7, 5, 8)
            g.rect("#", 6, 6, 10)
            g.rect("#", 6, 7, 10)
            g.rect("#", 5, 8, 12)
            g.rect("#", 5, 9, 12)
            g.rect("#", 5, 10, 12)
            g.rect("#", 5, 11, 12)
            g.rect("#", 5, 12, 12)
            g.rect("#", 5, 13, 12)
            g.rect("#", 5, 14, 12)
            g.rect("#", 5, 15, 12)
            g.rect("#", 6, 16, 10)
            g.rect("#", 6, 17, 10)
            g.rect("#", 7, 18, 8)
            g.rect("#", 9, 19, 4)
            // fire spots (cut holes)
            g.set(".", 8, 9); g.set(".", 9, 10)
            g.set(".", 13, 12); g.set(".", 14, 11)
            g.set(".", 9, 15); g.set(".", 10, 16)
            if highlight {
                g.set(".", 15, 5); g.set(".", 15, 6)
            }
            return g
        }
        return ColorSprite(
            gridSize: SIZE, palette: palette,
            frames: [build(false).build(), build(true).build(),
                     build(false).build(), build(true).build()]
        )
    }()

    // MARK: - Stage 2: Baby "Flamkin"
    // Round blob + flame tuft + dot eyes + tail nub that wags up/down
    static let baby: ColorSprite = {
        func build(tailYOffset: Int, mouth: Int) -> SpriteBuilder {
            var g = SpriteBuilder(size: SIZE)
            // flame tuft
            g.set("#", 10, 1); g.set("#", 11, 1)
            g.set("#", 9, 2);  g.set("#", 10, 2); g.set("#", 11, 2); g.set("#", 12, 2)
            g.set("#", 10, 3); g.set("#", 11, 3)
            // round body
            g.rect("#", 7, 5, 9)
            g.rect("#", 6, 6, 11)
            g.rect("#", 5, 7, 13)
            g.rect("#", 4, 8, 15)
            g.rect("#", 4, 9, 15)
            g.rect("#", 4, 10, 15)
            g.rect("#", 4, 11, 15)
            g.rect("#", 4, 12, 15)
            g.rect("#", 4, 13, 15)
            g.rect("#", 5, 14, 13)
            g.rect("#", 5, 15, 13)
            g.rect("#", 6, 16, 11)
            g.rect("#", 7, 17, 9)
            // eyes (punch holes)
            g.set(".", 8, 9); g.set(".", 8, 10)
            g.set(".", 14, 9); g.set(".", 14, 10)
            // mouth
            switch mouth {
            case 0: g.rect(".", 10, 12, 3, 1)
            case 1: g.rect(".", 10, 12, 3, 2)
            default: g.rect(".", 10, 12, 3, 1)
            }
            // tiny feet
            g.rect("#", 7, 18, 2)
            g.rect("#", 13, 18, 2)
            // tail nub on right side — wags up/down
            let ty = 11 + tailYOffset
            g.set("#", 18, ty)
            g.set("#", 19, ty)
            g.set("#", 19, ty - 1)
            g.set("#", 20, ty - 1)
            return g
        }
        return ColorSprite(
            gridSize: SIZE, palette: palette,
            frames: [
                build(tailYOffset: 0,  mouth: 0).build(),
                build(tailYOffset: -2, mouth: 1).build(),
                build(tailYOffset: 0,  mouth: 0).build(),
                build(tailYOffset: 2,  mouth: 0).build(),
            ]
        )
    }()

    // MARK: - Stage 3: Child "Flamon"
    // Bipedal + two ear-tufts + tail that wags
    static let child: ColorSprite = {
        func build(tailYOffset: Int, armUp: Bool) -> SpriteBuilder {
            var g = SpriteBuilder(size: SIZE)
            // ear tufts
            g.set("#", 5, 1); g.set("#", 6, 2); g.set("#", 6, 3)
            g.set("#", 16, 1); g.set("#", 15, 2); g.set("#", 15, 3)
            // head
            g.rect("#", 7, 3, 8)
            g.rect("#", 6, 4, 10)
            g.rect("#", 5, 5, 12)
            g.rect("#", 5, 6, 12)
            g.rect("#", 5, 7, 12)
            g.rect("#", 6, 8, 10)
            // eyes
            g.set(".", 8, 6); g.set(".", 9, 6)
            g.set(".", 13, 6); g.set(".", 14, 6)
            // mouth
            g.rect(".", 10, 8, 2)
            // neck
            g.rect("#", 9, 9, 4)
            // body
            g.rect("#", 7, 10, 8)
            g.rect("#", 6, 11, 10)
            g.rect("#", 6, 12, 10)
            g.rect("#", 7, 13, 8)
            g.rect("#", 7, 14, 8)
            // arms
            if armUp {
                g.set("#", 5, 10); g.set("#", 5, 11)
                g.set("#", 16, 10); g.set("#", 16, 11)
            } else {
                g.set("#", 5, 11); g.set("#", 5, 12); g.set("#", 4, 12)
                g.set("#", 16, 11); g.set("#", 16, 12); g.set("#", 17, 12)
            }
            // legs + feet
            g.rect("#", 8, 15, 2)
            g.rect("#", 12, 15, 2)
            g.rect("#", 7, 16, 3)
            g.rect("#", 12, 16, 3)
            g.rect("#", 7, 17, 3)
            g.rect("#", 12, 17, 3)
            // tail wagging from back (right side)
            let ty = 11 + tailYOffset
            g.set("#", 16, ty)
            g.set("#", 17, ty - 1)
            g.set("#", 18, ty - 1)
            g.set("#", 19, ty - 2)
            return g
        }
        return ColorSprite(
            gridSize: SIZE, palette: palette,
            frames: [
                build(tailYOffset: 0, armUp: false).build(),
                build(tailYOffset: -2, armUp: true).build(),
                build(tailYOffset: 0, armUp: false).build(),
                build(tailYOffset: 2, armUp: true).build(),
            ]
        )
    }()

    // MARK: - Stage 4: Teen "Blazon"
    // Mohawk + horns + longer tail
    static let teen: ColorSprite = {
        func build(tailYOffset: Int, mohawkShift: Int) -> SpriteBuilder {
            var g = SpriteBuilder(size: SIZE)
            // mohawk crest
            let mx = 10 + mohawkShift
            g.set("#", mx, 0); g.set("#", mx + 1, 0)
            g.set("#", mx - 1, 1); g.set("#", mx + 2, 1)
            g.set("#", mx, 1); g.set("#", mx + 1, 1)
            g.set("#", mx, 2); g.set("#", mx + 1, 2)
            // horns
            g.set("#", 5, 2); g.set("#", 6, 3)
            g.set("#", 16, 2); g.set("#", 15, 3)
            // head
            g.rect("#", 7, 3, 8)
            g.rect("#", 6, 4, 10)
            g.rect("#", 5, 5, 12)
            g.rect("#", 5, 6, 12)
            g.rect("#", 5, 7, 12)
            g.rect("#", 6, 8, 10)
            // fierce eyes
            g.set(".", 8, 6); g.set(".", 9, 7)
            g.set(".", 13, 6); g.set(".", 12, 7)
            // snarl mouth
            g.rect(".", 10, 8, 2)
            // neck
            g.rect("#", 9, 9, 4)
            // body
            g.rect("#", 6, 10, 10)
            g.rect("#", 5, 11, 12)
            g.rect("#", 5, 12, 12)
            g.rect("#", 6, 13, 10)
            g.rect("#", 7, 14, 8)
            // arms at sides
            g.set("#", 4, 11); g.set("#", 4, 12)
            g.set("#", 17, 11); g.set("#", 17, 12)
            // legs
            g.rect("#", 7, 15, 2)
            g.rect("#", 13, 15, 2)
            g.rect("#", 6, 16, 3)
            g.rect("#", 13, 16, 3)
            g.rect("#", 6, 17, 3)
            g.rect("#", 13, 17, 3)
            // tail — longer, flame-tipped, wags
            let ty = 12 + tailYOffset
            g.set("#", 16, ty)
            g.set("#", 17, ty - 1)
            g.set("#", 18, ty - 1)
            g.set("#", 19, ty - 2)
            g.set("#", 20, ty - 2)
            g.set("#", 20, ty - 3)  // flame tip
            return g
        }
        return ColorSprite(
            gridSize: SIZE, palette: palette,
            frames: [
                build(tailYOffset: 0,  mohawkShift: 0).build(),
                build(tailYOffset: -2, mohawkShift: 1).build(),
                build(tailYOffset: 0,  mohawkShift: 0).build(),
                build(tailYOffset: 2,  mohawkShift: -1).build(),
            ]
        )
    }()

    // MARK: - Stage 5: Adult "Infernon"
    // Curved horns + folded wings + dragon tail
    static let adult: ColorSprite = {
        func build(tailYOffset: Int, wingFlap: Bool) -> SpriteBuilder {
            var g = SpriteBuilder(size: SIZE)
            // curved horns
            g.set("#", 5, 1); g.set("#", 4, 2); g.set("#", 5, 3)
            g.set("#", 16, 1); g.set("#", 17, 2); g.set("#", 16, 3)
            // head
            g.rect("#", 7, 3, 8)
            g.rect("#", 6, 4, 10)
            g.rect("#", 6, 5, 10)
            g.rect("#", 5, 6, 12)
            g.rect("#", 5, 7, 12)
            g.rect("#", 6, 8, 10)
            // eyes
            g.set(".", 8, 5); g.set(".", 8, 6)
            g.set(".", 13, 5); g.set(".", 13, 6)
            // snout
            g.set(".", 10, 8); g.set(".", 11, 8)
            // neck
            g.rect("#", 8, 9, 6)
            // wings (behind shoulders)
            if wingFlap {
                g.set("#", 2, 7); g.set("#", 2, 8); g.set("#", 1, 9); g.set("#", 2, 9); g.set("#", 3, 10)
                g.set("#", 19, 7); g.set("#", 19, 8); g.set("#", 19, 9); g.set("#", 20, 9); g.set("#", 18, 10)
            } else {
                g.set("#", 3, 9); g.set("#", 2, 10); g.set("#", 3, 10); g.set("#", 3, 11); g.set("#", 4, 11)
                g.set("#", 18, 9); g.set("#", 19, 10); g.set("#", 18, 10); g.set("#", 18, 11); g.set("#", 17, 11)
            }
            // body
            g.rect("#", 5, 10, 12)
            g.rect("#", 4, 11, 14)
            g.rect("#", 5, 12, 12)
            g.rect("#", 5, 13, 12)
            g.rect("#", 6, 14, 10)
            // legs
            g.rect("#", 7, 15, 2)
            g.rect("#", 13, 15, 2)
            g.rect("#", 6, 16, 3)
            g.rect("#", 13, 16, 3)
            g.rect("#", 6, 17, 3)
            g.rect("#", 13, 17, 3)
            g.rect("#", 5, 18, 4)
            g.rect("#", 13, 18, 4)
            // dragon tail — long, wags
            let ty = 12 + tailYOffset
            g.set("#", 17, ty)
            g.set("#", 18, ty - 1)
            g.set("#", 19, ty - 1)
            g.set("#", 20, ty - 2)
            g.set("#", 20, ty - 3)
            return g
        }
        return ColorSprite(
            gridSize: SIZE, palette: palette,
            frames: [
                build(tailYOffset: 0,  wingFlap: false).build(),
                build(tailYOffset: -2, wingFlap: true).build(),
                build(tailYOffset: 0,  wingFlap: false).build(),
                build(tailYOffset: 2,  wingFlap: true).build(),
            ]
        )
    }()

    // MARK: - Stage 6: Ultimate "Phoenignis"
    // Flame crown + spread wings + majestic tail
    static let ultimate: ColorSprite = {
        func build(tailYOffset: Int, wingsUp: Bool, crownFlicker: Bool) -> SpriteBuilder {
            var g = SpriteBuilder(size: SIZE)
            // flame crown — three peaks
            if crownFlicker {
                g.set("#", 5, 1); g.set("#", 10, 0); g.set("#", 11, 0); g.set("#", 16, 1)
                g.set("#", 5, 2); g.set("#", 10, 1); g.set("#", 11, 1); g.set("#", 16, 2)
            } else {
                g.set("#", 5, 0); g.set("#", 10, 1); g.set("#", 11, 1); g.set("#", 16, 0)
                g.set("#", 5, 1); g.set("#", 10, 2); g.set("#", 11, 2); g.set("#", 16, 1)
            }
            g.set("#", 5, 3); g.set("#", 10, 3); g.set("#", 11, 3); g.set("#", 16, 3)
            // head
            g.rect("#", 7, 4, 8)
            g.rect("#", 6, 5, 10)
            g.rect("#", 6, 6, 10)
            g.rect("#", 6, 7, 10)
            g.rect("#", 7, 8, 8)
            // piercing eyes
            g.set(".", 8, 6); g.set(".", 13, 6)
            // mouth
            g.set(".", 10, 8); g.set(".", 11, 8)
            // wings — FULL wingspan
            if wingsUp {
                // up stroke
                g.set("#", 3, 4); g.set("#", 2, 5); g.set("#", 1, 6); g.set("#", 0, 7)
                g.set("#", 3, 5); g.set("#", 2, 6); g.set("#", 1, 7); g.set("#", 1, 8)
                g.set("#", 3, 6); g.set("#", 2, 7); g.set("#", 2, 8)
                g.set("#", 3, 7); g.set("#", 3, 8); g.set("#", 4, 9)
                g.set("#", 18, 4); g.set("#", 19, 5); g.set("#", 20, 6); g.set("#", 21, 7)
                g.set("#", 18, 5); g.set("#", 19, 6); g.set("#", 20, 7); g.set("#", 20, 8)
                g.set("#", 18, 6); g.set("#", 19, 7); g.set("#", 19, 8)
                g.set("#", 18, 7); g.set("#", 18, 8); g.set("#", 17, 9)
            } else {
                // down stroke
                g.set("#", 3, 9); g.set("#", 2, 10); g.set("#", 1, 11); g.set("#", 0, 12)
                g.set("#", 3, 10); g.set("#", 2, 11); g.set("#", 1, 12); g.set("#", 2, 12)
                g.set("#", 3, 11); g.set("#", 4, 11); g.set("#", 3, 12)
                g.set("#", 18, 9); g.set("#", 19, 10); g.set("#", 20, 11); g.set("#", 21, 12)
                g.set("#", 18, 10); g.set("#", 19, 11); g.set("#", 20, 12); g.set("#", 19, 12)
                g.set("#", 18, 11); g.set("#", 17, 11); g.set("#", 18, 12)
            }
            // neck + body
            g.rect("#", 9, 9, 4)
            g.rect("#", 6, 10, 10)
            g.rect("#", 5, 11, 12)
            g.rect("#", 5, 12, 12)
            g.rect("#", 6, 13, 10)
            g.rect("#", 6, 14, 10)
            // chest orb (empty hole)
            g.set(".", 10, 12); g.set(".", 11, 12)
            // legs
            g.rect("#", 7, 15, 2)
            g.rect("#", 13, 15, 2)
            g.rect("#", 6, 16, 3)
            g.rect("#", 13, 16, 3)
            g.rect("#", 6, 17, 3)
            g.rect("#", 13, 17, 3)
            g.rect("#", 5, 18, 4)
            g.rect("#", 13, 18, 4)
            // majestic tail
            let ty = 13 + tailYOffset
            g.set("#", 17, ty)
            g.set("#", 18, ty - 1)
            g.set("#", 19, ty - 1)
            g.set("#", 20, ty - 2)
            g.set("#", 20, ty - 3)
            g.set("#", 21, ty - 3)
            return g
        }
        return ColorSprite(
            gridSize: SIZE, palette: palette,
            frames: [
                build(tailYOffset: 0,  wingsUp: true,  crownFlicker: false).build(),
                build(tailYOffset: -2, wingsUp: false, crownFlicker: true).build(),
                build(tailYOffset: 0,  wingsUp: true,  crownFlicker: false).build(),
                build(tailYOffset: 2,  wingsUp: false, crownFlicker: true).build(),
            ]
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
