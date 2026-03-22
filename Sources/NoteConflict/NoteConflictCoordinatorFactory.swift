@MainActor
protocol NoteConflictCoordinatorFactory: Sendable {

    func make(navigation: Navigation) -> Coordinator
}

struct IOS18NoteConflictCoordinatorFactory: NoteConflictCoordinatorFactory {

    func make(navigation: Navigation) -> Coordinator {
        NoteConflictCoordinator(
            navigation: navigation,
            noteConflictViewControllerFactory: IOS18NoteConflictViewControllerFactory()
        )
    }
}

@available(iOS 26, *)
struct IOS26NoteConflictCoordinatorFactory: NoteConflictCoordinatorFactory {

    func make(navigation: Navigation) -> Coordinator {
        NoteConflictCoordinator(
            navigation: navigation,
            noteConflictViewControllerFactory: IOS26NoteConflictViewControllerFactory()
        )
    }
}
