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
        appearance.configureWithDefaultBackground()

        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance

        let navigation = Navigation(
            openDeepLinkProvider: { [weak self] deepLink in
                Task { @MainActor in
                    self?.rootCoordinator?.handle(deepLink: deepLink)
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

        let url = connectionOptions.urlContexts.first?.url ?? URL(string: "https://www.jottre.com")!
        let deepLink = DeepLink(url: url)

        let notesCoordinatorFactory: NotesCoordinatorFactory = if #available(iOS 26, *) {
            IOS26NotesCoordinatorFactory()
        } else {
            IOS18NotesCoordinatorFactory()
        }

        let rootCoordinator = notesCoordinatorFactory.make(navigation: navigation)
        self.rootCoordinator = rootCoordinator
        navigationController.viewControllers = rootCoordinator.handle(deepLink: deepLink)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }
}
