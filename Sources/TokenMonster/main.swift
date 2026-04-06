import Cocoa

if CommandLine.arguments.contains("--export-previews") {
    PreviewExporter.run()
    exit(0)
}
if CommandLine.arguments.contains("--render-dashboard") {
    _ = NSApplication.shared
    let dash = DashboardWindowController()
    let fake = UsageSnapshot(
        totalTokens: 45_200_000,
        todayTokens: 3_421_000,
        tokensPerMinute: 4_200,
        projects: [(name: "token-monster", tokens: 12_000_000)],
        stage: .child,
        totalCostUSD: 128.45
    )
    dash.apply(snapshot: fake)
    // give layout a chance to run
    RunLoop.main.run(until: Date().addingTimeInterval(0.5))
    if let cv = dash.window?.contentView {
        let rep = cv.bitmapImageRepForCachingDisplay(in: cv.bounds)!
        cv.cacheDisplay(in: cv.bounds, to: rep)
        if let png = rep.representation(using: .png, properties: [:]) {
            try? png.write(to: URL(fileURLWithPath: "samples/dashboard.png"))
            print("dashboard saved to samples/dashboard.png")
        }
    }
    exit(0)
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
