protocol RootRepositoryProtocol {

    func getInfoText() -> String
    func getNavigationTitle() -> String
    func getAddNoteButtonTitle() -> String?
}

final class RootRepository: RootRepositoryProtocol {

    private let deviceDataSource: DeviceDataSourceProtocol
    private let localizableStringsDataSource: LocalizableStringsDataSourceProtocol
    private let infoTextRepository: InfoTextViewRepositoryProtocol

    init(
        deviceDataSource: DeviceDataSourceProtocol,
        localizableStringsDataSource: LocalizableStringsDataSourceProtocol,
        infoTextRepository: InfoTextViewRepositoryProtocol
    ) {
        self.deviceDataSource = deviceDataSource
        self.localizableStringsDataSource = localizableStringsDataSource
        self.infoTextRepository = infoTextRepository
    }

    func getInfoText() -> String {
        infoTextRepository.getText()
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
