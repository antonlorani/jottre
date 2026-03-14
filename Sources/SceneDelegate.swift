import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private let rootCoordinator = RootCoordinator()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let url = connectionOptions.urlContexts.first?.url ?? URL(string: "https://www.jottre.com")!

        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()

        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.viewControllers = rootCoordinator.handleDeepLink(url)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        self.window = window
    }
}
