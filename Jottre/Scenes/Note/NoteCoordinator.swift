import UIKit

final class NoteCoordinator: Coordinator {
    var release: CoordinatorReleaseClosure?

    private let navigationController: UINavigationController
    private let noteBusinessModel: NoteBusinessModel

    init(
        navigationController: UINavigationController,
        noteBusinessModel: NoteBusinessModel
    ) {
        self.navigationController = navigationController
        self.noteBusinessModel = noteBusinessModel
    }

    func start() {
        let noteViewController = NoteViewController(
            viewModel: NoteViewModel(
                coordinator: self,
                noteBusinessModel: noteBusinessModel
            )
        )
        navigationController.pushViewController(noteViewController, animated: true)
    }

    func showExportNoteAlert(
        onPDFSelected: @escaping () -> Void,
        onJPGSelected: @escaping () -> Void,
        onPNGSelected: @escaping () -> Void
    ) {
        let alertController = UIAlertController.makeExportNoteAlert(
            content: ExportNoteAlertContent(
                title: "Export note",
                cancelActionTitle: "Cancel",
                actions: [
                    ExportAction(
                        title: "PDF",
                        onSelect: onPDFSelected
                    ),
                    ExportAction(
                        title: "JPG",
                        onSelect: onJPGSelected
                    ),
                    ExportAction(
                        title: "PNG",
                        onSelect: onPNGSelected
                    )
                ]
            )
        )
        navigationController.present(alertController, animated: true, completion: nil)
    }
}
