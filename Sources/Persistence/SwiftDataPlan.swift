import Foundation

public struct PersistencePlan: Sendable {
    public let notes: [String]

    public init() {
        self.notes = [
            "Use SwiftData @Model wrappers around domain structs for iOS app target.",
            "Persist quote timestamp and cadPerBTC for every conversion shown in UI.",
            "Keep repositories protocol-based so backend/SwiftData mocks are swappable in tests."
        ]
    }
}
