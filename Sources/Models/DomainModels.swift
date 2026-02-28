import Foundation

public struct UserProfile: Codable, Equatable, Sendable {
    public var homeCurrency: String
    public var btcHeld: Decimal
    public var avgCostCadPerBtc: Decimal

    public init(homeCurrency: String = "CAD", btcHeld: Decimal = 0, avgCostCadPerBtc: Decimal = 0) {
        self.homeCurrency = homeCurrency
        self.btcHeld = btcHeld
        self.avgCostCadPerBtc = avgCostCadPerBtc
    }
}

public struct Store: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var chain: String?
    public var address: String?
    public var latitude: Double?
    public var longitude: Double?
    public var radiusMeters: Double?

    public init(
        id: UUID = UUID(),
        name: String,
        chain: String? = nil,
        address: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        radiusMeters: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.chain = chain
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.radiusMeters = radiusMeters
    }
}

public struct Item: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var storeID: UUID
    public var name: String
    public var cadPrice: Decimal
    public var updatedAt: Date
    public var active: Bool

    public init(
        id: UUID = UUID(),
        storeID: UUID,
        name: String,
        cadPrice: Decimal,
        updatedAt: Date = .now,
        active: Bool = true
    ) {
        self.id = id
        self.storeID = storeID
        self.name = name
        self.cadPrice = cadPrice
        self.updatedAt = updatedAt
        self.active = active
    }
}

public enum ObservationSource: String, Codable, Sendable {
    case shelfTag
    case receiptTotal
    case manual
}

public struct Observation: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var itemID: UUID
    public var cadPrice: Decimal
    public var source: ObservationSource
    public var rawOCRText: String
    public var createdAt: Date
    public var btcCadRateUsed: Decimal

    public init(
        id: UUID = UUID(),
        itemID: UUID,
        cadPrice: Decimal,
        source: ObservationSource,
        rawOCRText: String,
        createdAt: Date = .now,
        btcCadRateUsed: Decimal
    ) {
        self.id = id
        self.itemID = itemID
        self.cadPrice = cadPrice
        self.source = source
        self.rawOCRText = rawOCRText
        self.createdAt = createdAt
        self.btcCadRateUsed = btcCadRateUsed
    }
}

public struct AlertRule: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var itemID: UUID
    public var baselineSats: Int64
    public var dropThresholdPct: Double
    public var cooldownHours: Int
    public var enabled: Bool

    public init(
        id: UUID = UUID(),
        itemID: UUID,
        baselineSats: Int64,
        dropThresholdPct: Double = 0.10,
        cooldownHours: Int = 12,
        enabled: Bool = true
    ) {
        self.id = id
        self.itemID = itemID
        self.baselineSats = baselineSats
        self.dropThresholdPct = dropThresholdPct
        self.cooldownHours = cooldownHours
        self.enabled = enabled
    }
}

public struct ShoppingList: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var storeID: UUID?
    public var createdAt: Date

    public init(id: UUID = UUID(), storeID: UUID? = nil, createdAt: Date = .now) {
        self.id = id
        self.storeID = storeID
        self.createdAt = createdAt
    }
}

public struct ShoppingListItem: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var listID: UUID
    public var itemID: UUID
    public var quantity: Int

    public init(id: UUID = UUID(), listID: UUID, itemID: UUID, quantity: Int = 1) {
        self.id = id
        self.listID = listID
        self.itemID = itemID
        self.quantity = quantity
    }
}
