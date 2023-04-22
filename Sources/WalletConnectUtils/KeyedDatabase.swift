import Foundation

public class KeyedDatabase<Element> where Element: Codable & Equatable {

    private var index: [String: [Element]] = [:] {
        didSet {
            guard oldValue != index else { return }
            set(index, for: identifier)
            onUpdate?()
        }
    }

    private let storage: KeyValueStorage
    private let identifier: String

    public var onUpdate: (() -> Void)?

    public init(storage: KeyValueStorage, identifier: String) {
        self.storage = storage
        self.identifier = identifier

        initializeIndex()
    }

    public func getAll() -> [Element] {
        return index.values.reduce([], +)
    }

    public func getElements(for key: String) -> [Element] {
        return index[key] ?? []
    }

    public func set(_ element: Element, for key: String) {
        index.append(element, for: key)
    }

    public func delete(_ element: Element, for key: String) {
        index.delete(element, for: key)
    }
}

private extension KeyedDatabase {

    func initializeIndex() {
        guard
            let data =  storage.object(forKey: identifier) as? Data,
            let decoded = try? JSONDecoder().decode([String: [Element]].self, from: data)
        else { return }

        index = decoded
    }

    func set(_ value: [String: [Element]], for key: String) {
        let data = try! JSONEncoder().encode(value)
        storage.set(data, forKey: key)
    }
}
