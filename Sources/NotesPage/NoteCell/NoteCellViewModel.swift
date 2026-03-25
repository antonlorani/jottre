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

final class NoteCellViewModel: PageCellViewModel {

    let note: NoteBusinessModel
    let infoText: String?
    let noteMenuConfigurations: [NoteMenuConfiguration]
    let onAction: @Sendable () -> Void

    init(
        note: NoteBusinessModel,
        infoText: String?,
        noteMenuConfigurations: [NoteMenuConfiguration],
        onAction: @Sendable @escaping () -> Void
    ) {
        self.note = note
        self.infoText = infoText
        self.noteMenuConfigurations = noteMenuConfigurations
        self.onAction = onAction
    }

    func handle(action: PageCellAction) {
        switch action {
        case .tap: onAction()
        }
    }

    func handleContextMenuConfiguration() -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { [weak self] _ in
            guard let self else {
                return nil
            }
            return UIMenu.make(noteMenuConfigurations: noteMenuConfigurations)
        }
    }
}
