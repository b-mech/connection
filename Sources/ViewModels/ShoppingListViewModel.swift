import Foundation

public struct ShoppingTotals: Equatable, Sendable {
    public let totalCad: Decimal
    public let totalSats: Int64
    public let btcNeeded: Decimal
}

public struct ShoppingListCalculator {
    private let converter: DenominationConverter

    public init(converter: DenominationConverter = BitcoinSatsConverter()) {
        self.converter = converter
    }

    public func computeTotals(listItems: [ShoppingListItem], itemByID: [UUID: Item], btcCadRate: Decimal) -> ShoppingTotals {
        var totalCad: Decimal = 0
        var totalSats: Int64 = 0

        for entry in listItems {
            guard let item = itemByID[entry.itemID] else { continue }
            let lineCad = item.cadPrice * Decimal(entry.quantity)
            totalCad += lineCad
            totalSats += converter.sats(fromCad: lineCad, btcCadRate: btcCadRate)
        }

        return ShoppingTotals(
            totalCad: totalCad,
            totalSats: totalSats,
            btcNeeded: converter.btcNeeded(fromCad: totalCad, btcCadRate: btcCadRate)
        )
    }
}
