import Cocoa

if CommandLine.arguments.contains("--export-previews") {
    PreviewExporter.run()
    exit(0)
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
