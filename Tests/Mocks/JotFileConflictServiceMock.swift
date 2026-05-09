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

final class JotFileConflictServiceMock: JotFileConflictServiceProtocol {

    private let getConfictingVersionsProvider: @Sendable (_ jotFileInfo: JotFile.Info) -> [JotFileVersion]?
    private let resolveVersionConflictsProvider:
        @Sendable (_ jotFileInfo: JotFile.Info, _ resolvedVersions: [JotFileVersion]) throws -> Void
    private let copyVersionToTemporaryProvider:
        @Sendable (_ jotFileInfo: JotFile.Info, _ jotFileVersion: JotFileVersion) throws -> JotFile.Info?

    init(
        getConfictingVersionsProvider: @Sendable @escaping (_ jotFileInfo: JotFile.Info) -> [JotFileVersion]? = { _ in
            nil
        },
        resolveVersionConflictsProvider:
            @Sendable @escaping (_ jotFileInfo: JotFile.Info, _ resolvedVersions: [JotFileVersion]) throws -> Void = {
                _,
                _ in
            },
        copyVersionToTemporaryProvider:
            @Sendable @escaping (_ jotFileInfo: JotFile.Info, _ jotFileVersion: JotFileVersion) throws -> JotFile.Info? =
            { _, _ in nil }
    ) {
        self.getConfictingVersionsProvider = getConfictingVersionsProvider
        self.resolveVersionConflictsProvider = resolveVersionConflictsProvider
        self.copyVersionToTemporaryProvider = copyVersionToTemporaryProvider
    }

    func getConfictingVersions(jotFileInfo: JotFile.Info) -> [JotFileVersion]? {
        getConfictingVersionsProvider(jotFileInfo)
    }
    func resolveVersionConflicts(jotFileInfo: JotFile.Info, resolvedVersions: [JotFileVersion]) throws {
        try resolveVersionConflictsProvider(jotFileInfo, resolvedVersions)
    }
    func copyVersionToTemporary(jotFileInfo: JotFile.Info, jotFileVersion: JotFileVersion) throws -> JotFile.Info? {
        try copyVersionToTemporaryProvider(jotFileInfo, jotFileVersion)
    }
}
