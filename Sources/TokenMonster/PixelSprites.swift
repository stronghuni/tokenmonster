import Foundation

/// 22x22 pixel grids. 1 = filled, 0 = empty.
/// Coordinates: (x,y) where x=0 is left, y=0 is top (SVG convention).
/// The renderer flips vertically for NSImage.
///
/// Design reference: Digimon V-Pet 16x16 B/W sprites — strong silhouette,
/// solid fill with small negative-space holes for features, progressive
/// silhouette complexity per evolution stage.
enum PixelSprites {

    // MARK: - Helpers
    private static func blank() -> [[Int]] {
        Array(repeating: Array(repeating: 0, count: 22), count: 22)
    }
    private static func fill(_ g: inout [[Int]], _ x: Int, _ y: Int, _ w: Int = 1, _ h: Int = 1) {
        for dy in 0..<h { for dx in 0..<w {
            guard y+dy >= 0, y+dy < 22, x+dx >= 0, x+dx < 22 else { continue }
            g[y+dy][x+dx] = 1
        }}
    }
    private static func clear(_ g: inout [[Int]], _ x: Int, _ y: Int, _ w: Int = 1, _ h: Int = 1) {
        for dy in 0..<h { for dx in 0..<w {
            guard y+dy >= 0, y+dy < 22, x+dx >= 0, x+dx < 22 else { continue }
            g[y+dy][x+dx] = 0
        }}
    }

    // MARK: - Stage 1: Egg
    static let eggA: [[Int]] = {
        var g = blank()
        fill(&g, 9,3,4); fill(&g, 8,4,6); fill(&g, 7,5,8); fill(&g, 6,6,10)
        fill(&g, 5,7,12,2); fill(&g, 4,9,14,7); fill(&g, 5,16,12)
        fill(&g, 6,17,10); fill(&g, 7,18,8)
        // fire-spot holes
        clear(&g, 8,10,2,2); clear(&g, 9,9)
        clear(&g, 12,12,2,2); clear(&g, 13,11)
        clear(&g, 8,14); clear(&g, 13,15)
        return g
    }()

    // MARK: - Stage 2: Baby "Flamkin"
    // Round blob + single tall flame tuft + 2-dot eyes + tiny feet
    static let babyA: [[Int]] = {
        var g = blank()
        // flame tuft (pointy)
        fill(&g, 10,1,2); fill(&g, 9,2); fill(&g, 12,2); fill(&g, 10,3,2); fill(&g, 10,4,2)
        // round body
        fill(&g, 7,5,8); fill(&g, 6,6,10); fill(&g, 5,7,12,2)
        fill(&g, 4,9,14,6); fill(&g, 5,15,12); fill(&g, 6,16,10)
        fill(&g, 7,17,8)
        // feet
        fill(&g, 6,18,2); fill(&g, 14,18,2)
        fill(&g, 5,19,3); fill(&g, 14,19,3)
        // eye holes (2px each)
        clear(&g, 8,10,2,2); clear(&g, 12,10,2,2)
        // mouth
        clear(&g, 10,13,2)
        return g
    }()
    static let babyB: [[Int]] = {
        var g = blank()
        // flame tuft leans right + bob down 1px
        fill(&g, 11,1,2); fill(&g, 10,2); fill(&g, 13,2); fill(&g, 11,3,2); fill(&g, 10,4,2)
        fill(&g, 7,6,8); fill(&g, 6,7,10); fill(&g, 5,8,12,2)
        fill(&g, 4,10,14,5); fill(&g, 5,15,12); fill(&g, 6,16,10)
        fill(&g, 7,17,8)
        fill(&g, 6,18,2); fill(&g, 14,18,2)
        fill(&g, 5,19,3); fill(&g, 14,19,3)
        // eyes closed (1px)
        clear(&g, 8,11); clear(&g, 13,11)
        // mouth open (2x2)
        clear(&g, 10,13,2,2)
        return g
    }()

    // MARK: - Stage 3: Child "Flamon"
    // Bipedal, two horn-tufts, small arms, sturdy legs
    static let childA: [[Int]] = {
        var g = blank()
        // two horn flame tufts
        fill(&g, 6,1); fill(&g, 7,2); fill(&g, 8,3)
        fill(&g, 15,1); fill(&g, 14,2); fill(&g, 13,3)
        // head
        fill(&g, 7,3,8); fill(&g, 6,4,10); fill(&g, 5,5,12)
        fill(&g, 5,6,12); fill(&g, 5,7,12); fill(&g, 6,8,10)
        // eye holes
        clear(&g, 8,6,2); clear(&g, 12,6,2)
        // mouth
        clear(&g, 10,8,2)
        // neck
        fill(&g, 9,9,4)
        // body (shoulders wide, arms out)
        fill(&g, 6,10,10); fill(&g, 5,11,12); fill(&g, 5,12,12)
        fill(&g, 6,13,10); fill(&g, 6,14,10); fill(&g, 7,15,8)
        // legs
        fill(&g, 7,16,2); fill(&g, 13,16,2)
        fill(&g, 7,17,2); fill(&g, 13,17,2)
        fill(&g, 6,18,3); fill(&g, 13,18,3)
        fill(&g, 6,19,3); fill(&g, 13,19,3)
        return g
    }()
    static let childB: [[Int]] = {
        var g = blank()
        // flames flicker
        fill(&g, 6,2); fill(&g, 7,1); fill(&g, 8,2)
        fill(&g, 15,2); fill(&g, 14,1); fill(&g, 13,2)
        fill(&g, 7,3,8); fill(&g, 6,4,10); fill(&g, 5,5,12)
        fill(&g, 5,6,12); fill(&g, 5,7,12); fill(&g, 6,8,10)
        clear(&g, 8,6); clear(&g, 13,6) // blink
        clear(&g, 10,8,2,2) // mouth open
        fill(&g, 9,9,4)
        fill(&g, 6,10,10); fill(&g, 5,11,12); fill(&g, 5,12,12)
        fill(&g, 6,13,10); fill(&g, 6,14,10); fill(&g, 7,15,8)
        // legs shifted slightly (walk)
        fill(&g, 6,16,2); fill(&g, 14,16,2)
        fill(&g, 6,17,2); fill(&g, 14,17,2)
        fill(&g, 5,18,3); fill(&g, 14,18,3)
        fill(&g, 5,19,3); fill(&g, 14,19,3)
        return g
    }()

    // MARK: - Stage 4: Teen "Blazon"
    // Bipedal + forward-angled pointy horns + visible tail swishing out to the right
    static let teenA: [[Int]] = {
        var g = blank()
        // forward horns (tips at the top corners of head area)
        fill(&g, 4,0); fill(&g, 5,1); fill(&g, 6,2); fill(&g, 7,3)
        fill(&g, 17,0); fill(&g, 16,1); fill(&g, 15,2); fill(&g, 14,3)
        // head
        fill(&g, 7,3,8); fill(&g, 6,4,10); fill(&g, 5,5,12)
        fill(&g, 5,6,12); fill(&g, 5,7,12); fill(&g, 6,8,10)
        clear(&g, 7,6,2); clear(&g, 13,6,2)   // fierce eyes
        clear(&g, 10,8,2)                     // fanged mouth
        // neck
        fill(&g, 8,9,6)
        // shoulders + arms reaching wide
        fill(&g, 5,10,12); fill(&g, 3,11,16)
        // torso
        fill(&g, 5,12,12); fill(&g, 5,13,12); fill(&g, 6,14,10)
        // tail curling right
        fill(&g, 16,12,2); fill(&g, 18,13,2); fill(&g, 19,14,2); fill(&g, 20,13)
        // legs (slightly apart)
        fill(&g, 7,15,3); fill(&g, 12,15,3)
        fill(&g, 7,16,3); fill(&g, 12,16,3)
        fill(&g, 7,17,3); fill(&g, 12,17,3)
        // feet
        fill(&g, 6,18,5); fill(&g, 12,18,5)
        fill(&g, 6,19,5); fill(&g, 12,19,5)
        return g
    }()
    static let teenB: [[Int]] = {
        var g = blank()
        fill(&g, 4,1); fill(&g, 5,2); fill(&g, 6,3); fill(&g, 7,4)
        fill(&g, 17,1); fill(&g, 16,2); fill(&g, 15,3); fill(&g, 14,4)
        fill(&g, 7,4,8); fill(&g, 6,5,10); fill(&g, 5,6,12)
        fill(&g, 5,7,12); fill(&g, 5,8,12); fill(&g, 6,9,10)
        clear(&g, 8,7); clear(&g, 13,7)       // blink (1px)
        clear(&g, 10,9,2,2)                   // mouth open
        fill(&g, 8,10,6)
        fill(&g, 5,11,12); fill(&g, 3,12,16)
        fill(&g, 5,13,12); fill(&g, 5,14,12); fill(&g, 6,15,10)
        // tail swish (different pose)
        fill(&g, 16,13,2); fill(&g, 18,12,2); fill(&g, 19,13,2); fill(&g, 20,14)
        fill(&g, 7,16,3); fill(&g, 12,16,3)
        fill(&g, 7,17,3); fill(&g, 12,17,3)
        fill(&g, 6,18,5); fill(&g, 12,18,5)
        fill(&g, 6,19,5); fill(&g, 12,19,5)
        return g
    }()

    // MARK: - Stage 5: Adult "Infernon"
    // Folded dragon wings rising beside the head (tall triangles) + large curved horns
    static let adultA: [[Int]] = {
        var g = blank()
        // curved horns above head
        fill(&g, 6,0); fill(&g, 6,1); fill(&g, 7,2)
        fill(&g, 15,0); fill(&g, 15,1); fill(&g, 14,2)
        // folded wings as tall triangles on both sides (col 0-4 left, 17-21 right)
        fill(&g, 3,3,2); fill(&g, 2,4,3); fill(&g, 1,5,4); fill(&g, 0,6,5); fill(&g, 0,7,5)
        fill(&g, 1,8,4); fill(&g, 2,9,3)
        fill(&g, 17,3,2); fill(&g, 17,4,3); fill(&g, 17,5,4); fill(&g, 17,6,5); fill(&g, 17,7,5)
        fill(&g, 17,8,4); fill(&g, 17,9,3)
        // head (centered)
        fill(&g, 8,3,6); fill(&g, 7,4,8); fill(&g, 6,5,10)
        fill(&g, 6,6,10); fill(&g, 6,7,10); fill(&g, 7,8,8)
        clear(&g, 8,6,2); clear(&g, 12,6,2)   // eyes
        clear(&g, 10,8,2)                     // mouth
        // neck
        fill(&g, 8,9,6)
        // shoulders broad
        fill(&g, 5,10,12); fill(&g, 4,11,14)
        // body
        fill(&g, 5,12,12); fill(&g, 5,13,12); fill(&g, 6,14,10)
        // tail
        fill(&g, 16,13,2); fill(&g, 18,14,2); fill(&g, 19,15,2); fill(&g, 20,14)
        // legs thick
        fill(&g, 6,15,3); fill(&g, 13,15,3)
        fill(&g, 6,16,3); fill(&g, 13,16,3)
        fill(&g, 6,17,3); fill(&g, 13,17,3)
        fill(&g, 5,18,5); fill(&g, 13,18,5)
        fill(&g, 5,19,5); fill(&g, 13,19,5)
        return g
    }()
    static let adultB: [[Int]] = {
        var g = blank()
        fill(&g, 6,0); fill(&g, 7,1); fill(&g, 7,2)
        fill(&g, 15,0); fill(&g, 14,1); fill(&g, 14,2)
        // wings flap outward slightly (1 wider)
        fill(&g, 3,3,2); fill(&g, 1,4,4); fill(&g, 0,5,5); fill(&g, 0,6,5); fill(&g, 0,7,5)
        fill(&g, 0,8,5); fill(&g, 1,9,4)
        fill(&g, 17,3,2); fill(&g, 17,4,4); fill(&g, 17,5,5); fill(&g, 17,6,5); fill(&g, 17,7,5)
        fill(&g, 17,8,5); fill(&g, 17,9,4)
        fill(&g, 8,3,6); fill(&g, 7,4,8); fill(&g, 6,5,10)
        fill(&g, 6,6,10); fill(&g, 6,7,10); fill(&g, 7,8,8)
        clear(&g, 9,6); clear(&g, 13,6)       // blink
        clear(&g, 10,8,2,2)                   // mouth open
        fill(&g, 8,9,6)
        fill(&g, 5,10,12); fill(&g, 4,11,14)
        fill(&g, 5,12,12); fill(&g, 5,13,12); fill(&g, 6,14,10)
        fill(&g, 16,12,2); fill(&g, 18,13,2); fill(&g, 20,14); fill(&g, 19,14,2)
        fill(&g, 6,15,3); fill(&g, 13,15,3)
        fill(&g, 6,16,3); fill(&g, 13,16,3)
        fill(&g, 6,17,3); fill(&g, 13,17,3)
        fill(&g, 5,18,5); fill(&g, 13,18,5)
        fill(&g, 5,19,5); fill(&g, 13,19,5)
        return g
    }()

    // MARK: - Stage 6: Ultimate "Phoenignis"
    // Full wingspan (fills canvas width), flame crown, commanding pose
    static let ultimateA: [[Int]] = {
        var g = blank()
        // flame crown — three points
        fill(&g, 7,0); fill(&g, 10,0,2); fill(&g, 14,0)
        fill(&g, 7,1,2); fill(&g, 10,1,2); fill(&g, 13,1,2)
        fill(&g, 8,2,6)
        // head
        fill(&g, 8,3,6); fill(&g, 7,4,8); fill(&g, 7,5,8); fill(&g, 7,6,8)
        clear(&g, 8,5,2); clear(&g, 12,5,2)   // eyes
        clear(&g, 10,6,2)                     // mouth
        // full wingspan trailing edges (upper)
        fill(&g, 0,4,2); fill(&g, 0,5,3); fill(&g, 0,6,4); fill(&g, 0,7,5); fill(&g, 0,8,5)
        fill(&g, 20,4,2); fill(&g, 19,5,3); fill(&g, 18,6,4); fill(&g, 17,7,5); fill(&g, 17,8,5)
        // lower wing trailing
        fill(&g, 1,9,4); fill(&g, 17,9,4)
        fill(&g, 2,10,3); fill(&g, 17,10,3)
        // shoulders + chest
        fill(&g, 7,7,8); fill(&g, 6,8,10); fill(&g, 5,9,12)
        fill(&g, 5,10,12); fill(&g, 4,11,14)
        // body
        fill(&g, 5,12,12); fill(&g, 5,13,12); fill(&g, 6,14,10); fill(&g, 6,15,10)
        // tail flame trailing right
        fill(&g, 16,14,2); fill(&g, 18,15,2); fill(&g, 19,16,2); fill(&g, 20,17)
        // legs powerful
        fill(&g, 6,16,3); fill(&g, 13,16,3)
        fill(&g, 6,17,3); fill(&g, 13,17,3)
        fill(&g, 5,18,4); fill(&g, 13,18,4)
        fill(&g, 5,19,4); fill(&g, 13,19,4)
        fill(&g, 4,20,5); fill(&g, 13,20,5)
        fill(&g, 4,21,5); fill(&g, 13,21,5)
        return g
    }()
    static let ultimateB: [[Int]] = {
        var g = blank()
        // crown flicker
        fill(&g, 7,1); fill(&g, 10,1,2); fill(&g, 14,1)
        fill(&g, 7,2,2); fill(&g, 10,2,2); fill(&g, 13,2,2)
        fill(&g, 8,3,6)
        fill(&g, 8,4,6); fill(&g, 7,5,8); fill(&g, 7,6,8); fill(&g, 7,7,8)
        clear(&g, 9,6); clear(&g, 12,6)       // blink
        clear(&g, 10,7,2,2)                   // mouth open
        // wings flap up (higher)
        fill(&g, 0,3,2); fill(&g, 0,4,3); fill(&g, 0,5,4); fill(&g, 0,6,5); fill(&g, 0,7,5)
        fill(&g, 20,3,2); fill(&g, 19,4,3); fill(&g, 18,5,4); fill(&g, 17,6,5); fill(&g, 17,7,5)
        fill(&g, 1,8,4); fill(&g, 17,8,4)
        fill(&g, 2,9,3); fill(&g, 17,9,3)
        fill(&g, 7,8,8); fill(&g, 6,9,10); fill(&g, 5,10,12)
        fill(&g, 5,11,12); fill(&g, 4,12,14)
        fill(&g, 5,13,12); fill(&g, 5,14,12); fill(&g, 6,15,10); fill(&g, 6,16,10)
        fill(&g, 16,15,2); fill(&g, 18,14,2); fill(&g, 19,15,2); fill(&g, 20,16)
        fill(&g, 6,17,3); fill(&g, 13,17,3)
        fill(&g, 6,18,3); fill(&g, 13,18,3)
        fill(&g, 5,19,4); fill(&g, 13,19,4)
        fill(&g, 5,20,4); fill(&g, 13,20,4)
        fill(&g, 4,21,5); fill(&g, 13,21,5)
        return g
    }()
}
