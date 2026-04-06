import Foundation

struct UsageSnapshot {
    let totalTokens: Int64        // since baseline
    let todayTokens: Int64
    let tokensPerMinute: Double
    let projects: [(name: String, tokens: Int64)]
    let stage: Stage
    let totalCostUSD: Double      // lifetime (absolute) cost estimate
}

final class TokenTracker {
    var onUpdate: ((UsageSnapshot) -> Void)?
    var onEvolution: ((Stage, Stage) -> Void)?  // (from, to)
    private var lastKnownStage: Stage = .egg

    private let claudeRoot: URL
    private var fileOffsets: [String: UInt64] = [:]
    private var projectTotals: [String: Int64] = [:]
    private var totalCostUSD: Double = 0
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
    }
    private func saveState() {
        let obj: [String: Any] = [
            "baseline": Int(_baseline ?? 0),
            "stage": lastKnownStage.rawValue,
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
    /// Debug: artificially lower the baseline to trigger the next stage.
    func forceEvolveNextStage() {
        let absolute = projectTotals.values.reduce(0, +)
        guard let next = Stage(rawValue: lastKnownStage.rawValue + 1) else { return }
        let need = next.threshold
        // set baseline so that (absolute - baseline) == need
        baseline = max(0, absolute - need)
        saveState()
        publish(addedNow: 0)
    }

    func resetBaseline() {
        let absolute = projectTotals.values.reduce(0, +)
        baseline = absolute
        todayTokens = 0
        recentBuckets.removeAll()
        lastKnownStage = .egg
        saveState()
        publish(addedNow: 0)
    }

    func start() {
        scan()
        let t = Timer(timeInterval: 10, repeats: true) { [weak self] _ in self?.scan() }
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
        }
        return added
    }

    private func publish(addedNow: Int64) {
        let now = Date()
        if addedNow > 0 { recentBuckets.append((now, addedNow)) }
        recentBuckets.removeAll { now.timeIntervalSince($0.time) > 60 }
        let tpm = Double(recentBuckets.reduce(0) { $0 + $1.tokens })

        let absoluteTotal = projectTotals.values.reduce(0, +)
        let monsterTotal = max(0, absoluteTotal - baseline)
        let sorted = projectTotals
            .map { (name: TokenTracker.prettyName($0.key), tokens: $0.value) }
            .sorted { $0.tokens > $1.tokens }

        let newStage = Stage.from(totalTokens: monsterTotal)
        onUpdate?(UsageSnapshot(
            totalTokens: monsterTotal,
            todayTokens: todayTokens,
            tokensPerMinute: tpm,
            projects: sorted,
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
}
