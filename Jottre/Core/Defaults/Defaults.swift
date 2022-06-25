import Combine
import Foundation

@dynamicMemberLookup
protocol DefaultsProtocol {
    subscript<T: DefaultsValue>(dynamicMember keyPath: KeyPath<DefaultsKey, T>) -> T? { get nonmutating set }
    func get<T: DefaultsValue>(_ keyPath: KeyPath<DefaultsKey, T>) -> T?
    func get<R: RawRepresentable>(_ keyPath: KeyPath<DefaultsKey, R.RawValue>, _ rawRepresentable: R.Type) -> R? where R.RawValue: DefaultsValue
    func get<L: LosslessStringConvertible>(_ keyPath: KeyPath<DefaultsKey, String>, _ losslessStringConvertible: L.Type) -> L?

    func set<T: DefaultsValue>(_ value: T?, _ keyPath: KeyPath<DefaultsKey, T>)
    func publisher<T: DefaultsValue>(_ keyPath: KeyPath<DefaultsKey, T>) -> AnyPublisher<T, Never>
}

@dynamicMemberLookup
struct Defaults: DefaultsProtocol {

    static let shared = Defaults(userDefaults: UserDefaults.standard)

    private let defaultsSubject = PassthroughSubject<(value: Any?, identifier: String), Never>()
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    subscript<T: DefaultsValue>(dynamicMember keyPath: KeyPath<DefaultsKey, T>) -> T? {
        get {
            get(keyPath)
        }
        nonmutating set {
            set(newValue, keyPath)
        }
    }

    // MARK: - Getter

    func publisher<T: DefaultsValue>(_ keyPath: KeyPath<DefaultsKey, T>) -> AnyPublisher<T, Never> {
        let targetIdentifier = identifier(keyPath: keyPath)
        return defaultsSubject
            .filter { _, identifier in
                identifier == targetIdentifier
            }
            .map { value, _ in
                return value as? T
            }
            .prepend(get(keyPath))
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    func get<T: DefaultsValue>(_ keyPath: KeyPath<DefaultsKey, T>) -> T? {
        userDefaults.object(forKey: identifier(keyPath: keyPath)) as? T
    }

    func get<R: RawRepresentable>(_ keyPath: KeyPath<DefaultsKey, R.RawValue>, _ rawRepresentable: R.Type) -> R? where R.RawValue: DefaultsValue {
        guard let value = get(keyPath) else {
            return nil
        }
        return R(rawValue: value)
    }

    func get<L: LosslessStringConvertible>(_ keyPath: KeyPath<DefaultsKey, String>, _ losslessStringConvertible: L.Type) -> L? {
        guard let value = get(keyPath) else {
            return nil
        }
        return L.init(value)
    }

    // MARK: - Setter

    func set<T: DefaultsValue>(_ value: T?, _ keyPath: KeyPath<DefaultsKey, T>) {
        let identifier = identifier(keyPath: keyPath)
    
        if let value = value {
            userDefaults.set(value, forKey: identifier)
        } else {
            userDefaults.removeObject(forKey: identifier)
        }

        defaultsSubject.send((value: value, identifier: identifier))
    }

    private func identifier<T>(keyPath: KeyPath<DefaultsKey, T>) -> String {
        NSExpression(forKeyPath: keyPath).keyPath
    }
}
