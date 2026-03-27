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

        let fileService = FileService(fileManager: .default)
        let fileConflictService = FileConflictService(fileManager: .default)
        let jotFileService = JotFileService(fileService: fileService)
        let jotFileConflictService = JotFileConflictService(
            fileService: fileService,
            fileConflictService: fileConflictService
        )
        let jotsRepository = JotsRepository(
            jotFileService: jotFileService,
            fileService: fileService
        )
        let editJotRepository = EditJotRepository(
            jotFileService: jotFileService,
            jotFileConflictService: jotFileConflictService
        )
        let createJotRepository = CreateJotRepository(
            fileService: fileService,
            jotFileService: jotFileService
        )
        let deleteJotRepository = DeleteJotRepository(
            fileService: fileService
        )
        let renameJotRepository = RenameJotRepository(
            fileService: fileService
        )

        let jotsCoordinatorFactory: JotsCoordinatorFactory =
            if #available(iOS 26, *) {
                IOS26JotsCoordinatorFactory(
                    jotsRepository: jotsRepository,
                    editJotRepository: editJotRepository,
                    createJotRepository: createJotRepository,
                    deleteJotRepository: deleteJotRepository,
                    renameJotRepository: renameJotRepository
                )
            } else {
                IOS18JotsCoordinatorFactory(
                    jotsRepository: jotsRepository,
                    editJotRepository: editJotRepository,
                    createJotRepository: createJotRepository,
                    deleteJotRepository: deleteJotRepository,
                    renameJotRepository: renameJotRepository
                )
            }

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
