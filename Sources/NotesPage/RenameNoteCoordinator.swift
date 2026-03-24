import UIKit

final class RenameNoteCoordinator: Coordinator {

    var onEnd: (() -> Void)?

    private let navigation: Navigation

    init(navigation: Navigation) {
        self.navigation = navigation
    }

    func start() {
        let alertController = UIAlertController(
            title: "Rename Note",
            message: nil,
            preferredStyle: .alert
        )
        alertController.addTextField { textField in
            textField.clearButtonMode = .whileEditing
        }
        alertController.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel
        ))
        alertController.addAction(UIAlertAction(
            title: "Rename",
            style: .default
        ) { [weak alertController] _ in
            // TODO: Apply rename with alertController?.textFields?.first?.text
        })
        navigation.present(alertController, animated: true)
    }
}
