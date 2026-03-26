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
protocol NotesCoordinatorFactory: Sendable {

    func make(navigation: Navigation) -> NavigationCoordinator
}

struct IOS18NotesCoordinatorFactory: NotesCoordinatorFactory {

    let notesRepository: NotesRepositoryProtocol

    func make(navigation: Navigation) -> NavigationCoordinator {
        NotesCoordinator(
            navigation: navigation,
            notesViewControllerFactory: IOS18NotesViewControllerFactory(
                repository: notesRepository
            ),
            settingsCoordinatorFactory: IOS18SettingsCoordinatorFactory(),
            enableCloudCoordinatorFactory: IOS18EnableCloudCoordinatorFactory(),
            editNoteCoordinatorFactory: IOS18EditNoteCoordinatorFactory(),
            cloudMigrationCoordinatorFactory: IOS18CloudMigrationCoordinatorFactory()
        )
    }
}

@available(iOS 26, *)
struct IOS26NotesCoordinatorFactory: NotesCoordinatorFactory {

    let notesRepository: NotesRepositoryProtocol

    func make(navigation: Navigation) -> NavigationCoordinator {
        NotesCoordinator(
            navigation: navigation,
            notesViewControllerFactory: IOS26NotesViewControllerFactory(
                repository: notesRepository
            ),
            settingsCoordinatorFactory: IOS26SettingsCoordinatorFactory(),
            enableCloudCoordinatorFactory: IOS26EnableCloudCoordinatorFactory(),
            editNoteCoordinatorFactory: IOS26EditNoteCoordinatorFactory(),
            cloudMigrationCoordinatorFactory: IOS26CloudMigrationCoordinatorFactory()
        )
    }
}
