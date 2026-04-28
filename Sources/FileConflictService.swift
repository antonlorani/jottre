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

    func copyVersionToTemporary(
        fileURL: URL,
        versionURL: URL
    ) throws -> URL?
}

struct FileConflictService: FileConflictServiceProtocol {

    enum Failure: Error {
        case couldNotCoordinateWrite
    }

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
        guard
            let unresolvedConflicts = getConflictingVersions(fileURL: fileURL),
            !resolvedVersions.isEmpty
        else {
            return
        }

        let directory = fileURL.deletingLastPathComponent()
        let name = fileURL.deletingPathExtension().lastPathComponent

        for (index, versionURL) in resolvedVersions.dropFirst().enumerated() {
            guard let version = unresolvedConflicts.first(where: { $0.url == versionURL }) else {
                continue
            }

            let copyName = "\(name) (\(index + 2))"
            let copyURL =
                directory
                .appendingPathComponent(copyName, isDirectory: false)
                .appendingPathExtension(fileURL.pathExtension)

            try coordinateWrite(fileURL: copyURL) { url in
                try version.replaceItem(at: url, options: [])
            }
        }

        try coordinateWrite(fileURL: fileURL) { url in
            if let first = resolvedVersions.first, first != fileURL,
                let version = unresolvedConflicts.first(where: { $0.url == first })
            {
                try version.replaceItem(at: url, options: [])
            }

            for conflictingVersion in unresolvedConflicts {
                conflictingVersion.isResolved = true
            }

            try NSFileVersion.removeOtherVersionsOfItem(at: url)
        }
    }

    func copyVersionToTemporary(
        fileURL: URL,
        versionURL: URL
    ) throws -> URL? {
        guard
            let versions = NSFileVersion.unresolvedConflictVersionsOfItem(at: fileURL),
            let version = versions.first(where: { $0.url == versionURL })
        else {
            return nil
        }
        let tmpURL = fileManager.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(fileURL.pathExtension)

        try coordinateWrite(fileURL: tmpURL) { url in
            try version.replaceItem(at: url, options: [])
        }

        return tmpURL
    }

    private func coordinateWrite(
        fileURL: URL,
        accessor: (URL) throws -> Void
    ) throws {
        let coordinator = NSFileCoordinator()
        var coordinatorError: NSError?
        var result: Result<Void, Error>?

        coordinator.coordinate(
            writingItemAt: fileURL,
            options: .forReplacing,
            error: &coordinatorError
        ) { url in
            result = Result(catching: {
                try accessor(url)
            })
        }

        if let coordinatorError {
            throw coordinatorError
        }

        guard let result else {
            throw Failure.couldNotCoordinateWrite
        }

        try result.get()
    }
}
