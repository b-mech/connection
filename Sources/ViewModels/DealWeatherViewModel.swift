#if canImport(Combine)
import Foundation
import Combine

@MainActor
public final class DealWeatherViewModel: ObservableObject {
    @Published public private(set) var quote: BTCQuote?
    @Published public var userProfile: UserProfile
    @Published public private(set) var weather: DealWeather = .cold

    private let quoteProvider: BTCQuoteProviding
    private let converter: DenominationConverter

    public init(
        userProfile: UserProfile = .init(),
        quoteProvider: BTCQuoteProviding,
        converter: DenominationConverter = BitcoinSatsConverter()
    ) {
        self.userProfile = userProfile
        self.quoteProvider = quoteProvider
        self.converter = converter
    }

    public var inProfit: Bool {
        guard let quote else { return false }
        return quote.cadPerBTC > userProfile.avgCostCadPerBtc
    }

    public var deploySignal: Bool {
        (weather == .warm || weather == .hot) && inProfit
    }

    public func refreshQuote() async {
        do {
            quote = try await quoteProvider.fetchSpotQuote()
        } catch {
            quote = nil
        }
    }

    public func recomputeWeather(items: [Item], baselines: [UUID: Int64]) {
        guard let quote else {
            weather = .cold
            return
        }

        let dealPercents: [Double] = items.compactMap { item in
            guard let baseline = baselines[item.id], baseline > 0 else { return nil }
            let current = converter.sats(fromCad: item.cadPrice, btcCadRate: quote.cadPerBTC)
            return DealComputation.dealPercent(baselineSats: baseline, currentSats: current)
        }
        weather = DealComputation.classifyDay(dealPercents: dealPercents)
    }
}
#endif
