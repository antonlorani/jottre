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

private struct NoteID: Sendable, Hashable {
    let note: NoteBusinessModel
    let infoText: String?
}

extension PageCellItem {

    @MainActor
    static func note(
        note: NoteBusinessModel,
        infoText: String?,
        noteMenuConfigurations: [NoteMenuConfiguration],
        sizing: PageCellSizingStrategy,
        onAction: @Sendable @escaping () -> Void
    ) -> PageCellItem {
        PageCellItem(
            id: NoteID(
                note: note,
                infoText: infoText
            ),
            cellType: NoteCell.self,
            sizing: sizing,
            viewModel: NoteCellViewModel(
                note: note,
                infoText: infoText,
                noteMenuConfigurations: noteMenuConfigurations,
                onAction: onAction
            )
        )
    }
}
