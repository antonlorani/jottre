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

final class FileConflictServiceMock: FileConflictServiceProtocol {

    private let getConflictingVersionsProvider: @Sendable (_ fileURL: URL) -> [NSFileVersion]?
    private let resolveVersionConflictsProvider: @Sendable (_ fileURL: URL, _ resolvedVersions: [URL]) throws -> Void
    private let copyVersionToTemporaryProvider: @Sendable (_ fileURL: URL, _ versionURL: URL) throws -> URL?

    init(
        getConflictingVersionsProvider: @Sendable @escaping (_ fileURL: URL) -> [NSFileVersion]? = { _ in nil },
        resolveVersionConflictsProvider:
            @Sendable @escaping (_ fileURL: URL, _ resolvedVersions: [URL]) throws -> Void = { _, _ in },
        copyVersionToTemporaryProvider:
            @Sendable @escaping (_ fileURL: URL, _ versionURL: URL) throws -> URL? = { _, _ in nil }
    ) {
        self.getConflictingVersionsProvider = getConflictingVersionsProvider
        self.resolveVersionConflictsProvider = resolveVersionConflictsProvider
        self.copyVersionToTemporaryProvider = copyVersionToTemporaryProvider
    }

    func getConflictingVersions(fileURL: URL) -> [NSFileVersion]? {
        getConflictingVersionsProvider(fileURL)
    }

    func resolveVersionConflicts(fileURL: URL, resolvedVersions: [URL]) throws {
        try resolveVersionConflictsProvider(fileURL, resolvedVersions)
    }

    func copyVersionToTemporary(fileURL: URL, versionURL: URL) throws -> URL? {
        try copyVersionToTemporaryProvider(fileURL, versionURL)
    }
}
