protocol RootCoordinatorRepositoryProtocol {

    func getAddNoteAlert() -> AddNoteAlertContent
}

final class RootCoordinatorRepository: RootCoordinatorRepositoryProtocol {

    private let localizableStringsDataSource: LocalizableStringsDataSourceProtocol

    init(localizableStringsDataSource: LocalizableStringsDataSourceProtocol) {
        self.localizableStringsDataSource = localizableStringsDataSource
    }

    func getAddNoteAlert() -> AddNoteAlertContent {
        AddNoteAlertContent(
            title: localizableStringsDataSource.getText(identifier: "JTR.CreateNoteAlert.title"),
            message: localizableStringsDataSource.getText(identifier: "JTR.CreateNoteAlert.message"),
            placeholder: localizableStringsDataSource.getText(identifier: "JTR.Note.defaultName"),
            primaryActionTitle: localizableStringsDataSource.getText(identifier: "JTR.CreateNoteAlert.primaryActionTitle"),
            cancelActionTitle: localizableStringsDataSource.getText(identifier: "JTR.Alert.cancel")
        )
    }
}
