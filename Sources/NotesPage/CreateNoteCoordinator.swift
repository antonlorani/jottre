import UIKit

final class CreateNoteCoordinator: Coordinator {
    
    var onEnd: (() -> Void)?
    
    private let navigation: Navigation
    
    init(navigation: Navigation) {
        self.navigation = navigation
    }
    
    func start() {
        let alertController = UIAlertController(
            title: L10n.Notes.Create.title,
            message: nil,
            preferredStyle: .alert
        )
        alertController.addTextField { textField in
            textField.placeholder = L10n.Notes.Create.namePlaceholder
            textField.autocapitalizationType = .sentences
            textField.returnKeyType = .done
        }

        let createAction = UIAlertAction(
            title: L10n.Action.create,
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
            title: L10n.Action.cancel,
            style: .cancel
        )
        alertController.addAction(cancelAction)
        
        navigation.present(alertController, animated: true)
    }
}
