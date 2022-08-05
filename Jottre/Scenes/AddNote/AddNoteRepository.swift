protocol AddNoteRepositoryProtocol {

    func getAddNoteAlert() -> AddNoteAlertContent
}

final class AddNoteRepository: AddNoteRepositoryProtocol {

    private let localizableStringsDataSource: LocalizableStringsDataSourceProtocol

    init(localizableStringsDataSource: LocalizableStringsDataSourceProtocol) {
        self.localizableStringsDataSource = localizableStringsDataSource
    }

    func getAddNoteAlert() -> AddNoteAlertContent {
        AddNoteAlertContent(
            title: localizableStringsDataSource.getText(identifier: "Alert.CreateNoteAlert.title"),
            message: localizableStringsDataSource.getText(identifier: "Alert.CreateNoteAlert.message"),
            placeholder: localizableStringsDataSource.getText(identifier: "Defaults.Note.name"),
            primaryActionTitle: localizableStringsDataSource.getText(identifier: "Alert.CreateNoteAlert.primaryActionTitle"),
            cancelActionTitle: localizableStringsDataSource.getText(identifier: "Alert.Default.cancel")
        )
    }
}
