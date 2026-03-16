import UIKit

final class CreateNoteCoordinator: NavigationCoordinator {

    private let navigation: Navigation

    init(navigation: Navigation) {
        self.navigation = navigation
    }

    func shouldHandle(url: URL) -> Bool {
        url.path.hasPrefix(CreateNoteURL().path)
    }

    func handle(url: URL) -> [UIViewController] {
        let alertController = UIAlertController(
            title: "New Jot",
            message: nil,
            preferredStyle: .alert
        )
        alertController.addTextField { textField in
            textField.placeholder = "Name"
            textField.autocapitalizationType = .sentences
            textField.returnKeyType = .done
        }

        let createAction = UIAlertAction(
            title: "Create",
            style: .default
        ) { [weak self] _ in
            guard
                let self,
                let title = alertController.textFields?.first?.text,
                !title.isEmpty
            else {
                return
            }
            navigation.open(url: EditNoteURL().toURL())
        }
        alertController.addAction(createAction)

        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel
        )
        alertController.addAction(cancelAction)

        navigation.present(alertController, animated: true)
        return []
    }
}
