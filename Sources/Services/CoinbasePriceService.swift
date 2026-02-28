import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct BTCQuote: Equatable, Sendable {
    public let cadPerBTC: Decimal
    public let fetchedAt: Date

    public init(cadPerBTC: Decimal, fetchedAt: Date) {
        self.cadPerBTC = cadPerBTC
        self.fetchedAt = fetchedAt
    }
}

public protocol BTCQuoteProviding: Sendable {
    func fetchSpotQuote() async throws -> BTCQuote
}

public enum CoinbasePriceServiceError: Error {
    case invalidAmount
}

public final class CoinbasePriceService: BTCQuoteProviding {
    private let session: URLSession
    private let endpoint = URL(string: "https://api.coinbase.com/v2/prices/BTC-CAD/spot")!

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func fetchSpotQuote() async throws -> BTCQuote {
        let (data, _) = try await session.data(from: endpoint)
        let response = try JSONDecoder().decode(CoinbaseSpotResponse.self, from: data)
        guard let amount = Decimal(string: response.data.amount) else {
            throw CoinbasePriceServiceError.invalidAmount
        }
        return BTCQuote(cadPerBTC: amount, fetchedAt: .now)
    }
}

private struct CoinbaseSpotResponse: Decodable {
    struct Payload: Decodable {
        let amount: String
    }

    let data: Payload
}
