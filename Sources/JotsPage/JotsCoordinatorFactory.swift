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
protocol JotsCoordinatorFactoryProtocol: Sendable {

    func make(navigation: Navigation) -> NavigationCoordinator
}

struct JotsCoordinatorFactory: JotsCoordinatorFactoryProtocol {

    let jotsViewControllerFactory: JotsViewControllerFactory

    let settingsCoordinatorFactory: SettingsCoordinatorFactory
    let enableCloudCoordinatorFactory: EnableCloudCoordinatorFactory
    let editJotCoordinatorFactory: EditJotCoordinatorFactory
    let cloudMigrationCoordinatorFactory: CloudMigrationCoordinatorFactory
    let createJotCoordinatorFactory: CreateJotCoordinatorFactoryProtocol
    let deleteJotCoordinatorFactory: DeleteJotCoordinatorFactoryProtocol
    let renameJotCoordinatorFactory: RenameJotCoordinatorFactoryProtocol

    func make(navigation: Navigation) -> NavigationCoordinator {
        JotsCoordinator(
            navigation: navigation,
            jotsViewControllerFactory: jotsViewControllerFactory,
            settingsCoordinatorFactory: settingsCoordinatorFactory,
            enableCloudCoordinatorFactory: enableCloudCoordinatorFactory,
            editJotCoordinatorFactory: editJotCoordinatorFactory,
            cloudMigrationCoordinatorFactory: cloudMigrationCoordinatorFactory,
            createJotCoordinatorFactory: createJotCoordinatorFactory,
            deleteJotCoordinatorFactory: deleteJotCoordinatorFactory,
            renameJotCoordinatorFactory: renameJotCoordinatorFactory
        )
    }
}
