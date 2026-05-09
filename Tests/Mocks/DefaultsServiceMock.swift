/*
 Jottre: Minimalistic jotting for iPhone, iPad and Mac.
 Copyright (C) 2021-2026 Anton Lorani

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

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
