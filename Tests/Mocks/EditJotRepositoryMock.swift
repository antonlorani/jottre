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

import CoreGraphics
import Foundation
@preconcurrency import PencilKit

@testable import Jottre

final class EditJotRepositoryMock: EditJotRepositoryProtocol {

    private let ubiquitousInfoProvider: @Sendable (_ url: URL) -> UbiquitousInfo?
    private let readDrawingProvider:
        @Sendable (_ jotFileInfo: JotFile.Info) async throws -> (drawing: PKDrawing, width: CGFloat)
    private let writeDrawingProvider: @Sendable (_ jotFileInfo: JotFile.Info, _ drawing: PKDrawing) async throws -> Void
    private let getConflictingVersionsProvider: @Sendable (_ jotFileInfo: JotFile.Info) -> [JotFileVersion]?
    private let duplicateProvider: @Sendable (_ jotFileInfo: JotFile.Info) throws -> JotFile.Info

    init(
        ubiquitousInfoProvider: @Sendable @escaping (_ url: URL) -> UbiquitousInfo? = { _ in nil },
        readDrawingProvider:
            @Sendable @escaping (_ jotFileInfo: JotFile.Info) async throws -> (drawing: PKDrawing, width: CGFloat) = {
                _ in (PKDrawing(), 800)
            },
        writeDrawingProvider:
            @Sendable @escaping (_ jotFileInfo: JotFile.Info, _ drawing: PKDrawing) async throws -> Void = { _, _ in },
        getConflictingVersionsProvider: @Sendable @escaping (_ jotFileInfo: JotFile.Info) -> [JotFileVersion]? = { _ in
            nil
        },
        duplicateProvider: @Sendable @escaping (_ jotFileInfo: JotFile.Info) throws -> JotFile.Info = { jotFileInfo in
            jotFileInfo
        }
    ) {
        self.ubiquitousInfoProvider = ubiquitousInfoProvider
        self.readDrawingProvider = readDrawingProvider
        self.writeDrawingProvider = writeDrawingProvider
        self.getConflictingVersionsProvider = getConflictingVersionsProvider
        self.duplicateProvider = duplicateProvider
    }

    func ubiquitousInfo(url: URL) -> UbiquitousInfo? {
        ubiquitousInfoProvider(url)
    }

    func readDrawing(jotFileInfo: JotFile.Info) async throws -> (drawing: PKDrawing, width: CGFloat) {
        try await readDrawingProvider(jotFileInfo)
    }

    func writeDrawing(jotFileInfo: JotFile.Info, drawing: PKDrawing) async throws {
        try await writeDrawingProvider(jotFileInfo, drawing)
    }

    func getConflictingVersions(jotFileInfo: JotFile.Info) -> [JotFileVersion]? {
        getConflictingVersionsProvider(jotFileInfo)
    }

    func duplicate(jotFileInfo: JotFile.Info) throws -> JotFile.Info {
        try duplicateProvider(jotFileInfo)
    }
}
