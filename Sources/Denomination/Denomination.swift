import Foundation

public protocol DenominationConverter: Sendable {
    func sats(fromCad cadPrice: Decimal, btcCadRate: Decimal) -> Int64
    func btcNeeded(fromCad cadAmount: Decimal, btcCadRate: Decimal) -> Decimal
}

public struct BitcoinSatsConverter: DenominationConverter {
    public static let satsPerBTC = Decimal(100_000_000)

    public init() {}

    public func sats(fromCad cadPrice: Decimal, btcCadRate: Decimal) -> Int64 {
        guard btcCadRate > 0 else { return 0 }
        let rawSats = (cadPrice / btcCadRate) * Self.satsPerBTC
        return NSDecimalNumber(decimal: rawSats).rounding(accordingToBehavior: nil).int64Value
    }

    public func btcNeeded(fromCad cadAmount: Decimal, btcCadRate: Decimal) -> Decimal {
        guard btcCadRate > 0 else { return 0 }
        return cadAmount / btcCadRate
    }
}

public enum DealWeather: String, Sendable {
    case hot
    case warm
    case cold
}

public struct DealComputation {
    public static func dealPercent(baselineSats: Int64, currentSats: Int64) -> Double {
        guard baselineSats > 0 else { return 0 }
        return Double(baselineSats - currentSats) / Double(baselineSats)
    }

    public static func classifyDay(dealPercents: [Double]) -> DealWeather {
        guard !dealPercents.isEmpty else { return .cold }
        let warmOrHotCount = dealPercents.filter { $0 >= 0.05 }.count
        let dealIndex = Double(warmOrHotCount) / Double(dealPercents.count)
        switch dealIndex {
        case 0.40...: return .hot
        case 0.20..<0.40: return .warm
        default: return .cold
        }
    }
}
