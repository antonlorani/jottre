final class PageHeaderCellViewModel: PageCellViewModel {
    let headline: String
    let subheadline: String

    init(
        headline: String,
        subheadline: String
    ) {
        self.headline = headline
        self.subheadline = subheadline
    }

    func handle(action: PageCellAction) {
        /* no-op */
    }
}
