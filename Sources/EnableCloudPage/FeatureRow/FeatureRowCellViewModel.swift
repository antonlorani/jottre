final class FeatureRowCellViewModel: PageCellViewModel {
    let systemImageName: String
    let text: String

    init(
        systemImageName: String,
        text: String
    ) {
        self.systemImageName = systemImageName
        self.text = text
    }

    func handle(action: PageCellAction) {
        /* no-op */
    }
}
