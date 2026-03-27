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

protocol FileConflictServiceProtocol: Sendable {

    func getConflictingVersions(fileURL: URL) -> [NSFileVersion]?

    func resolveVersionConflicts(
        fileURL: URL,
        resolvedVersions: [URL]
    ) throws
}

struct FileConflictService: FileConflictServiceProtocol {

    nonisolated(unsafe) private let fileManager: FileManager

    init(fileManager: FileManager) {
        self.fileManager = fileManager
    }

    func getConflictingVersions(fileURL: URL) -> [NSFileVersion]? {
        NSFileVersion.unresolvedConflictVersionsOfItem(at: fileURL)
    }

    func resolveVersionConflicts(
        fileURL: URL,
        resolvedVersions: [URL]
    ) throws {
        guard let unresolvedConflicts = getConflictingVersions(fileURL: fileURL) else {
            return
        }

        if let first = resolvedVersions.first {
            _ = try fileManager.replaceItemAt(
                fileURL,
                withItemAt: first
            )
        }

        let directory = fileURL.deletingLastPathComponent()
        let name = fileURL.deletingPathExtension().lastPathComponent
        let ext = fileURL.pathExtension

        for (index, version) in resolvedVersions.dropFirst().enumerated() {
            let copyName = "\(name) (\(index + 2)).\(ext)"
            let copyURL = directory.appendingPathComponent(copyName)
            try fileManager.copyItem(at: version, to: copyURL)
        }

        for conflictingVersion in unresolvedConflicts {
            conflictingVersion.isResolved = true
        }

        try NSFileVersion.removeOtherVersionsOfItem(at: fileURL)
    }
}
