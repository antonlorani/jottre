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
final class ApplicationServiceMock: ApplicationServiceProtocol {

    private let supportsMultipleScenesProvider: @MainActor () -> Bool
    private let openProvider: @MainActor (_ url: URL) -> Void
    private let canOpenProvider: @MainActor (_ url: URL) -> Bool

    init(
        supportsMultipleScenesProvider: @MainActor @escaping () -> Bool = { false },
        openProvider: @MainActor @escaping (_ url: URL) -> Void = { _ in },
        canOpenProvider: @MainActor @escaping (_ url: URL) -> Bool = { _ in true }
    ) {
        self.supportsMultipleScenesProvider = supportsMultipleScenesProvider
        self.openProvider = openProvider
        self.canOpenProvider = canOpenProvider
    }

    func supportsMultipleScenes() -> Bool { supportsMultipleScenesProvider() }
    func open(url: URL) { openProvider(url) }
    func canOpen(url: URL) -> Bool { canOpenProvider(url) }
}
