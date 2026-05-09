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

@testable import Jottre

@MainActor
final class CloudMigrationCoordinatorMock: CloudMigrationCoordinatorProtocol {

    var onEnd: (() -> Void)?

    private let shouldStartProvider: () -> Bool
    private let startProvider: () -> Void
    private let showInfoAlertProvider: (_ title: String, _ message: String) -> Void
    private let dismissProvider: () -> Void

    init(
        shouldStartProvider: @escaping () -> Bool = { false },
        startProvider: @escaping () -> Void = {},
        showInfoAlertProvider: @escaping (_ title: String, _ message: String) -> Void = { _, _ in },
        dismissProvider: @escaping () -> Void = {}
    ) {
        self.shouldStartProvider = shouldStartProvider
        self.startProvider = startProvider
        self.showInfoAlertProvider = showInfoAlertProvider
        self.dismissProvider = dismissProvider
    }

    func shouldStart() -> Bool {
        shouldStartProvider()
    }

    func start() {
        startProvider()
    }

    func showInfoAlert(title: String, message: String) {
        showInfoAlertProvider(title, message)
    }

    func dismiss() {
        dismissProvider()
    }
}
