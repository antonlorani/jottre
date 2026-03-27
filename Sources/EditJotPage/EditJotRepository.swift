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

@preconcurrency import PencilKit

protocol EditJotRepositoryProtocol {

    func readDrawing(jotFileInfo: JotFile.Info) throws -> (drawing: PKDrawing, width: CGFloat)
    func getUnresolvedConflicts(jotFileInfo: JotFile.Info) -> [JotFileVersion]?
    func duplicate(jotFileInfo: JotFile.Info) throws -> JotFile.Info
}

struct EditJotRepository: EditJotRepositoryProtocol {

    private let jotFileService: JotFileServiceProtocol
    private let jotFileConflictService: JotFileConflictServiceProtocol

    init(
        jotFileService: JotFileServiceProtocol,
        jotFileConflictService: JotFileConflictServiceProtocol
    ) {
        self.jotFileService = jotFileService
        self.jotFileConflictService = jotFileConflictService
    }

    func readDrawing(jotFileInfo: JotFile.Info) throws -> (drawing: PKDrawing, width: CGFloat) {
        let file = try jotFileService.readJotFile(jotFileInfo: jotFileInfo)
        let drawing = try PKDrawing(data: file.jot.drawing)
        return (
            drawing: drawing,
            width: file.jot.width
        )
    }

    func getUnresolvedConflicts(jotFileInfo: JotFile.Info) -> [JotFileVersion]? {
        jotFileConflictService.getUnresolvedConflicts(jotFileInfo: jotFileInfo)
    }

    func duplicate(jotFileInfo: JotFile.Info) throws -> JotFile.Info {
        try jotFileService.duplicate(jotFileInfo: jotFileInfo)
    }
}
