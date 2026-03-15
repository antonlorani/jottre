import UIKit

final class EditNoteCoordinator: NavigationCoordinator {

    private let navigation: Navigation

    init(navigation: Navigation) {
        self.navigation = navigation
    }

    func shouldHandle(deepLink: DeepLink) -> Bool {
        deepLink.path.hasPrefix(EditNoteDeepLink().path)
    }

    func handle(deepLink: DeepLink) -> [UIViewController] {
        [EditNoteViewController(viewModel: EditNoteViewModel(coordinator: self))]
    }
}
