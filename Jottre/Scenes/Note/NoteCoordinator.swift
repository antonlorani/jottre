import UIKit

final class NoteCoordinator: Coordinator {
    var release: CoordinatorReleaseClosure?

    private let defaults: DefaultsProtocol
    private let localFileDataSource: LocalFileDataSource
    private let remoteFileDataSource: RemoteFileDataSource
    private let navigationController: UINavigationController
    private let url: URL

    init(
        defaults: DefaultsProtocol,
        localFileDataSource: LocalFileDataSource,
        remoteFileDataSource: RemoteFileDataSource,
        navigationController: UINavigationController,
        url: URL
    ) {
        self.defaults = defaults
        self.localFileDataSource = localFileDataSource
        self.remoteFileDataSource = remoteFileDataSource
        self.navigationController = navigationController
        self.url = url
    }

    func start() {
        let noteViewController = NoteViewController(
            viewModel: NoteViewModel(
                noteDataSource: NoteFileDataSource(
                    defaults: defaults,
                    localFileDataSource: localFileDataSource,
                    remoteFileDataSource: remoteFileDataSource
                ),
                coordinator: self,
                url: url
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
