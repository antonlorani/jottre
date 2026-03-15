@MainActor
protocol EditNoteCoordinatorFactory {

    func make(navigation: Navigation) -> NavigationCoordinator
}

struct IOS18EditNoteCoordinatorFactory: EditNoteCoordinatorFactory {

    func make(navigation: Navigation) -> NavigationCoordinator {
        EditNoteCoordinator(
            navigation: navigation,
            editNoteViewControllerFactory: IOS18EditNoteViewControllerFactory()
        )
    }
}

@available(iOS 26, *)
struct IOS26EditNoteCoordinatorFactory: EditNoteCoordinatorFactory {

    func make(navigation: Navigation) -> NavigationCoordinator {
        EditNoteCoordinator(
            navigation: navigation,
            editNoteViewControllerFactory: IOS26EditNoteViewControllerFactory()
        )
    }
}
