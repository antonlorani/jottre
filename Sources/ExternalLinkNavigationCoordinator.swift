import UIKit

final class ExternalLinkNavigationCoordinator: NavigationCoordinator {

    func shouldHandle(url: URL) -> Bool {
        (url.scheme == "https" || url.scheme == "http") && UIApplication.shared.canOpenURL(url)
    }

    func handle(url: URL) -> [UIViewController] {
        UIApplication.shared.open(url)
        return []
    }
}
