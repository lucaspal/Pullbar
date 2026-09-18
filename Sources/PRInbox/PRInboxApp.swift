import AppKit

/// Entry point. `@MainActor` so the main-actor `AppDelegate` can be created
/// synchronously here (top-level code in a `main.swift` is nonisolated).
@main
enum PRInboxApp {
    @MainActor
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        // Menu bar only: no Dock icon, no main window. `LSUIElement` in the
        // bundle's Info.plist does the same when packaged; this covers `swift run`.
        app.setActivationPolicy(.accessory)
        app.run()
    }
}
