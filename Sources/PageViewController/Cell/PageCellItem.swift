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
