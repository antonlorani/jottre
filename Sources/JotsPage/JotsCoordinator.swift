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

@MainActor
final class JotsCoordinator: NavigationCoordinator {

    private var retainedShareJotCoordinator: Coordinator?
    private var retainedRenameJotCoordinator: Coordinator?

    private var retainedJotsViewController: UIViewController?

    private lazy var childCoordinators: [NavigationCoordinator] = [
        settingsCoordinatorFactory.make(navigation: navigation),
        enableCloudCoordinatorFactory.make(navigation: navigation),
        editJotCoordinatorFactory.make(navigation: navigation),
        cloudMigrationCoordinatorFactory.make(navigation: navigation),
        createJotCoordinatorFactory.make(navigation: navigation),
        deleteJotCoordinatorFactory.make(navigation: navigation),
    ]

    private let navigation: Navigation
    private let jotsViewControllerFactory: JotsViewControllerFactory
    private let settingsCoordinatorFactory: SettingsCoordinatorFactory
    private let enableCloudCoordinatorFactory: EnableCloudCoordinatorFactory
    private let editJotCoordinatorFactory: EditJotCoordinatorFactory
    private let cloudMigrationCoordinatorFactory: CloudMigrationCoordinatorFactory
    private let createJotCoordinatorFactory: CreateJotCoordinatorFactoryProtocol
    private let deleteJotCoordinatorFactory: DeleteJotCoordinatorFactoryProtocol
    private let renameJotCoordinatorFactory: RenameJotCoordinatorFactoryProtocol

    init(
        navigation: Navigation,
        jotsViewControllerFactory: JotsViewControllerFactory,
        settingsCoordinatorFactory: SettingsCoordinatorFactory,
        enableCloudCoordinatorFactory: EnableCloudCoordinatorFactory,
        editJotCoordinatorFactory: EditJotCoordinatorFactory,
        cloudMigrationCoordinatorFactory: CloudMigrationCoordinatorFactory,
        createJotCoordinatorFactory: CreateJotCoordinatorFactoryProtocol,
        deleteJotCoordinatorFactory: DeleteJotCoordinatorFactoryProtocol,
        renameJotCoordinatorFactory: RenameJotCoordinatorFactoryProtocol,
    ) {
        self.navigation = navigation
        self.jotsViewControllerFactory = jotsViewControllerFactory
        self.settingsCoordinatorFactory = settingsCoordinatorFactory
        self.enableCloudCoordinatorFactory = enableCloudCoordinatorFactory
        self.editJotCoordinatorFactory = editJotCoordinatorFactory
        self.cloudMigrationCoordinatorFactory = cloudMigrationCoordinatorFactory
        self.createJotCoordinatorFactory = createJotCoordinatorFactory
        self.deleteJotCoordinatorFactory = deleteJotCoordinatorFactory
        self.renameJotCoordinatorFactory = renameJotCoordinatorFactory
    }

    func shouldHandle(url: URL) -> Bool {
        true
    }

    func handle(url: URL) -> [UIViewController] {
        var viewControllers: [UIViewController]

        if let retainedJotsViewController {
            viewControllers = [retainedJotsViewController]
        } else {
            let jotsViewController = jotsViewControllerFactory.make(coordinator: self)
            self.retainedJotsViewController = jotsViewController
            viewControllers = [jotsViewController]
        }

        if let childCoordinator = childCoordinators.first(where: { $0.shouldHandle(url: url) }) {
            viewControllers.append(contentsOf: childCoordinator.handle(url: url))
        }

        return viewControllers
    }

    func openSettings() {
        navigation.open(url: SettingsURL())
    }

    func openCreateJot() {
        navigation.open(url: CreateJotURL())
    }

    func openJot(jotFileInfo: JotFile.Info) {
        navigation.open(url: EditJotURL(jotFileInfo: jotFileInfo))
    }

    func openEnableCloudPage() {
        navigation.open(url: EnableCloudURL())
    }

    func showShareJot(format: ShareFormat) {
        let coordinator = ShareJotCoordinator(
            navigation: navigation,
            format: format
        )
        retainedShareJotCoordinator = coordinator
        coordinator.onEnd = { [weak self] in
            self?.retainedShareJotCoordinator = nil
        }
        coordinator.start()
    }

    func showRenameAlert(jotFileInfo: JotFile.Info) {
        let coordinator = renameJotCoordinatorFactory.make(
            jotFileInfo: jotFileInfo,
            navigation: navigation
        ) { _ in
            /* no-op */
        }
        retainedRenameJotCoordinator = coordinator
        coordinator.onEnd = { [weak self] in
            self?.retainedRenameJotCoordinator = nil
        }
        coordinator.start()
    }

    func openDeleteJot(jotFileInfo: JotFile.Info) {
        navigation.open(url: DeleteJotURL(jotFileInfo: jotFileInfo))
    }

    func showInFiles() {

    }
}
