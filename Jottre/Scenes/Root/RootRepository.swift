protocol RootRepositoryProtocol {

    func getNavigationTitle() -> String
    func getAddNoteButtonTitle() -> String?
}

final class RootRepository: RootRepositoryProtocol {

    private let deviceDataSource: DeviceDataSourceProtocol
    private let localizableStringsDataSource: LocalizableStringsDataSourceProtocol

    init(
        deviceDataSource: DeviceDataSourceProtocol,
        localizableStringsDataSource: LocalizableStringsDataSourceProtocol
    ) {
        self.deviceDataSource = deviceDataSource
        self.localizableStringsDataSource = localizableStringsDataSource
    }

    func getNavigationTitle() -> String {
        localizableStringsDataSource.getText(identifier: "Scene.Root.navigationTitle")
    }

    func getAddNoteButtonTitle() -> String? {
        guard deviceDataSource.getIsReadOnly() == false else {
            return nil
        }

        return localizableStringsDataSource.getText(identifier: "Scene.Root.BarButton.AddNote.title")
    }
}
