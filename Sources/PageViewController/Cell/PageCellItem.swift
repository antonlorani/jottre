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

struct PageCellItem: Sendable, Hashable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    let id: any Hashable & Sendable
    let cellType: any PageCell.Type
    let sizing: PageCellSizingStrategy
    let configure: @Sendable @MainActor (_ cell: Any) -> Void
    let handleAction: @Sendable @MainActor (_ action: PageCellAction) -> Void
    let contextMenuConfiguration: @Sendable @MainActor () -> UIContextMenuConfiguration?

    init<
        Cell: PageCell,
        ViewModel: PageCellViewModel
    >(
        id: some Hashable & Sendable,
        cellType: Cell.Type,
        sizing: PageCellSizingStrategy,
        viewModel: ViewModel
    ) where Cell.ViewModel == ViewModel {
        self.id = id
        self.cellType = Cell.self
        self.sizing = sizing
        configure = { cell in
            guard let cell = cell as? Cell else {
                assertionFailure("Expected '\(Cell.self)' but received '\(type(of: cell))'.")
                return
            }
            cell.configure(viewModel: viewModel)
        }
        handleAction = { viewModel.handle(action: $0) }
        contextMenuConfiguration = { viewModel.handleContextMenuConfiguration() }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}
