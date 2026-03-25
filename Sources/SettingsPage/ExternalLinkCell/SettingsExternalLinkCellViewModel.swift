final class SettingsExternalLinkCellViewModel: PageCellViewModel {

    let name: String
    let info: String?
    let onAction: @Sendable () -> Void

    init(
        name: String,
        info: String?,
        onAction: @Sendable @escaping () -> Void
    ) {
        self.name = name
        self.info = info
        self.onAction = onAction
    }

    func handle(action: PageCellAction) {
        switch action {
        case .tap: onAction()
        }
    }
}
