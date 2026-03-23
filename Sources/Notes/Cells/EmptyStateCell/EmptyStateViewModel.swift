final class EmptyStateCellViewModel: PageCellViewModel {

    let title: String

    init(title: String) {
        self.title = title
    }

    func handle(action: PageCellAction) {
        /* no-op */
    }
}
