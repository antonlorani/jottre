final class SettingsToggleCellViewModel: PageCellViewModel {

    let name: String
    let isOn: Bool

    init(name: String, isOn: Bool) {
        self.name = name
        self.isOn = isOn
    }

    func handle(action: PageCellAction) {
        /* no-op */
    }
}
