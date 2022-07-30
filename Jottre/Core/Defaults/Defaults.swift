import Combine
import Foundation

protocol DefaultsEntryProtocol {

    associatedtype Value

    var key: String { get }
    var valueType: Value.Type { get }
}

protocol DefaultsProtocol {

    func get<E: DefaultsEntryProtocol>(_ entry: E) -> E.Value?

    func set<E: DefaultsEntryProtocol>(_ entry: E, _ value: E.Value?)

    func get<E: DefaultsEntryProtocol, T: RawRepresentable>(_ entry: E, _ type: T.Type) -> T? where E.Value == T.RawValue

    func get<E: DefaultsEntryProtocol, T: LosslessStringConvertible>(_ entry: E, _ type: T.Type) -> T? where E.Value == String

    func publisher<E: DefaultsEntryProtocol>(_ entry: E) -> AnyPublisher<E.Value?, Never>
}

struct Defaults: DefaultsProtocol {

    static let shared = Defaults(userDefaults: .standard)

    private let defaultsSubject = PassthroughSubject<(key: String, value: Any?), Never>()

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func get<E: DefaultsEntryProtocol>(_ entry: E) -> E.Value? {
        userDefaults.object(forKey: entry.key) as? E.Value
    }

    func set<E: DefaultsEntryProtocol>(_ entry: E, _ value: E.Value?) {
        if let value = value {
            userDefaults.set(value, forKey: entry.key)
        } else {
            userDefaults.removeObject(forKey: entry.key)
        }

        defaultsSubject.send((key: entry.key, value: value))
    }

    func get<E: DefaultsEntryProtocol, T: RawRepresentable>(_ entry: E, _ type: T.Type) -> T? where E.Value == T.RawValue {
        guard let value = get(entry) else {
            return nil
        }
        return T(rawValue: value)
    }

    func get<E: DefaultsEntryProtocol, T: LosslessStringConvertible>(_ entry: E, _ type: T.Type) -> T? where E.Value == String {
        guard let value = get(entry) else {
            return nil
        }
        return T(value)
    }

    func publisher<E: DefaultsEntryProtocol>(_ entry: E) -> AnyPublisher<E.Value?, Never> {
        defaultsSubject
            .filter { key, _ in
                key == entry.key
            }
            .map { _, value in
                value as? E.Value
            }
            .prepend(get(entry))
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}
