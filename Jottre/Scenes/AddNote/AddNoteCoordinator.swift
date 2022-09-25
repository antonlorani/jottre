import UIKit
import Combine
import PencilKit

struct AddNoteCoordinator {

    private let navigationController: UINavigationController
    private let repository: AddNoteRepositoryProtocol

    init(
        navigationController: UINavigationController,
        repository: AddNoteRepositoryProtocol
    ) {
        self.navigationController = navigationController
        self.repository = repository
    }

    func startFlow() -> AnyPublisher<URL?, Never> {
        UIAlertController
            .makeAddNoteAlert(content: repository.getAddNoteAlert())
            .first()
            .receive(on: DispatchQueue.main)
            .flatMap { alertController, noteNamePublisher -> AnyPublisher<String?, Never> in
                navigationController.present(alertController, animated: true)
                return noteNamePublisher
            }
            .compactMap { name in
                guard let name = name else {
                    return nil
                }
                return repository.createNote(name: name)
            }
            .eraseToAnyPublisher()
    }
}
