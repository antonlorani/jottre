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
            dismissViewControllerProvider: { [weak navigationController] animated in
                Task { @MainActor in
                    navigationController?.dismiss(animated: animated)
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
                CloudMigrationURL().toURL()
            }

        let fileManager = FileManager.default
        let fileService = FileService(fileManager: fileManager)
        let fileConflictService = FileConflictService(fileManager: fileManager)
        let jotFileService = JotFileService(fileService: fileService)
        let jotFileConflictService = JotFileConflictService(
            fileService: fileService,
            fileConflictService: fileConflictService
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

        let jotsCoordinatorFactory: JotsCoordinatorFactoryProtocol = JotsCoordinatorFactory(
            jotsViewControllerFactory: JotsViewControllerFactory(
                repository: JotsRepository(
                    jotFileService: jotFileService,
                    fileService: fileService
                ),
                menuConfigurationFactory: menuConfigurationFactory,
                textBarButtonItemFactory: textBarButtonItemFactory,
                symbolBarButtonItemFactory: symbolBarButtonItemFactory
            ),
            settingsCoordinatorFactory: SettingsCoordinatorFactory(
                settingsViewControllerFactory: SettingsViewControllerFactory(
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
                editJotViewControllerFactory: EditJotViewControllerFactory(
                    repository: EditJotRepository(
                        jotFileService: jotFileService,
                        jotFileConflictService: jotFileConflictService
                    ),
                    menuConfigurationFactory: menuConfigurationFactory,
                    symbolBarButtonItemFactory: symbolBarButtonItemFactory
                ),
                jotConflictCoordinatorFactory: JotConflictCoordinatorFactory(
                    jotConflictViewControllerFactory: JotConflictViewControllerFactory(
                        textBarButtonItemFactory: textBarButtonItemFactory,
                        symbolBarButtonItemFactory: symbolBarButtonItemFactory
                    )
                ),
                renameJotCoordinatorFactory: RenameJotCoordinatorFactory(
                    repository: RenameJotRepository(
                        fileService: fileService
                    )
                )
            ),
            cloudMigrationCoordinatorFactory: CloudMigrationCoordinatorFactory(
                cloudMigrationViewControllerFactory: CloudMigrationViewControllerFactory(
                    textBarButtonItemFactory: textBarButtonItemFactory,
                    symbolBarButtonItemFactory: symbolBarButtonItemFactory
                )
            ),
            createJotCoordinatorFactory: CreateJotCoordinatorFactory(
                repository: CreateJotRepository(
                    fileService: fileService,
                    jotFileService: jotFileService
                )
            ),
            deleteJotCoordinatorFactory: DeleteJotCoordinatorFactory(
                repository: DeleteJotRepository(
                    fileService: fileService
                )
            ),
            renameJotCoordinatorFactory: RenameJotCoordinatorFactory(
                repository: RenameJotRepository(
                    fileService: fileService
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
