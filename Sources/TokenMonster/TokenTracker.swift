import Foundation

enum BallTier: Int {
    case monster = 0, superBall = 1, hyper = 2
}

struct WeeklyProject {
    let name: String
    let weeklyTokens: Int64
    let tier: BallTier
}

struct UsageSnapshot {
    let totalTokens: Int64        // since baseline
    let todayTokens: Int64
    let tokensPerMinute: Double
    let projects: [(name: String, tokens: Int64)]   // lifetime
    let weeklyProjects: [WeeklyProject]             // last 7 days, ranked
    let stage: Stage
    let totalCostUSD: Double
}

final class TokenTracker {
    var onUpdate: ((UsageSnapshot) -> Void)?
    var onEvolution: ((Stage, Stage) -> Void)?  // (from, to)
    private var lastKnownStage: Stage = .egg

    private let claudeRoot: URL
    private var fileOffsets: [String: UInt64] = [:]
    private var projectTotals: [String: Int64] = [:]
    // weekly: project -> day-key (yyyy-MM-dd) -> tokens
    private var projectDaily: [String: [String: Int64]] = [:]
    private var totalCostUSD: Double = 0

    private static let dayKeyFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone.current
        return f
    }()
    private static let iso8601Parser: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    private static let iso8601ParserNoMs: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()
    private static func parseDate(_ s: String) -> Date? {
        iso8601Parser.date(from: s) ?? iso8601ParserNoMs.date(from: s)
    }
    private var todayTokens: Int64 = 0
    private var todayDate: String = TokenTracker.todayKey()
    private var recentBuckets: [(time: Date, tokens: Int64)] = []
    private var timer: Timer?
    private var didInitialScan = false

    private let stateURL: URL = {
        let dir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/TokenMonster")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("state.json")
    }()
    private var _baseline: Int64?
    private var forceBonus: Int64 = 0
    private var hasBaseline: Bool { _baseline != nil }
    private var baseline: Int64 {
        get { _baseline ?? 0 }
        set { _baseline = newValue; saveState() }
    }
    private func loadState() {
        guard let data = try? Data(contentsOf: stateURL),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
        if let b = obj["baseline"] as? Int { _baseline = Int64(b) }
        if let s = obj["stage"] as? Int, let stage = Stage(rawValue: s) { lastKnownStage = stage }
        if let f = obj["forceBonus"] as? Int { forceBonus = Int64(f) }
    }
    private func saveState() {
        let obj: [String: Any] = [
            "baseline": Int(_baseline ?? 0),
            "stage": lastKnownStage.rawValue,
            "forceBonus": Int(forceBonus),
        ]
        if let data = try? JSONSerialization.data(withJSONObject: obj) {
            try? data.write(to: stateURL)
        }
    }

    init() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        self.claudeRoot = home.appendingPathComponent(".claude/projects")
        loadState()
    }

    /// Re-hatches: current absolute total becomes the new zero point.
    /// Debug: push forceBonus so the next stage threshold is immediately met.
    func forceEvolveNextStage() {
        let absolute = projectTotals.values.reduce(0, +)
        let current = max(0, absolute - baseline) + forceBonus
        guard let next = Stage(rawValue: lastKnownStage.rawValue + 1) else { return }
        if current < next.threshold {
            forceBonus += (next.threshold - current)
        }
        saveState()
        publish(addedNow: 0)
    }

    func resetBaseline() {
        let absolute = projectTotals.values.reduce(0, +)
        baseline = absolute
        forceBonus = 0
        todayTokens = 0
        recentBuckets.removeAll()
        lastKnownStage = .egg
        saveState()
        publish(addedNow: 0)
    }

    func start() {
        scan()
        let t = Timer(timeInterval: 5, repeats: true) { [weak self] _ in self?.scan() }
        timer = t
        RunLoop.main.add(t, forMode: .common)
    }

    private func scan() {
        let initial = !didInitialScan
        defer { didInitialScan = true }

        let fm = FileManager.default
        guard fm.fileExists(atPath: claudeRoot.path) else {
            publish(addedNow: 0)
            return
        }

        var addedThisTick: Int64 = 0
        let projects = (try? fm.contentsOfDirectory(at: claudeRoot, includingPropertiesForKeys: nil)) ?? []
        for proj in projects {
            var isDir: ObjCBool = false
            fm.fileExists(atPath: proj.path, isDirectory: &isDir)
            guard isDir.boolValue else { continue }

            let files = (try? fm.contentsOfDirectory(at: proj, includingPropertiesForKeys: nil)) ?? []
            for f in files where f.pathExtension == "jsonl" {
                addedThisTick += readIncrement(file: f, projectName: proj.lastPathComponent)
            }
        }

        let key = TokenTracker.todayKey()
        if key != todayDate { todayDate = key; todayTokens = 0 }

        if initial {
            // don't count the historical catch-up as "just now"; reset today too
            todayTokens = 0
            if !hasBaseline {
                baseline = projectTotals.values.reduce(0, +)
            }
            publish(addedNow: 0)
        } else {
            todayTokens += addedThisTick
            publish(addedNow: addedThisTick)
        }
    }

    private func readIncrement(file: URL, projectName: String) -> Int64 {
        let path = file.path
        let attrs = try? FileManager.default.attributesOfItem(atPath: path)
        let size = (attrs?[.size] as? UInt64) ?? 0
        let start = fileOffsets[path] ?? 0
        guard size > start else { return 0 }

        guard let handle = try? FileHandle(forReadingFrom: file) else { return 0 }
        defer { try? handle.close() }

        do { try handle.seek(toOffset: start) } catch { return 0 }
        let data = handle.readDataToEndOfFile()
        fileOffsets[path] = size

        guard let text = String(data: data, encoding: .utf8) else { return 0 }
        var added: Int64 = 0
        for line in text.split(separator: "\n") {
            guard let d = line.data(using: .utf8),
                  let obj = try? JSONSerialization.jsonObject(with: d) as? [String: Any],
                  let message = obj["message"] as? [String: Any],
                  let usage = message["usage"] as? [String: Any] else { continue }
            let model = (message["model"] as? String) ?? ""
            let inT  = (usage["input_tokens"]  as? Int) ?? 0
            let outT = (usage["output_tokens"] as? Int) ?? 0
            let cC   = (usage["cache_creation_input_tokens"] as? Int) ?? 0
            let cR   = (usage["cache_read_input_tokens"]     as? Int) ?? 0
            let total = Int64(inT + outT + cC + cR)
            added += total
            projectTotals[projectName, default: 0] += total
            totalCostUSD += CostCalculator.cost(
                model: model, input: inT, output: outT, cacheCreate: cC, cacheRead: cR
            )

            // weekly bucket — parse entry timestamp
            if let ts = obj["timestamp"] as? String, let date = Self.parseDate(ts) {
                let key = Self.dayKeyFormatter.string(from: date)
                projectDaily[projectName, default: [:]][key, default: 0] += total
            }
        }
        return added
    }

    private let activityWindowSec: TimeInterval = 15

    private func publish(addedNow: Int64) {
        let now = Date()
        if addedNow > 0 { recentBuckets.append((now, addedNow)) }
        recentBuckets.removeAll { now.timeIntervalSince($0.time) > activityWindowSec }
        // Normalize "tokens in the last N seconds" to a per-minute rate.
        let tokensInWindow = recentBuckets.reduce(0) { $0 + $1.tokens }
        let tpm = Double(tokensInWindow) * (60.0 / activityWindowSec)

        let absoluteTotal = projectTotals.values.reduce(0, +)
        let monsterTotal = max(0, absoluteTotal - baseline) + forceBonus
        let sorted = projectTotals
            .map { (name: TokenTracker.prettyName($0.key), tokens: $0.value) }
            .sorted { $0.tokens > $1.tokens }

        // weekly: collect days within last 7
        let dayFmt = Self.dayKeyFormatter
        let today = Date()
        let cal = Calendar.current
        var validDayKeys = Set<String>()
        for i in 0..<7 {
            if let d = cal.date(byAdding: .day, value: -i, to: today) {
                validDayKeys.insert(dayFmt.string(from: d))
            }
        }
        var weeklyRaw: [(String, Int64)] = []
        for (proj, days) in projectDaily {
            let sum = days.filter { validDayKeys.contains($0.key) }
                          .values.reduce(0, +)
            if sum > 0 {
                weeklyRaw.append((TokenTracker.prettyName(proj), sum))
            }
        }
        weeklyRaw.sort { $0.1 > $1.1 }
        let weeklyProjects: [WeeklyProject] = weeklyRaw.map { entry in
            let tier = Self.tier(for: entry.1)
            return WeeklyProject(name: entry.0, weeklyTokens: entry.1, tier: tier)
        }

        let newStage = Stage.from(totalTokens: monsterTotal)
        onUpdate?(UsageSnapshot(
            totalTokens: monsterTotal,
            todayTokens: todayTokens,
            tokensPerMinute: tpm,
            projects: sorted,
            weeklyProjects: weeklyProjects,
            stage: newStage,
            totalCostUSD: totalCostUSD
        ))
        if newStage.rawValue > lastKnownStage.rawValue {
            let from = lastKnownStage
            lastKnownStage = newStage
            saveState()
            onEvolution?(from, newStage)
        } else if newStage != lastKnownStage {
            lastKnownStage = newStage
            saveState()
        }
    }

    private static func todayKey() -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    private static func prettyName(_ raw: String) -> String {
        raw.split(separator: "-").last.map(String.init) ?? raw
    }

    /// Weekly-tokens → ball tier thresholds.
    private static func tier(for weekly: Int64) -> BallTier {
        switch weekly {
        case ..<5_000_000:           return .monster    // < 5M/week
        case 5_000_000..<20_000_000: return .superBall  // 5M–20M/week
        default:                     return .hyper      // ≥ 20M/week
        }
    }
}
