import UIKit

/// Defines navigation actions.
struct Navigation: Sendable {

    private let openURLProvider: @Sendable (_ url: URL) -> Void
    private let presentViewControllerProvider: @Sendable (
        _ viewController: UIViewController,
        _ animated: Bool
    ) -> Void
    private let dismissViewControllerProvider: @Sendable (_ animated: Bool) -> Void

    init(
        openURLProvider: @Sendable @escaping (_ url: URL) -> Void,
        presentViewControllerProvider: @Sendable @escaping (
            _ viewController: UIViewController,
            _ animated: Bool
        ) -> Void,
        dismissViewControllerProvider: @Sendable @escaping (_ animated: Bool) -> Void
    ) {
        self.openURLProvider = openURLProvider
        self.presentViewControllerProvider = presentViewControllerProvider
        self.dismissViewControllerProvider = dismissViewControllerProvider
    }

    func open(url: URL) {
        openURLProvider(url)
    }

    func open<T: URLConvertible>(url: T) {
        openURLProvider(url.toURL())
    }

    func present(_ viewController: UIViewController, animated: Bool) {
        presentViewControllerProvider(viewController, animated)
    }

    func dismiss(animated: Bool) {
        dismissViewControllerProvider(animated)
    }
}
