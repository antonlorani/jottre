final class SettingsInfoCellViewModel: PageCellViewModel {

    let name: String
    let value: String

    init(name: String, value: String) {
        self.name = name
        self.value = value
    }

    func handle(action: PageCellAction) {
        /* no-op */
    }
}
