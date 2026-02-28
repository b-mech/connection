import Foundation

public struct StoreDealRow: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let itemName: String
    public let currentSats: Int64
    public let baselineSats: Int64
    public let dealPercent: Double
}

public struct StoreDealsBuilder {
    private let converter: DenominationConverter

    public init(converter: DenominationConverter = BitcoinSatsConverter()) {
        self.converter = converter
    }

    public func buildRows(items: [Item], baselines: [UUID: Int64], btcCadRate: Decimal) -> [StoreDealRow] {
        items.compactMap { item in
            guard let baseline = baselines[item.id], baseline > 0 else { return nil }
            let currentSats = converter.sats(fromCad: item.cadPrice, btcCadRate: btcCadRate)
            return StoreDealRow(
                id: item.id,
                itemName: item.name,
                currentSats: currentSats,
                baselineSats: baseline,
                dealPercent: DealComputation.dealPercent(baselineSats: baseline, currentSats: currentSats)
            )
        }
        .sorted { $0.dealPercent > $1.dealPercent }
    }
}
