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

import UIKit

protocol CreateJotRepositoryProtocol: Sendable {

    func createJot(name: String) async throws -> JotFile.Info
}

struct CreateJotRepository: CreateJotRepositoryProtocol {

    enum Failure: Error {
        case couldNotCreateFile
        case fileExists
    }

    private let fileService: FileServiceProtocol
    private let jotFileService: JotFileServiceProtocol

    init(
        fileService: FileServiceProtocol,
        jotFileService: JotFileServiceProtocol
    ) {
        self.fileService = fileService
        self.jotFileService = jotFileService
    }

    func createJot(name: String) async throws -> JotFile.Info {
        let cloudDirectory = try await fileService.iCloudDocumentsDirectory()
        let localDirectory = try fileService.localDocumentsDirectory()

        guard let directory = cloudDirectory ?? localDirectory else {
            throw Failure.couldNotCreateFile
        }

        let fileURL =
            directory
            .appendingPathComponent(name, isDirectory: false)
            .appendingPathExtension(JotFile.Info.fileExtension)

        guard !fileService.fileExists(fileURL: fileURL) else {
            throw Failure.fileExists
        }

        let jotFile = JotFile(
            info: JotFile.Info(
                url: fileURL,
                name: name,
                modificationDate: nil
            ),
            jot: .makeEmpty()
        )
        try jotFileService.write(jotFile: jotFile)
        return jotFile.info
    }
}
