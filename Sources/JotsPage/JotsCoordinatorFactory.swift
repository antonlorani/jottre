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
protocol JotsCoordinatorFactory: Sendable {

    func make(navigation: Navigation) -> NavigationCoordinator
}

struct IOS18JotsCoordinatorFactory: JotsCoordinatorFactory {

    let jotsRepository: JotsRepositoryProtocol
    let editJotRepository: EditJotRepositoryProtocol

    func make(navigation: Navigation) -> NavigationCoordinator {
        JotsCoordinator(
            navigation: navigation,
            jotsViewControllerFactory: IOS18JotsViewControllerFactory(
                repository: jotsRepository
            ),
            settingsCoordinatorFactory: IOS18SettingsCoordinatorFactory(),
            enableCloudCoordinatorFactory: IOS18EnableCloudCoordinatorFactory(),
            editJotCoordinatorFactory: IOS18EditJotCoordinatorFactory(
                repository: editJotRepository
            ),
            cloudMigrationCoordinatorFactory: IOS18CloudMigrationCoordinatorFactory()
        )
    }
}

@available(iOS 26, *)
struct IOS26JotsCoordinatorFactory: JotsCoordinatorFactory {

    let jotsRepository: JotsRepositoryProtocol
    let editJotRepository: EditJotRepositoryProtocol

    func make(navigation: Navigation) -> NavigationCoordinator {
        JotsCoordinator(
            navigation: navigation,
            jotsViewControllerFactory: IOS26JotsViewControllerFactory(
                repository: jotsRepository
            ),
            settingsCoordinatorFactory: IOS26SettingsCoordinatorFactory(),
            enableCloudCoordinatorFactory: IOS26EnableCloudCoordinatorFactory(),
            editJotCoordinatorFactory: IOS26EditJotCoordinatorFactory(
                repository: editJotRepository
            ),
            cloudMigrationCoordinatorFactory: IOS26CloudMigrationCoordinatorFactory()
        )
    }
}
