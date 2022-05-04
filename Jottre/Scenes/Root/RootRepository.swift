protocol RootRepositoryProtocol {

    func getNavigationTitle() -> String
    func getAddNoteButtonTitle() -> String?
}

final class RootRepository: RootRepositoryProtocol {

    private let deviceEnvironmentDataSource: DeviceEnvironmentDataSourceProtocol
    private let localizableStringsDataSource: LocalizableStringsDataSourceProtocol

    init(
        deviceEnvironmentDataSource: DeviceEnvironmentDataSourceProtocol,
        localizableStringsDataSource: LocalizableStringsDataSourceProtocol
    ) {
        self.deviceEnvironmentDataSource = deviceEnvironmentDataSource
        self.localizableStringsDataSource = localizableStringsDataSource
    }

    func getNavigationTitle() -> String {
        localizableStringsDataSource.getText(identifier: "JTR.title")
    }

    func getAddNoteButtonTitle() -> String? {
        guard deviceEnvironmentDataSource.getIsReadOnly() == false else {
            return nil
        }

        return localizableStringsDataSource.getText(identifier: "JTR.AddNoteButton.title")
    }
}
