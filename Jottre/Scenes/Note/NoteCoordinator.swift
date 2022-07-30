import UIKit

final class NoteCoordinator: Coordinator {
    var release: CoordinatorReleaseClosure?

    private let navigationController: UINavigationController

    init(
        navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }

    func start() {
        let noteViewController = NoteViewController(
            viewModel: NoteViewModel(
                coordinator: self
            )
        )
        navigationController.pushViewController(noteViewController, animated: true)
    }

    func showExportNoteAlert(
        onPDFSelected: @escaping () -> Void,
        onJPGSelected: @escaping () -> Void,
        onPNGSelected: @escaping () -> Void
    ) {
        let alert = UIAlertController.makeExportNoteAlert(
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
        navigationController.present(alert, animated: true, completion: nil)
    }
}
