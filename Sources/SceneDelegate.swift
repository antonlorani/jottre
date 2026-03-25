import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var rootCoordinator: NavigationCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
#if targetEnvironment(macCatalyst)
        windowScene.title = "Jottre"
#endif

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()

        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.tintColor = .label

        let navigation = Navigation(
            openURLProvider: { [weak self] url in
                Task { @MainActor in
                    guard let viewControllers = self?.rootCoordinator?.handle(url: url) else {
                        return
                    }
                    navigationController.setViewControllers(viewControllers, animated: true)
                }
            },
            presentViewControllerProvider: { [weak navigationController] viewController, animated in
                Task { @MainActor in
                    navigationController?.present(viewController, animated: animated)
                }
            },
            dismissViewControllerProvider: { [weak navigationController] animated in
                Task { @MainActor in
                    navigationController?.dismiss(animated: animated)
                }
            }
        )

        let url = if let url = connectionOptions.urlContexts.first?.url {
            url
        } else {
            CloudMigrationURL().toURL()
        }

        let notesCoordinatorFactory: NotesCoordinatorFactory = if #available(iOS 26, *) {
            IOS26NotesCoordinatorFactory()
        } else {
            IOS18NotesCoordinatorFactory()
        }

        let rootCoordinator = RootCoordinator(
            navigation: navigation,
            notesCoordinatorFactory: notesCoordinatorFactory
        )
        self.rootCoordinator = rootCoordinator
        navigationController.viewControllers = rootCoordinator.handle(url: url)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }
}
