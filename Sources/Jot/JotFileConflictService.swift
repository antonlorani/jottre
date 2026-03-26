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

    func getUnresolvedConflicts(jotFileInfo: JotFile.Info) -> [JotFileVersion]?

    func resolveConflicts(
        jotFileInfo: JotFile.Info,
        resolvedVersion: JotFileVersion?
    ) throws
}

struct JotFileConflictService: JotFileConflictServiceProtocol {

    private let fileService: FileServiceProtocol
    private let fileConflictService: FileConflictServiceProtocol

    init(
        fileService: FileServiceProtocol,
        fileConflictService: FileConflictServiceProtocol
    ) {
        self.fileService = fileService
        self.fileConflictService = fileConflictService
    }

    func getUnresolvedConflicts(jotFileInfo: JotFile.Info) -> [JotFileVersion]? {
        guard let fileVersions = fileConflictService.getUnresolvedConflicts(fileURL: jotFileInfo.url),
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
                        modificationDate: fileVersion.modificationDate
                    )
                )
            }
    }

    func resolveConflicts(
        jotFileInfo: JotFile.Info,
        resolvedVersion: JotFileVersion?
    ) throws {
        try fileConflictService.resolveConflicts(
            fileURL: jotFileInfo.url,
            resolvedVersion: resolvedVersion?.info.url
        )
    }
}
