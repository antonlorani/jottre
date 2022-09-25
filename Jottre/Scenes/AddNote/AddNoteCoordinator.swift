import UIKit
import Combine
import PencilKit

final class AddNoteCoordinator {

    private let navigationController: UINavigationController
    private let repository: AddNoteRepositoryProtocol

    init(
        navigationController: UINavigationController,
        repository: AddNoteRepositoryProtocol
    ) {
        self.navigationController = navigationController
        self.repository = repository
    }

    func startFlow() -> AnyPublisher<NoteBusinessModel?, Never> {
        UIAlertController
            .makeAddNoteAlert(content: repository.getAddNoteAlert())
            .first()
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] alertController, noteNamePublisher in
                self?.navigationController.present(alertController, animated: true, completion: nil)
                return noteNamePublisher
            }
            // TODO: Evaluate noteName availability
            .map { noteName -> NoteBusinessModel? in
                guard let noteName = noteName else {
                    return nil
                }
                return NoteBusinessModel(
                    name: noteName,
                    note: Note(drawing: PKDrawing())
                )
            }
            .eraseToAnyPublisher()
    }
}
