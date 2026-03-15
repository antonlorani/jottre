import UIKit

final class RootCoordinator: NavigationCoordinator {

    private lazy var externalLinkNavigationCoordinator = ExternalLinkNavigationCoordinator()
    private lazy var notesCoordinator = notesCoordinatorFactory.make(navigation: navigation)
    
    private let navigation: Navigation
    private let notesCoordinatorFactory: NotesCoordinatorFactory
    
    init(
        navigation: Navigation,
        notesCoordinatorFactory: NotesCoordinatorFactory
    ) {
        self.navigation = navigation
        self.notesCoordinatorFactory = notesCoordinatorFactory
    }
    
    func shouldHandle(url: URL) -> Bool {
        true
    }

    func handle(url: URL) -> [UIViewController] {
        var viewControllers = [UIViewController]()
        viewControllers.append(contentsOf: notesCoordinator.handle(url: url))

        if externalLinkNavigationCoordinator.shouldHandle(url: url) {
            viewControllers.append(contentsOf: externalLinkNavigationCoordinator.handle(url: url))
        }

        return viewControllers
    }
}
