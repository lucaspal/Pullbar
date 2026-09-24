import Foundation

/// Mirrors the "Updated: …" filter on github.com/pulls/inbox.
enum UpdatedWindow: String, CaseIterable {
    case week, month, quarter, all

    var title: String {
        switch self {
        case .week: return "Last week"
        case .month: return "Last month"
        case .quarter: return "Last 3 months"
        case .all: return "Any time"
        }
    }

    var days: Int? {
        switch self {
        case .week: return 7
        case .month: return 31
        case .quarter: return 92
        case .all: return nil
        }
    }

    /// The `updated:>=YYYY-MM-DD` search qualifier, or nil for no filter.
    var searchQualifier: String? {
        guard let days else { return nil }
        let date = Calendar(identifier: .gregorian).date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "UTC")
        f.dateFormat = "yyyy-MM-dd"
        return "updated:>=\(f.string(from: date))"
    }
}

@MainActor
final class Settings {
    static let shared = Settings()
    private let defaults = UserDefaults.standard

    static let refreshChoices: [TimeInterval] = [60, 120, 300, 900]

    var updatedWindow: UpdatedWindow {
        get { UpdatedWindow(rawValue: defaults.string(forKey: "updatedWindow") ?? "") ?? .month }
        set { defaults.set(newValue.rawValue, forKey: "updatedWindow") }
    }

    var refreshInterval: TimeInterval {
        get {
            let v = defaults.double(forKey: "refreshInterval")
            return v > 0 ? v : 120
        }
        set { defaults.set(newValue, forKey: "refreshInterval") }
    }
}
