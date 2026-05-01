import Foundation

@testable import Jottre

final class DefaultsServiceMock: DefaultsServiceProtocol, @unchecked Sendable {

    private let lock = NSLock()
    private var storage: [String: Any] = [:]
    private var continuations: [String: [Any]] = [:]

    init(initialValues: [String: any LosslessStringConvertible & Sendable] = [:]) {
        storage = initialValues
    }

    func getValue<T: LosslessStringConvertible & Sendable>(_ defaultsKey: DefaultsKey<T>) -> T? {
        lock.withLock {
            storage[defaultsKey.description] as? T
        }
    }

    func set<T: LosslessStringConvertible & Sendable>(_ defaultsKey: DefaultsKey<T>, value: T?) {
        let listeners: [AsyncStream<T?>.Continuation] = lock.withLock {
            if let value {
                storage[defaultsKey.description] = value
            } else {
                storage.removeValue(forKey: defaultsKey.description)
            }
            return (continuations[defaultsKey.description] ?? [])
                .compactMap { $0 as? AsyncStream<T?>.Continuation }
        }
        for continuation in listeners {
            continuation.yield(value)
        }
    }

    func getValueStream<T: LosslessStringConvertible & Sendable>(_ defaultsKey: DefaultsKey<T>) -> AsyncStream<T?> {
        AsyncStream { [weak self] continuation in
            guard let self else {
                continuation.finish()
                return
            }
            continuation.yield(self.getValue(defaultsKey))
            self.lock.withLock {
                self.continuations[defaultsKey.description, default: []].append(continuation)
            }
        }
    }
}
