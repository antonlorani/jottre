import Foundation

protocol AddNoteRepositoryProtocol {

    func getAddNoteAlert() -> AddNoteAlertContent
    func createNote(name: String) -> URL?
}

final class AddNoteRepository: AddNoteRepositoryProtocol {

    private let localizableStringsDataSource: LocalizableStringsDataSourceProtocol
    private let noteDataSource: NoteFileDataSource

    init(
        localizableStringsDataSource: LocalizableStringsDataSourceProtocol,
        noteDataSource: NoteFileDataSource
    ) {
        self.localizableStringsDataSource = localizableStringsDataSource
        self.noteDataSource = noteDataSource
    }

    func createNote(name: String) -> URL? {
        noteDataSource.createNote(name: name)
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
