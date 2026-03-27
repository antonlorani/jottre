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

@MainActor
protocol JotConflictCoordinatorFactoryProtocol: Sendable {

    func make(
        jotFileInfo: JotFile.Info,
        jotFileVersions: [JotFileVersion],
        navigation: Navigation,
        onResult: @Sendable @escaping (_ result: JotConflictResult) -> Void
    ) -> Coordinator
}

struct JotConflictCoordinatorFactory: JotConflictCoordinatorFactoryProtocol {

    let jotConflictViewControllerFactory: JotConflictViewControllerFactoryProtocol
    let repository: JotConflictRepositoryProtocol

    func make(
        jotFileInfo: JotFile.Info,
        jotFileVersions: [JotFileVersion],
        navigation: Navigation,
        onResult: @Sendable @escaping (_ result: JotConflictResult) -> Void
    ) -> Coordinator {
        JotConflictCoordinator(
            jotFileInfo: jotFileInfo,
            jotFileVersions: jotFileVersions,
            repository: repository,
            navigation: navigation,
            jotConflictViewControllerFactory: jotConflictViewControllerFactory,
            onResult: onResult
        )
    }
}
