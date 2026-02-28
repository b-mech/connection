import Foundation

public struct ShelfTagParser {
    private static let promoTokens = ["SAVE", "OFF", "%", "WAS", "REG", "COMPARE", "MEMBER"]
    private static let unitTokens = ["/KG", "/LB", "/100G", "/L"]

    public init() {}

    public func parsePrice(from rawText: String) -> ParsedPriceResult {
        let normalized = rawText
            .uppercased()
            .split(whereSeparator: \.isNewline)
            .map(String.init)

        let filtered = normalized.filter { line in
            !Self.promoTokens.contains(where: line.contains) && !Self.unitTokens.contains(where: line.contains)
        }

        for line in filtered {
            if let result = parseMultiBuy(line: line) {
                return result
            }
        }

        for line in filtered {
            if let amount = extractSinglePrice(from: line) {
                return ParsedPriceResult(cadPrice: amount, confidence: 0.72, matchedLine: line)
            }
        }

        return ParsedPriceResult(cadPrice: nil, confidence: 0, matchedLine: nil)
    }

    private func parseMultiBuy(line: String) -> ParsedPriceResult? {
        let patterns: [String] = [
            #"\b([2-9]|10)\s*/\s*\$?\s*([0-9]+(?:\.[0-9]{2})?)\b"#,
            #"\$\s*([0-9]+(?:\.[0-9]{2})?)\s+FOR\s+([2-9]|10)\b"#,
            #"\b([2-9]|10)\s+FOR\s+\$?\s*([0-9]+(?:\.[0-9]{2})?)\b"#
        ]

        for (index, pattern) in patterns.enumerated() {
            guard let regex = try? NSRegularExpression(pattern: pattern) else { continue }
            let range = NSRange(line.startIndex..., in: line)
            guard let match = regex.firstMatch(in: line, range: range),
                  let r1 = Range(match.range(at: 1), in: line),
                  let r2 = Range(match.range(at: 2), in: line)
            else { continue }

            let first = Decimal(string: String(line[r1]))
            let second = Decimal(string: String(line[r2]))

            let quantity: Decimal
            let total: Decimal
            if index == 1 {
                total = first ?? 0
                quantity = second ?? 0
            } else {
                quantity = first ?? 0
                total = second ?? 0
            }

            guard quantity >= 2, quantity <= 10, total > 0 else { continue }
            return ParsedPriceResult(cadPrice: total / quantity, confidence: 0.9, matchedLine: line)
        }

        return nil
    }

    private func extractSinglePrice(from line: String) -> Decimal? {
        let pattern = #"\$\s*([0-9]+(?:\.[0-9]{2})?)|\b([0-9]+\.[0-9]{2})\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(line.startIndex..., in: line)
        guard let match = regex.firstMatch(in: line, range: range) else { return nil }

        for group in 1...2 {
            let nsRange = match.range(at: group)
            guard nsRange.location != NSNotFound,
                  let swiftRange = Range(nsRange, in: line),
                  let value = Decimal(string: String(line[swiftRange]))
            else { continue }
            return value
        }

        return nil
    }
}
