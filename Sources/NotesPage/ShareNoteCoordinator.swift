import UIKit

enum ShareFormat {
    case pdf, jpg, png
}

final class ShareNoteCoordinator: Coordinator {

    var onEnd: (() -> Void)?

    private let navigation: Navigation
    private let format: ShareFormat

    init(
        navigation: Navigation,
        format: ShareFormat
    ) {
        self.navigation = navigation
        self.format = format
    }

    func start() {
        let activityViewController = UIActivityViewController(
            activityItems: [],
            applicationActivities: nil
        )
        navigation.present(activityViewController, animated: true)
    }
}
