import UIKit

@MainActor
protocol PageCellViewModel: Sendable {

    func handle(action: PageCellAction)
    func handleContextMenuConfiguration() -> UIContextMenuConfiguration?
}

extension PageCellViewModel {

    func handleContextMenuConfiguration() -> UIContextMenuConfiguration? {
        nil
    }
}
