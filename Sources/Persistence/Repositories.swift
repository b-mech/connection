import Foundation

public protocol ItemRepository: Sendable {
    func fetchItems(storeID: UUID?) async -> [Item]
    func save(item: Item) async
}

public actor InMemoryItemRepository: ItemRepository {
    private var items: [UUID: Item] = [:]

    public init(seed: [Item] = []) {
        for item in seed {
            items[item.id] = item
        }
    }

    public func fetchItems(storeID: UUID?) async -> [Item] {
        let values = Array(items.values)
        guard let storeID else { return values }
        return values.filter { $0.storeID == storeID }
    }

    public func save(item: Item) async {
        items[item.id] = item
    }
}
