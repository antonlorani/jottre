import UIKit
import Combine

extension UIAlertController {

    static func makeAddNoteAlert(
        content: AddNoteAlertContent
    ) -> AnyPublisher<(UIAlertController, AnyPublisher<String?, Never>), Never> {
        let noteNameSubject = PassthroughSubject<String?, Never>()
        let controller = UIAlertController(
            title: content.title,
            message: content.message,
            preferredStyle: .alert
        )
        controller.addTextField { textField in
            textField.placeholder = content.placeholder
        }
        controller.addAction(
            UIAlertAction(
                title: content.primaryActionTitle,
                style: .default,
                handler: { _ in
                    guard let text = controller.textFields?.first?.text else {
                        noteNameSubject.send(content.placeholder)
                        return
                    }

                    noteNameSubject.send(text.isEmpty ? content.placeholder : text)
                }
            )
        )
        controller.addAction(
            UIAlertAction(
                title: content.cancelActionTitle,
                style: .cancel,
                handler: { _ in
                    noteNameSubject.send(nil)
                }
            )
        )
        return Just((controller, noteNameSubject.eraseToAnyPublisher())).eraseToAnyPublisher()
    }
}
