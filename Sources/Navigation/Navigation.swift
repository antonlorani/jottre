import UIKit

/// Defines navigation actions.
struct Navigation: Sendable {

    private let openDeepLinkProvider: @Sendable (_ deepLink: DeepLink) -> Void
    private let presentViewControllerProvider: @Sendable (_ viewController: UIViewController, _ animated: Bool) -> Void
    private let dismissViewControllerProvider: @Sendable (_ animated: Bool) -> Void

    init(
        openDeepLinkProvider: @Sendable @escaping (_ deepLink: DeepLink) -> Void,
        presentViewControllerProvider: @Sendable @escaping (_ viewController: UIViewController, _ animated: Bool) -> Void,
        dismissViewControllerProvider: @Sendable @escaping (_ animated: Bool) -> Void
    ) {
        self.openDeepLinkProvider = openDeepLinkProvider
        self.presentViewControllerProvider = presentViewControllerProvider
        self.dismissViewControllerProvider = dismissViewControllerProvider
    }

    func open(deepLink: DeepLink) {
        openDeepLinkProvider(deepLink)
    }

    func open<T: DeepLinkConvertible>(deepLink: T) {
        openDeepLinkProvider(deepLink.toDeepLink())
    }

    func present(_ viewController: UIViewController, animated: Bool) {
        presentViewControllerProvider(viewController, animated)
    }

    func dismiss(animated: Bool) {
        dismissViewControllerProvider(animated)
    }
}
