import UIKit

@MainActor
protocol NavigationCoordinator: Sendable {

    /// Whether this coordinator is capable of navigating to the given ``DeepLink``.
    func shouldHandle(deepLink: DeepLink) -> Bool

    /// Performs the navigation action this coordinator provides for the given ``DeepLink``.
    func handle(deepLink: DeepLink) -> [UIViewController]
}
