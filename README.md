# MarketRate (MVP Scaffold)

Swift package scaffold for a sats-first iOS app that tracks item prices in CAD and converts to sats with Coinbase BTC/CAD spot quotes.

## Structure

- `Sources/Models`: core domain model types
- `Sources/Services`: quote provider abstraction + Coinbase implementation
- `Sources/Parsing`: OCR text parsers for receipt total and shelf tags
- `Sources/Denomination`: sats conversion + weather/deal math
- `Sources/Persistence`: repository protocols + in-memory mock
- `Sources/Backend`: alert evaluation interface + mock backend actor
- `Sources/ViewModels`: MVVM logic for deal weather/store deals/shopping totals
- `Sources/Views`: initial SwiftUI screens (compiled when SwiftUI is available)
- `Tests`: XCTest coverage for conversion and parser behavior

## Notes

- Receipt parser is total-only by design (V1).
- Shelf tag parser prioritizes multi-buy expressions to derive per-unit CAD.
- Backend/APNs responsibilities are represented via interfaces and mock implementation for extension.
