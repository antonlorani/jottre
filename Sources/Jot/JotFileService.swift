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

protocol JotFileServiceProtocol: Sendable {
    func listContents(directory: URL) throws -> [JotFile.Info]

    func readJotFile(jotFileInfo: JotFile.Info) throws -> JotFile

    func write(jotFile: JotFile) throws

    func duplicate(jotFileInfo: JotFile.Info) throws -> JotFile.Info
}

struct JotFileService: JotFileServiceProtocol {

    private enum Constants {

        static let fileProperties: [URLResourceKey] = [
            .contentModificationDateKey,
            .isWritableKey,
            .isReadableKey,
            .isRegularFileKey,
        ]
    }

    private let propertyListDecoder = PropertyListDecoder()
    private let propertyListEncoder = PropertyListEncoder()

    private let fileService: FileServiceProtocol

    init(fileService: FileServiceProtocol) {
        self.fileService = fileService
    }

    func listContents(directory: URL) throws -> [JotFile.Info] {
        let contents = try fileService.listContents(
            directory: directory,
            properties: Constants.fileProperties
        )

        return
            try contents
            .map { content in
                try (
                    content: content,
                    properties: content.resourceValues(forKeys: Set(Constants.fileProperties))
                )
            }
            .filter { (fileURL: URL, properties: URLResourceValues) in
                properties.isRegularFile == true
                    && properties.isReadable == true
                    && properties.isWritable == true
                    && fileURL.pathExtension == JotFile.Info.fileExtension
            }
            .map { (fileURL: URL, properties: URLResourceValues) in
                JotFile.Info(
                    url: fileURL,
                    name: fileURL.deletingPathExtension().lastPathComponent,
                    modificationDate: properties.contentModificationDate
                )
            }
    }

    func readJotFile(jotFileInfo: JotFile.Info) throws -> JotFile {
        let data = try fileService.readFile(fileURL: jotFileInfo.url)
        let jot = try propertyListDecoder.decode(Jot.self, from: data)
        return JotFile(
            info: jotFileInfo,
            jot: jot
        )
    }

    func write(jotFile: JotFile) throws {
        let data = try propertyListEncoder.encode(jotFile.jot)
        try fileService.writeFile(
            fileURL: jotFile.info.url,
            data: data
        )
    }

    func duplicate(jotFileInfo: JotFile.Info) throws -> JotFile.Info {
        let duplicatedFileURL = try fileService.duplicateFile(fileURL: jotFileInfo.url)

        return JotFile.Info(
            url: duplicatedFileURL,
            name: duplicatedFileURL.deletingPathExtension().lastPathComponent,
            modificationDate: jotFileInfo.modificationDate
        )
    }
}
