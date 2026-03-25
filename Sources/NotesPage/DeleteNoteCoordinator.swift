import UIKit

final class DeleteNoteCoordinator: Coordinator {

    var onEnd: (() -> Void)?

    private let navigation: Navigation

    init(navigation: Navigation) {
        self.navigation = navigation
    }

    func start() {
        let alertController = UIAlertController(
            title: L10n.Notes.Delete.title,
            message: L10n.Notes.Delete.message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(
            title: L10n.Action.cancel,
            style: .cancel
        ))
        alertController.addAction(UIAlertAction(
            title: L10n.Action.delete,
            style: .destructive
        ) { [weak self] _ in
            self?.navigation.dismiss(animated: true)
            //            self?.onEnd()
        })
        navigation.present(alertController, animated: true)
    }
}
