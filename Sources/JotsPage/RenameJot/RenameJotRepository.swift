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

protocol RenameJotRepositoryProtocol {

    func rename(jotFileInfo: JotFile.Info, newName: String) throws -> JotFile.Info
}

struct RenameJotRepository: RenameJotRepositoryProtocol {

    private let fileService: FileServiceProtocol

    init(fileService: FileServiceProtocol) {
        self.fileService = fileService
    }

    func rename(jotFileInfo: JotFile.Info, newName: String) throws -> JotFile.Info {
        let newFileURL = jotFileInfo.url
            .deletingPathExtension()
            .deletingLastPathComponent()
            .appendingPathComponent(newName)
            .appendingPathExtension(jotFileInfo.url.pathExtension)

        try fileService.moveFile(fileURL: jotFileInfo.url, newFileURL: newFileURL)

        return JotFile.Info(
            url: newFileURL,
            name: newName,
            modificationDate: jotFileInfo.modificationDate
        )
    }
}
