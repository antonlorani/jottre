final class SettingsDropdownCellViewModel: PageCellViewModel {

    let name: String
    let current: SettingsDropdownBusinessModel.Option
    let options: [SettingsDropdownBusinessModel.Option]
    let onAction: @Sendable (SettingsDropdownBusinessModel.Option) -> Void

    init(
        name: String,
        current: SettingsDropdownBusinessModel.Option,
        options: [SettingsDropdownBusinessModel.Option],
        onAction: @Sendable @escaping (SettingsDropdownBusinessModel.Option) -> Void
    ) {
        self.name = name
        self.current = current
        self.options = options
        self.onAction = onAction
    }

    func handle(action: PageCellAction) {
        /* no-op */
    }
}
