import UIKit

@MainActor
protocol NavigationCoordinator: Sendable {

    /// Whether this coordinator is capable of navigating to the given ``URL``.
    func shouldHandle(url: URL) -> Bool

    /// Performs the navigation action this coordinator provides for the given ``URL``.
    func handle(url: URL) -> [UIViewController]
}
