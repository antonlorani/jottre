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

final class ShareJotRepositoryMock: ShareJotRepositoryProtocol {

    private let exportJotProvider: @Sendable (_ jotFileInfo: JotFile.Info, _ format: ShareFormat) async throws -> URL

    init(
        exportJotProvider:
            @Sendable @escaping (_ jotFileInfo: JotFile.Info, _ format: ShareFormat) async throws -> URL = { _, _ in
                URL(fileURLWithPath: "/tmp/share")
            }
    ) {
        self.exportJotProvider = exportJotProvider
    }

    func exportJot(jotFileInfo: JotFile.Info, format: ShareFormat) async throws -> URL {
        try await exportJotProvider(jotFileInfo, format)
    }
}
