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

protocol DefaultsServiceProtocol: Sendable {

    func getValue<T: LosslessStringConvertible & Sendable>(_ defaultsKey: DefaultsKey<T>) -> T?

    func set<T: LosslessStringConvertible & Sendable>(_ defaultsKey: DefaultsKey<T>, value: T?)

    func getValueStream<T: LosslessStringConvertible & Sendable>(_ defaultsKey: DefaultsKey<T>) -> AsyncStream<T?>
}

final class DefaultsService: DefaultsServiceProtocol, @unchecked Sendable {

    private let userDefaults: UserDefaults
    private let continuationStorage = DefaultsContinuationStorage()

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func getValue<T: LosslessStringConvertible & Sendable>(
        _ defaultsKey: DefaultsKey<T>
    ) -> T? {
        guard let value = userDefaults.value(forKey: defaultsKey.description) as? String else {
            return nil
        }
        return T(value)
    }

    func set<T: LosslessStringConvertible & Sendable>(
        _ defaultsKey: DefaultsKey<T>,
        value: T?
    ) {
        let key = defaultsKey.description
        userDefaults.setValue(value?.description, forKey: key)

        if let continuations = continuationStorage.continuations(defaultsKey: defaultsKey) {
            for continuation in continuations {
                continuation.yield(value)
            }
        }
    }

    func getValueStream<T: LosslessStringConvertible & Sendable>(
        _ defaultsKey: DefaultsKey<T>
    ) -> AsyncStream<T?> {
        AsyncStream { [weak self] continuation in
            continuation.yield(self?.getValue(defaultsKey))

            self?.continuationStorage.add(
                continuation,
                defaultsKey: defaultsKey
            )

            continuation.onTermination = { [weak self] _ in
                self?.continuationStorage.remove(
                    continuation,
                    defaultsKey: defaultsKey
                )
            }
        }
    }
}
