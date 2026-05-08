import UIKit

@testable import Jottre

extension Navigation {

    static func test(
        openURLProvider: @Sendable @escaping (_ url: URL) -> Void = { _ in },
        openExternalURLProvider: @Sendable @escaping (_ url: URL) -> Void = { _ in },
        openSceneProvider: @Sendable @escaping (_ url: URL) -> Void = { _ in },
        presentViewControllerProvider:
            @Sendable @escaping (_ viewController: UIViewController, _ animated: Bool) -> Void = { _, _ in },
        dismissViewControllerProvider:
            @Sendable @escaping (_ animated: Bool, _ completion: (@Sendable () -> Void)?) -> Void = { _, _ in },
        popViewControllerProvider: @Sendable @escaping (_ animated: Bool) -> Void = { _ in },
        getViewControllersProvider: @MainActor @escaping () -> [UIViewController] = { [] }
    ) -> Navigation {
        Navigation(
            openURLProvider: openURLProvider,
            openExternalURLProvider: openExternalURLProvider,
            openSceneProvider: openSceneProvider,
            presentViewControllerProvider: presentViewControllerProvider,
            dismissViewControllerProvider: dismissViewControllerProvider,
            popViewControllerProvider: popViewControllerProvider,
            getViewControllersProvider: getViewControllersProvider
        )
    }
}
