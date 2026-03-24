import UIKit

final class RenameNoteCoordinator: Coordinator {

    var onEnd: (() -> Void)?

    private let navigation: Navigation

    init(navigation: Navigation) {
        self.navigation = navigation
    }

    func start() {
        let alertController = UIAlertController(
            title: L10n.Notes.Rename.title,
            message: nil,
            preferredStyle: .alert
        )
        alertController.addTextField { textField in
            textField.clearButtonMode = .whileEditing
        }
        alertController.addAction(UIAlertAction(
            title: L10n.Action.cancel,
            style: .cancel
        ))
        alertController.addAction(UIAlertAction(
            title: L10n.Action.rename,
            style: .default
        ) { _ in
            // TODO: Apply rename with alertController?.textFields?.first?.text
        })
        navigation.present(alertController, animated: true)
    }
}
