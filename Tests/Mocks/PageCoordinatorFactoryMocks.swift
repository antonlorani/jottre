import UIKit

@testable import Jottre

@MainActor
final class SettingsCoordinatorFactoryMock: SettingsCoordinatorFactoryProtocol {

    private let makeProvider: @MainActor (_ navigation: Navigation) -> Coordinator

    init(
        makeProvider: @MainActor @escaping (_ navigation: Navigation) -> Coordinator = { _ in CoordinatorMock() }
    ) {
        self.makeProvider = makeProvider
    }

    func make(navigation: Navigation) -> Coordinator {
        makeProvider(navigation)
    }
}

@MainActor
final class EnableCloudCoordinatorFactoryMock: EnableCloudCoordinatorFactoryProtocol {

    private let makeProvider: @MainActor (_ navigation: Navigation) -> Coordinator

    init(
        makeProvider: @MainActor @escaping (_ navigation: Navigation) -> Coordinator = { _ in CoordinatorMock() }
    ) {
        self.makeProvider = makeProvider
    }

    func make(navigation: Navigation) -> Coordinator {
        makeProvider(navigation)
    }
}

@MainActor
final class EditJotCoordinatorFactoryMock: EditJotCoordinatorFactoryProtocol {

    private let makeProvider: @MainActor (_ navigation: Navigation) -> NavigationCoordinator

    init(
        makeProvider:
            @MainActor @escaping (_ navigation: Navigation) -> NavigationCoordinator = { _ in
                NavigationCoordinatorMock()
            }
    ) {
        self.makeProvider = makeProvider
    }

    func make(navigation: Navigation) -> NavigationCoordinator {
        makeProvider(navigation)
    }
}

@MainActor
final class CloudMigrationCoordinatorFactoryMock: CloudMigrationCoordinatorFactoryProtocol {

    private let makeProvider: @MainActor (_ navigation: Navigation) -> CloudMigrationCoordinatorProtocol

    init(
        makeProvider: @MainActor @escaping (_ navigation: Navigation) -> CloudMigrationCoordinatorProtocol = { _ in
            CloudMigrationCoordinatorMock()
        }
    ) {
        self.makeProvider = makeProvider
    }

    func make(navigation: Navigation) -> CloudMigrationCoordinatorProtocol {
        makeProvider(navigation)
    }
}

@MainActor
final class NavigationCoordinatorMock: NavigationCoordinator {

    private let shouldHandleProvider: (_ url: URL) -> Bool
    private let handleProvider: (_ url: URL) -> [UIViewController]

    init(
        shouldHandleProvider: @escaping (_ url: URL) -> Bool = { _ in false },
        handleProvider: @escaping (_ url: URL) -> [UIViewController] = { _ in [] }
    ) {
        self.shouldHandleProvider = shouldHandleProvider
        self.handleProvider = handleProvider
    }

    func shouldHandle(url: URL) -> Bool {
        shouldHandleProvider(url)
    }

    func handle(url: URL) -> [UIViewController] {
        handleProvider(url)
    }
}
