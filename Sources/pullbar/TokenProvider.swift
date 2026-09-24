import AppKit
import Foundation

/// Ensures standard paste works even though pullbar has no main Edit menu.
private final class TokenTextField: NSSecureTextField {
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let isPaste = event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command
            && event.charactersIgnoringModifiers?.lowercased() == "v"
        if isPaste {
            currentEditor()?.paste(nil)
            return true
        }
        return super.performKeyEquivalent(with: event)
    }
}

/// Finds a GitHub token: Keychain first, then a logged-in `gh` CLI, then a prompt.
enum TokenProvider {
    static func fromGhCLI() async -> String? {
        await Task.detached(priority: .utility) { () -> String? in
            let process = Process()
            // A login shell so Homebrew's PATH is available even when launched from Finder.
            process.executableURL = URL(fileURLWithPath: "/bin/zsh")
            process.arguments = ["-lc", "gh auth token 2>/dev/null"]
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = FileHandle.nullDevice
            process.standardInput = FileHandle.nullDevice
            do { try process.run() } catch { return nil }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else { return nil }
            let token = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
            return token.isEmpty ? nil : token
        }.value
    }

    /// Modal prompt for a token. Returns nil when cancelled or left empty.
    @MainActor
    static func prompt(reason: String? = nil) -> String? {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "GitHub token for pullbar"
        var text = """
        Paste a personal access token. It is stored only in your login Keychain.

        Classic token: scopes `repo` and `read:org`.
        Fine-grained token: Pull requests → Read, granted for your organisation's repositories.
        """
        if let reason { text = reason + "\n\n" + text }
        alert.informativeText = text

        let field = TokenTextField(frame: NSRect(x: 0, y: 0, width: 380, height: 24))
        field.placeholderString = "ghp_… or github_pat_…"
        alert.accessoryView = field
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")
        alert.window.initialFirstResponder = field

        NSApp.activate(ignoringOtherApps: true)
        guard alert.runModal() == .alertFirstButtonReturn else { return nil }
        let token = field.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        return token.isEmpty ? nil : token
    }
}
