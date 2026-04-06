import Cocoa

if CommandLine.arguments.contains("--export-previews") {
    PreviewExporter.run()
    exit(0)
}
if CommandLine.arguments.contains("--render-dashboard") {
    _ = NSApplication.shared
    let view = DashboardView()
    view.frame = NSRect(x: 0, y: 0, width: 560, height: 480)
    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor(white: 0.12, alpha: 1).cgColor
    view.layer?.cornerRadius = 18
    let fake = UsageSnapshot(
        totalTokens: 45_200_000,
        todayTokens: 3_421_000,
        tokensPerMinute: 4_200,
        projects: [],
        weeklyProjects: [
            WeeklyProject(name: "marry",       weeklyTokens: 24_500_000, tier: .hyper),
            WeeklyProject(name: "api",         weeklyTokens: 12_800_000, tier: .hyper),
            WeeklyProject(name: "main",        weeklyTokens:  5_200_000, tier: .superBall),
            WeeklyProject(name: "megaharness", weeklyTokens:  1_900_000, tier: .superBall),
            WeeklyProject(name: "monster",     weeklyTokens:    640_000, tier: .monster),
            WeeklyProject(name: "playground",  weeklyTokens:    120_000, tier: .monster),
        ],
        stage: .child,
        totalCostUSD: 128.45
    )
    view.apply(snapshot: fake, quote: "용기는 무모하게 달려드는 게 아니야. 두려움을 이겨내고 친구를 위해 나서는 마음이야")
    RunLoop.main.run(until: Date().addingTimeInterval(0.5))
    let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds)!
    view.cacheDisplay(in: view.bounds, to: rep)
    if let png = rep.representation(using: .png, properties: [:]) {
        try? png.write(to: URL(fileURLWithPath: "samples/dashboard.png"))
        print("dashboard saved to samples/dashboard.png")
    }
    exit(0)
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
