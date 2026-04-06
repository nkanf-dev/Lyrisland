import AppKit
import Foundation

protocol PlayerEnvironmentInspecting {
    func isInstalled(_ player: PlayerKind) -> Bool
    func isRunning(_ player: PlayerKind) -> Bool
    func hasAutomationPermission() -> Bool
}

struct SystemPlayerEnvironmentInspector: PlayerEnvironmentInspecting {
    func isInstalled(_ player: PlayerKind) -> Bool {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: player.bundleIdentifier) != nil
    }

    func isRunning(_ player: PlayerKind) -> Bool {
        NSRunningApplication.runningApplications(withBundleIdentifier: player.bundleIdentifier).first != nil
    }

    func hasAutomationPermission() -> Bool {
        let testScript = """
        tell application \"System Events\"
            return name of first process
        end tell
        """
        guard let script = NSAppleScript(source: testScript) else {
            return false
        }
        var error: NSDictionary?
        script.executeAndReturnError(&error)
        return error == nil
    }
}
