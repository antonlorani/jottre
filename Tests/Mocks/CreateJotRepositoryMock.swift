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

final class CreateJotRepositoryMock: CreateJotRepositoryProtocol {

    private let createJotProvider: @Sendable (_ name: String) async throws -> JotFile.Info

    init(
        createJotProvider:
            @Sendable @escaping (_ name: String) async throws -> JotFile.Info = { name in
                JotFile.Info(
                    url: URL(fileURLWithPath: "/tmp/\(name).jot"),
                    name: name,
                    modificationDate: nil,
                    ubiquitousInfo: nil
                )
            }
    ) {
        self.createJotProvider = createJotProvider
    }

    func createJot(name: String) async throws -> JotFile.Info {
        try await createJotProvider(name)
    }
}

final class DeleteJotRepositoryMock: DeleteJotRepositoryProtocol {

    private let deleteJotProvider: @Sendable (_ jotFileInfo: JotFile.Info) throws -> Void

    init(
        deleteJotProvider: @Sendable @escaping (_ jotFileInfo: JotFile.Info) throws -> Void = { _ in }
    ) {
        self.deleteJotProvider = deleteJotProvider
    }

    func deleteJot(jotFileInfo: JotFile.Info) throws {
        try deleteJotProvider(jotFileInfo)
    }
}
