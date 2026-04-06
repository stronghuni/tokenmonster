import Foundation
import ServiceManagement

enum LaunchAtLogin {
    static var isEnabled: Bool {
        if #available(macOS 13, *) {
            return SMAppService.mainApp.status == .enabled
        }
        return false
    }

    static func setEnabled(_ enabled: Bool) {
        guard #available(macOS 13, *) else { return }
        do {
            if enabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("LaunchAtLogin error: \(error)")
        }
    }
}
