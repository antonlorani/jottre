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

@MainActor
final class SettingsCoordinatorMock: SettingsCoordinatorProtocol {

    var onEnd: (() -> Void)?

    private let startProvider: () -> Void
    private let openExternalLinkProvider: (_ url: URL) -> Void
    private let dismissProvider: () -> Void

    init(
        startProvider: @escaping () -> Void = {},
        openExternalLinkProvider: @escaping (_ url: URL) -> Void = { _ in },
        dismissProvider: @escaping () -> Void = {}
    ) {
        self.startProvider = startProvider
        self.openExternalLinkProvider = openExternalLinkProvider
        self.dismissProvider = dismissProvider
    }

    func start() {
        startProvider()
    }

    func openExternalLink(url: URL) {
        openExternalLinkProvider(url)
    }

    func dismiss() {
        dismissProvider()
    }
}
