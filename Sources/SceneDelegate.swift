/*
 Jottre: Minimalistic jotting for iPhone, iPad and Mac.
 Copyright (C) 2021-2026 Anton Lorani

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private static let defaultsService = DefaultsService(userDefaults: .standard)

    #if targetEnvironment(macCatalyst)
    private lazy var appKitPluginService = MacCatalystAppKitPluginService(bundle: .main)
    #endif

    var window: UIWindow?

    private var sceneCoordinator: SceneCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        #if targetEnvironment(macCatalyst)
        windowScene.title = L10n.App.title
        #endif

        let fileManager = FileManager.default
        let localFileService = LocalFileService(
            fileManager: fileManager
        )
        let ubiquitousFileService = UbiquitousFileService(
            fileManager: fileManager,
            localFileService: localFileService
        )
        let fileConflictService = FileConflictService(
            fileManager: fileManager
        )
        let bundleService = BundleService(
            bundle: .main
        )
        let jotFileService = JotFileService(
            localFileService: localFileService,
            ubiquitousFileService: ubiquitousFileService
        )
        let jotFileConflictService = JotFileConflictService(
            fileConflictService: fileConflictService
        )
        let jotFilePreviewImageService = CachedJotFilePreviewImageService(
            localFileService: localFileService,
            jotFilePreviewImageService: JotFilePreviewImageService(
                jotFileService: jotFileService
            )
        )
        let applicationService = ApplicationService(
            application: .shared
        )
        let deviceService = DeviceService(
            device: .current
        )

        let textBarButtonItemFactory: TextBarButtonItemFactory
        let symbolBarButtonItemFactory: SymbolBarButtonItemFactory

        if #available(iOS 26, *) {
            textBarButtonItemFactory = IOS26TextBarButtonItemFactory()
            symbolBarButtonItemFactory = IOS26SymbolBarButtonItemFactory()
        } else {
            textBarButtonItemFactory = IOS18TextBarButtonItemFactory()
            symbolBarButtonItemFactory = IOS18SymbolBarButtonItemFactory()
        }

        let menuConfigurationFactory = JotMenuConfigurationFactory()

        let deleteJotCoordinatorFactory = DeleteJotCoordinatorFactory(
            repository: DeleteJotRepository(
                jotFileService: jotFileService
            )
        )

        let shareJotCoordinatorFactory = ShareJotCoordinatorFactory(
            repository: ShareJotRepository(
                jotFileService: jotFileService
            )
        )

        let revealFileCoordinatorFactory = RevealFileCoordinatorFactory(
            applicationService: applicationService
        )

        let editJotRepository = EditJotRepository(
            ubiquitousFileService: ubiquitousFileService,
            jotFileService: jotFileService,
            jotFileConflictService: jotFileConflictService
        )

        let editJotCoordinatorFactory = EditJotCoordinatorFactory(
            repository: editJotRepository,
            editJotViewControllerFactory: EditJotViewControllerFactory(
                repository: editJotRepository,
                menuConfigurationFactory: menuConfigurationFactory,
                symbolBarButtonItemFactory: symbolBarButtonItemFactory
            ),
            jotConflictCoordinatorFactory: JotConflictCoordinatorFactory(
                jotConflictViewControllerFactory: JotConflictViewControllerFactory(
                    textBarButtonItemFactory: textBarButtonItemFactory,
                    symbolBarButtonItemFactory: symbolBarButtonItemFactory
                ),
                repository: JotConflictRepository(
                    jotFileConflictService: jotFileConflictService,
                    jotFilePreviewImageService: jotFilePreviewImageService
                )
            ),
            renameJotCoordinatorFactory: RenameJotCoordinatorFactory(
                repository: RenameJotRepository(
                    jotFileService: jotFileService
                )
            ),
            deleteJotCoordinatorFactory: deleteJotCoordinatorFactory,
            shareJotCoordinatorFactory: shareJotCoordinatorFactory,
            revealFileCoordinatorFactory: revealFileCoordinatorFactory
        )

        let jotsCoordinatorFactory: JotsCoordinatorFactoryProtocol = JotsCoordinatorFactory(
            jotsViewControllerFactory: JotsViewControllerFactory(
                repository: JotsRepository(
                    ubiquitousFileService: ubiquitousFileService,
                    applicationService: applicationService,
                    deviceService: deviceService,
                    jotFileService: jotFileService,
                    jotFilePreviewImageService: jotFilePreviewImageService
                ),
                menuConfigurationFactory: menuConfigurationFactory,
                textBarButtonItemFactory: textBarButtonItemFactory,
                symbolBarButtonItemFactory: symbolBarButtonItemFactory
            ),
            settingsCoordinatorFactory: SettingsCoordinatorFactory(
                settingsViewControllerFactory: SettingsViewControllerFactory(
                    repository: SettingsRepository(
                        ubiquitousFileService: ubiquitousFileService,
                        bundleService: bundleService,
                        defaultsService: Self.defaultsService
                    ),
                    textBarButtonItemFactory: textBarButtonItemFactory,
                    symbolBarButtonItemFactory: symbolBarButtonItemFactory
                )
            ),
            enableCloudCoordinatorFactory: EnableCloudCoordinatorFactory(
                enableCloudViewControllerFactory: EnableCloudViewControllerFactory(
                    textBarButtonItemFactory: textBarButtonItemFactory,
                    symbolBarButtonItemFactory: symbolBarButtonItemFactory
                )
            ),
            editJotCoordinatorFactory: editJotCoordinatorFactory,
            cloudMigrationCoordinatorFactory: CloudMigrationCoordinatorFactory(
                repository: CloudMigrationRepository(
                    ubiquitousFileService: ubiquitousFileService,
                    jotFileService: jotFileService,
                    jotFilePreviewImageService: jotFilePreviewImageService,
                    defaultsService: Self.defaultsService
                ),
                cloudMigrationViewControllerFactory: CloudMigrationViewControllerFactory(
                    textBarButtonItemFactory: textBarButtonItemFactory,
                    symbolBarButtonItemFactory: symbolBarButtonItemFactory
                )
            ),
            createJotCoordinatorFactory: CreateJotCoordinatorFactory(
                repository: CreateJotRepository(
                    localFileService: localFileService,
                    ubiquitousFileService: ubiquitousFileService,
                    jotFileService: jotFileService
                )
            ),
            deleteJotCoordinatorFactory: deleteJotCoordinatorFactory,
            renameJotCoordinatorFactory: RenameJotCoordinatorFactory(
                repository: RenameJotRepository(
                    jotFileService: jotFileService
                )
            ),
            shareJotCoordinatorFactory: shareJotCoordinatorFactory,
            revealFileCoordinatorFactory: revealFileCoordinatorFactory
        )

        let rootCoordinatorFactory = RootCoordinatorFactory(
            jotsCoordinatorFactory: jotsCoordinatorFactory
        )

        let navigationController = makeNavigationController()

        let navigation = Navigation(
            openURLProvider: { [weak self, weak navigationController] url in
                Task { @MainActor in
                    guard let viewControllers = self?.sceneCoordinator?.handle(url: url) else {
                        return
                    }
                    navigationController?.setViewControllers(viewControllers, animated: true)
                }
            },
            openExternalURLProvider: { url in
                Task { @MainActor in
                    guard applicationService.canOpen(url: url) else {
                        return
                    }
                    applicationService.open(url: url)
                }
            },
            openSceneProvider: { [weak self] url in
                Task { @MainActor in
                    self?.sceneCoordinator?.openScene(url: url)
                }
            },
            presentViewControllerProvider: { [weak navigationController] viewController, animated in
                Task { @MainActor in
                    navigationController?.present(viewController, animated: animated)
                }
            },
            dismissViewControllerProvider: { [weak navigationController] animated, completion in
                Task { @MainActor in
                    navigationController?.dismiss(animated: animated, completion: completion)
                }
            },
            popViewControllerProvider: { [weak self, weak navigationController] animated in
                Task { @MainActor in
                    navigationController?.popViewController(animated: animated)
                    self?.sceneCoordinator?.handlePop()
                }
            },
            getViewControllersProvider: { [weak navigationController] in
                navigationController?.viewControllers ?? []
            }
        )

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        self.window = window

        let sceneCoordinator = SceneCoordinator(
            navigation: navigation,
            defaultsService: Self.defaultsService,
            applicationService: applicationService,
            ubiquitousFileService: ubiquitousFileService,
            rootCoordinatorFactory: rootCoordinatorFactory,
            editJotCoordinatorFactory: editJotCoordinatorFactory,
            onUpdateUserInterfaceStyle: { [weak window] userInterfaceStyle in
                Task { @MainActor in
                    window?.overrideUserInterfaceStyle = userInterfaceStyle
                }
            },
            requestSceneSessionActivationProvider: { url in
                Task { @MainActor in
                    let activity = NSUserActivity(
                        activityType: SceneCoordinator.Constants.activityType
                    )
                    activity.userInfo = [SceneCoordinator.Constants.urlKey: url.absoluteString]
                    UIApplication.shared.requestSceneSessionActivation(
                        nil,
                        userActivity: activity,
                        options: nil,
                        errorHandler: nil
                    )
                }
            }
        )
        self.sceneCoordinator = sceneCoordinator
        navigationController.viewControllers = sceneCoordinator.handle(
            session: session,
            connectionOptions: connectionOptions
        )

        window.makeKeyAndVisible()
    }

    #if targetEnvironment(macCatalyst)
    func sceneDidDisconnect(_ scene: UIScene) {
        guard UIApplication.shared.connectedScenes.isEmpty,
            let appKitPluginService
        else {
            return
        }
        appKitPluginService.terminate()
    }
    #endif

    func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        sceneCoordinator?.handleURLContexts(urlContexts: URLContexts)
    }

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        sceneCoordinator?.makeStateRestorationActivity()
    }

    private func makeNavigationController() -> UINavigationController {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()

        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.tintColor = .label
        return navigationController
    }
}
