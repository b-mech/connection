import Foundation

public struct ParsedPriceResult: Equatable, Sendable {
    public let cadPrice: Decimal?
    public let confidence: Double
    public let matchedLine: String?

    public init(cadPrice: Decimal?, confidence: Double, matchedLine: String?) {
        self.cadPrice = cadPrice
        self.confidence = confidence
        self.matchedLine = matchedLine
    }
}

public struct ReceiptTotalParser {
    private static let preferredKeywords = [
        "TOTAL", "AMOUNT DUE", "BALANCE DUE", "GRAND TOTAL", "TOTAL DUE", "TO PAY",
        "MONTANT DÛ", "SOLDE DÛ", "TOTAL GÉNÉRAL", "À PAYER"
    ]

    private static let rejectedKeywords = [
        "SUBTOTAL", "TAX", "GST", "PST", "HST", "TIP", "GRATUITY", "CHANGE", "DISCOUNT", "REMISE", "%"
    ]

    public init() {}

    public func parseTotal(from rawText: String) -> ParsedPriceResult {
        let lines = rawText
            .split(whereSeparator: \.isNewline)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !lines.isEmpty else {
            return ParsedPriceResult(cadPrice: nil, confidence: 0, matchedLine: nil)
        }

        var best: (line: String, amount: Decimal, score: Double)?

        for (index, line) in lines.enumerated() {
            let upper = line.uppercased()
            if Self.rejectedKeywords.contains(where: upper.contains) { continue }
            guard let amount = extractAmount(from: line) else { continue }

            var score = 0.2
            if Self.preferredKeywords.contains(where: upper.contains) { score += 0.6 }
            if index >= Int(Double(lines.count) * 0.75) { score += 0.2 }

            if best == nil || score > best!.score || (score == best!.score && amount > best!.amount) {
                best = (line, amount, min(1.0, score))
            }
        }

        if let best {
            return ParsedPriceResult(cadPrice: best.amount, confidence: best.score, matchedLine: best.line)
        }

        let tailStart = Int(Double(lines.count) * 0.75)
        let tailLines = Array(lines[tailStart...])
        let fallback = tailLines
            .filter { line in
                let upper = line.uppercased()
                return !Self.rejectedKeywords.contains(where: upper.contains)
            }
            .compactMap(extractAmount(from:))
            .max()

        return ParsedPriceResult(cadPrice: fallback, confidence: fallback == nil ? 0 : 0.45, matchedLine: nil)
    }

    private func extractAmount(from line: String) -> Decimal? {
        let pattern = #"\$?\s*([0-9]{1,5}(?:[\.,][0-9]{2})?)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(line.startIndex..., in: line)
        guard let match = regex.matches(in: line, range: range).last,
              let valueRange = Range(match.range(at: 1), in: line)
        else {
            return nil
        }
        let normalized = line[valueRange].replacingOccurrences(of: ",", with: ".")
        return Decimal(string: String(normalized))
    }
}
