import XCTest
@testable import MarketRate

final class MarketRateTests: XCTestCase {
    func testCadToSatsRoundsToNearest() {
        let converter = BitcoinSatsConverter()
        let sats = converter.sats(fromCad: 4.99, btcCadRate: 100_000)
        XCTAssertEqual(sats, 4_990)
    }

    func testReceiptParserPrefersTotalKeywordNearBottom() {
        let text = """
        SUBTOTAL 12.99
        HST 1.69
        TOTAL 14.68
        """
        let parser = ReceiptTotalParser()
        let result = parser.parseTotal(from: text)

        XCTAssertEqual(result.cadPrice, Decimal(string: "14.68"))
        XCTAssertGreaterThanOrEqual(result.confidence, 0.7)
    }

    func testReceiptParserFallbackLargestInTail() {
        let text = """
        ITEM A 2.00
        ITEM B 3.00
        NOTE
        25.45
        """
        let parser = ReceiptTotalParser()
        let result = parser.parseTotal(from: text)

        XCTAssertEqual(result.cadPrice, Decimal(string: "25.45"))
    }

    func testShelfTagParsesMultiBuySlashPattern() {
        let parser = ShelfTagParser()
        let result = parser.parsePrice(from: "2/$5")
        XCTAssertEqual(result.cadPrice, Decimal(string: "2.5"))
        XCTAssertGreaterThanOrEqual(result.confidence, 0.9)
    }

    func testShelfTagParsesForPattern() {
        let parser = ShelfTagParser()
        let result = parser.parsePrice(from: "$6 FOR 3")
        XCTAssertEqual(result.cadPrice, Decimal(string: "2"))
    }
}
