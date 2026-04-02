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

protocol JotFileConflictServiceProtocol: Sendable {

    func getConfictingVersions(jotFileInfo: JotFile.Info) -> [JotFileVersion]?

    func resolveVersionConflicts(
        jotFileInfo: JotFile.Info,
        resolvedVersions: [JotFileVersion]
    ) throws

    func copyVersionToTemporary(
        jotFileInfo: JotFile.Info,
        jotFileVersion: JotFileVersion
    ) throws -> JotFile.Info?
}

struct JotFileConflictService: JotFileConflictServiceProtocol {

    private let fileConflictService: FileConflictServiceProtocol

    init(fileConflictService: FileConflictServiceProtocol) {
        self.fileConflictService = fileConflictService
    }

    func getConfictingVersions(jotFileInfo: JotFile.Info) -> [JotFileVersion]? {
        guard let fileVersions = fileConflictService.getConflictingVersions(fileURL: jotFileInfo.url),
            !fileVersions.isEmpty
        else {
            return nil
        }
        return
            fileVersions
            .map { fileVersion in
                JotFileVersion(
                    localizedNameOfSavingComputer: fileVersion.localizedNameOfSavingComputer,
                    info: JotFile.Info(
                        url: fileVersion.url,
                        name: fileVersion.localizedName ?? fileVersion.url.deletingPathExtension().lastPathComponent,
                        modificationDate: fileVersion.modificationDate,
                        ubiquitousInfo: UbiquitousInfo(downloadStatus: nil, isDownloading: false)
                    )
                )
            }
    }

    func resolveVersionConflicts(
        jotFileInfo: JotFile.Info,
        resolvedVersions: [JotFileVersion]
    ) throws {
        try fileConflictService.resolveVersionConflicts(
            fileURL: jotFileInfo.url,
            resolvedVersions: resolvedVersions.map(\.info.url)
        )
    }

    func copyVersionToTemporary(
        jotFileInfo: JotFile.Info,
        jotFileVersion: JotFileVersion
    ) throws -> JotFile.Info? {
        guard
            let tmpURL = try fileConflictService.copyVersionToTemporary(
                fileURL: jotFileInfo.url,
                versionURL: jotFileVersion.info.url
            )
        else {
            return nil
        }
        return JotFile.Info(
            url: tmpURL,
            name: jotFileVersion.info.name,
            modificationDate: jotFileVersion.info.modificationDate,
            ubiquitousInfo: jotFileVersion.info.ubiquitousInfo
        )
    }
}
