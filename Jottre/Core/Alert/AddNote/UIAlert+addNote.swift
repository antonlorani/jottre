import UIKit

extension UIAlertController {

    static func makeAddNoteAlert(
        content: AddNoteAlertContent,
        onSubmit: @escaping (String) -> Void
    ) -> UIAlertController {
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
                        onSubmit(content.placeholder)
                        return
                    }

                    onSubmit(text.isEmpty ? content.placeholder : text)
                }
            )
        )
        controller.addAction(
            UIAlertAction(
                title: content.cancelActionTitle,
                style: .cancel,
                handler: nil
            )
        )
        return controller
    }
}
