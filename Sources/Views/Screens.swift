#if canImport(SwiftUI)
import SwiftUI

public struct DealWeatherScreen: View {
    @StateObject private var viewModel: DealWeatherViewModel

    public init(viewModel: DealWeatherViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GroupBox("BTC/CAD") {
                Text(viewModel.quote?.cadPerBTC.description ?? "--")
                Text(viewModel.quote?.fetchedAt.formatted() ?? "No quote")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            GroupBox("Deal Weather") {
                Text(viewModel.weather.rawValue.capitalized)
                    .font(.title2.bold())
                Text("Deploy Signal: \(viewModel.deploySignal ? "ON" : "OFF")")
                Text("In Profit: \(viewModel.inProfit ? "Yes" : "No")")
            }

            Spacer()
        }
        .padding()
        .task { await viewModel.refreshQuote() }
    }
}

public struct StoreDealsScreen: View {
    public let rows: [StoreDealRow]

    public init(rows: [StoreDealRow]) {
        self.rows = rows
    }

    public var body: some View {
        List(rows) { row in
            VStack(alignment: .leading) {
                Text(row.itemName)
                Text("\(row.currentSats) sats (\(Int(row.dealPercent * 100))% deal)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Best Deals")
    }
}

public struct ShoppingListScreen: View {
    public let totals: ShoppingTotals

    public init(totals: ShoppingTotals) {
        self.totals = totals
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total: CAD \(totals.totalCad.description)")
            Text("Total sats: \(totals.totalSats)")
            Text("BTC needed: \(totals.btcNeeded.description)")
            Spacer()
        }
        .padding()
        .navigationTitle("Shopping List")
    }
}
#endif
