import UIKit

final class DeleteNoteCoordinator: Coordinator {

    var onEnd: (() -> Void)?

    private let navigation: Navigation

    init(navigation: Navigation) {
        self.navigation = navigation
    }

    func start() {
        let alertController = UIAlertController(
            title: "Delete Note",
            message: "Are you sure you want to delete this note? This action cannot be undone.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel
        ))
        alertController.addAction(UIAlertAction(
            title: "Delete",
            style: .destructive
        ) { [weak self] _ in
            self?.navigation.dismiss(animated: true)
            //            self?.onEnd()
        })
        navigation.present(alertController, animated: true)
    }
}
