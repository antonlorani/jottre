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

protocol FileServiceProtocol: Sendable {

    /// Whether the ``FileService`` is available for file-system interaction.
    func isEnabled() -> Bool

    /// Returns the path to the apps documents directory.
    func documentsDirectory() async throws -> URL?

    /// A temporary directory, suitable for loosy file persistence.
    func temporaryDirectory() -> URL

    /// Returns the contents of the given directories.
    func listContents(
        directory: URL,
        properties: [URLResourceKey]
    ) throws -> [URL]

    /// Whether the given file url is a ubiquitous item or not.
    func isUbiquitous(url: URL) -> Bool

    /// A stream that fires once the contents within the specified directory changes.
    ///
    ///  - NOTE: Only recognizes file changes at the first level depth.
    ///
    func directoryChanges(directory: URL) -> AsyncStream<Void>

    /// Returns the contents of a file.
    func readFile(fileURL: URL) throws -> Data

    /// Writes the contents of a file.
    func writeFile(fileURL: URL, data: Data) throws

    /// Whether the file is present on the file system.
    func fileExists(fileURL: URL) -> Bool

    /// Removes a file from the file-system.
    func removeFile(fileURL: URL) throws

    /// Moves a file from its current place to a new place.
    func moveFile(fileURL: URL, newFileURL: URL) throws

    /// Creates a copy of a file at a given destination.
    func duplicateFile(fileURL: URL) throws -> URL
}
