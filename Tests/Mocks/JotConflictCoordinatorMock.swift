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
final class JotConflictCoordinatorMock: JotConflictCoordinatorProtocol {

    var onEnd: (() -> Void)?

    private let startProvider: () -> Void
    private let showInfoAlertProvider: (_ title: String, _ message: String) -> Void
    private let dismissProvider: (_ completion: @Sendable () -> Void) -> Void

    init(
        startProvider: @escaping () -> Void = {},
        showInfoAlertProvider: @escaping (_ title: String, _ message: String) -> Void = { _, _ in },
        dismissProvider: @escaping (_ completion: @Sendable () -> Void) -> Void = { _ in }
    ) {
        self.startProvider = startProvider
        self.showInfoAlertProvider = showInfoAlertProvider
        self.dismissProvider = dismissProvider
    }

    func start() {
        startProvider()
    }

    func showInfoAlert(title: String, message: String) {
        showInfoAlertProvider(title, message)
    }

    func dismiss(completion: @Sendable @escaping () -> Void) {
        dismissProvider(completion)
    }
}
