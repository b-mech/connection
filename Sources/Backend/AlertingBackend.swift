import Foundation

public struct AlertTrigger: Equatable, Sendable {
    public let itemID: UUID
    public let storeID: UUID
    public let currentSats: Int64
    public let baselineSats: Int64
    public let dropPercent: Double
}

public protocol AlertingBackend: Sendable {
    func evaluateAndQueueAlerts(now: Date, rules: [AlertRule], items: [Item], currentSatsByItem: [UUID: Int64]) async
}

public actor MockAlertingBackend: AlertingBackend {
    private(set) var queuedAlerts: [AlertTrigger] = []
    private var lastFireAt: [UUID: Date] = [:]

    public init() {}

    public func evaluateAndQueueAlerts(now: Date, rules: [AlertRule], items: [Item], currentSatsByItem: [UUID: Int64]) async {
        let itemStoreIndex = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0.storeID) })

        for rule in rules where rule.enabled {
            guard let currentSats = currentSatsByItem[rule.itemID],
                  let storeID = itemStoreIndex[rule.itemID]
            else { continue }

            let threshold = Double(rule.baselineSats) * (1.0 - rule.dropThresholdPct)
            guard Double(currentSats) <= threshold else { continue }

            if let last = lastFireAt[rule.id],
               let nextAllowed = Calendar.current.date(byAdding: .hour, value: rule.cooldownHours, to: last),
               nextAllowed > now {
                continue
            }

            let dropPercent = Double(rule.baselineSats - currentSats) / Double(rule.baselineSats)
            queuedAlerts.append(
                AlertTrigger(itemID: rule.itemID, storeID: storeID, currentSats: currentSats, baselineSats: rule.baselineSats, dropPercent: dropPercent)
            )
            lastFireAt[rule.id] = now
        }
    }
}
