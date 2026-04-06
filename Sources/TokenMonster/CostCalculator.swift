import Foundation

/// Per-1M-token prices in USD (Anthropic public pricing, rough).
enum CostCalculator {
    struct Rate { let input: Double; let output: Double; let cacheWrite: Double; let cacheRead: Double }

    private static func rate(for model: String) -> Rate {
        let m = model.lowercased()
        if m.contains("opus")   { return Rate(input: 15, output: 75, cacheWrite: 18.75, cacheRead: 1.50) }
        if m.contains("sonnet") { return Rate(input: 3,  output: 15, cacheWrite: 3.75,  cacheRead: 0.30) }
        if m.contains("haiku")  { return Rate(input: 0.80, output: 4, cacheWrite: 1.00, cacheRead: 0.08) }
        return Rate(input: 3, output: 15, cacheWrite: 3.75, cacheRead: 0.30) // default → Sonnet
    }

    static func cost(model: String, input: Int, output: Int, cacheCreate: Int, cacheRead: Int) -> Double {
        let r = rate(for: model)
        return (Double(input)       * r.input
              + Double(output)      * r.output
              + Double(cacheCreate) * r.cacheWrite
              + Double(cacheRead)   * r.cacheRead) / 1_000_000
    }
}
