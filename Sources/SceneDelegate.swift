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
            dismissViewControllerProvider: { [weak navigationController] animated, completion in
                Task { @MainActor in
                    navigationController?.dismiss(animated: animated, completion: completion)
                }
            },
            popViewControllerProvider: { [weak navigationController] animated in
                Task { @MainActor in
                    navigationController?.popViewController(animated: animated)
                }
            }
        )

        let url =
            if let url = connectionOptions.urlContexts.first?.url {
                url
            } else {
                JotsPageURL().toURL()
            }

        let fileManager = FileManager.default
        let localFileService = LocalFileService(
            fileManager: fileManager
        )
        let ubiquitousFileService = UbiquitousFileService(
            fileManager: fileManager,
            localFileService: localFileService
        )
        let fileConflictService = FileConflictService(fileManager: fileManager)
        let bundleService = BundleService(bundle: .main)
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

        let defaultsService = DefaultsService(userDefaults: .standard)

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

        let editJotRepository = EditJotRepository(
            ubiquitousFileService: ubiquitousFileService,
            jotFileService: jotFileService,
            jotFileConflictService: jotFileConflictService
        )

        let jotsCoordinatorFactory: JotsCoordinatorFactoryProtocol = JotsCoordinatorFactory(
            jotsViewControllerFactory: JotsViewControllerFactory(
                repository: JotsRepository(
                    ubiquitousFileService: ubiquitousFileService,
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
                        defaultsService: defaultsService
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
            editJotCoordinatorFactory: EditJotCoordinatorFactory(
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
                deleteJotCoordinatorFactory: deleteJotCoordinatorFactory
            ),
            cloudMigrationCoordinatorFactory: CloudMigrationCoordinatorFactory(
                repository: CloudMigrationRepository(
                    ubiquitousFileService: ubiquitousFileService,
                    jotFileService: jotFileService,
                    jotFilePreviewImageService: jotFilePreviewImageService,
                    defaultsService: defaultsService
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
            )
        )

        let rootCoordinator = RootCoordinator(
            navigation: navigation,
            jotsCoordinatorFactory: jotsCoordinatorFactory
        )
        self.rootCoordinator = rootCoordinator
        navigationController.viewControllers = rootCoordinator.handle(url: url)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }
}
