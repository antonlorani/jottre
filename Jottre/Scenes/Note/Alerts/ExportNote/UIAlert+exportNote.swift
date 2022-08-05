import UIKit

extension UIAlertController {

    static func makeExportNoteAlert(
        content: ExportNoteAlertContent
    ) -> UIAlertController {
        let controller = UIAlertController(
            title: content.title,
            message: nil,
            preferredStyle: .actionSheet
        )

        content
            .actions
            .forEach { action in
                controller.addAction(
                    UIAlertAction(
                        title: action.title,
                        style: .default,
                        handler: { _ in
                            action.onSelect()
                        }
                    )
                )
            }
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
