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

@testable import Jottre

@MainActor
final class SettingsCoordinatorFactoryMock: SettingsCoordinatorFactoryProtocol {

    private let makeProvider: @MainActor (_ navigation: Navigation) -> Coordinator

    init(
        makeProvider: @MainActor @escaping (_ navigation: Navigation) -> Coordinator = { _ in CoordinatorMock() }
    ) {
        self.makeProvider = makeProvider
    }

    func make(navigation: Navigation) -> Coordinator {
        makeProvider(navigation)
    }
}

@MainActor
final class EnableCloudCoordinatorFactoryMock: EnableCloudCoordinatorFactoryProtocol {

    private let makeProvider: @MainActor (_ navigation: Navigation) -> Coordinator

    init(
        makeProvider: @MainActor @escaping (_ navigation: Navigation) -> Coordinator = { _ in CoordinatorMock() }
    ) {
        self.makeProvider = makeProvider
    }

    func make(navigation: Navigation) -> Coordinator {
        makeProvider(navigation)
    }
}

@MainActor
final class EditJotCoordinatorFactoryMock: EditJotCoordinatorFactoryProtocol {

    private let makeProvider: @MainActor (_ navigation: Navigation) -> NavigationCoordinator

    init(
        makeProvider:
            @MainActor @escaping (_ navigation: Navigation) -> NavigationCoordinator = { _ in
                NavigationCoordinatorMock()
            }
    ) {
        self.makeProvider = makeProvider
    }

    func make(navigation: Navigation) -> NavigationCoordinator {
        makeProvider(navigation)
    }
}

@MainActor
final class CloudMigrationCoordinatorFactoryMock: CloudMigrationCoordinatorFactoryProtocol {

    private let makeProvider: @MainActor (_ navigation: Navigation) -> CloudMigrationCoordinatorProtocol

    init(
        makeProvider: @MainActor @escaping (_ navigation: Navigation) -> CloudMigrationCoordinatorProtocol = { _ in
            CloudMigrationCoordinatorMock()
        }
    ) {
        self.makeProvider = makeProvider
    }

    func make(navigation: Navigation) -> CloudMigrationCoordinatorProtocol {
        makeProvider(navigation)
    }
}

@MainActor
final class NavigationCoordinatorMock: NavigationCoordinator {

    private let shouldHandleProvider: (_ url: URL) -> Bool
    private let handleProvider: (_ url: URL) -> [UIViewController]

    init(
        shouldHandleProvider: @escaping (_ url: URL) -> Bool = { _ in false },
        handleProvider: @escaping (_ url: URL) -> [UIViewController] = { _ in [] }
    ) {
        self.shouldHandleProvider = shouldHandleProvider
        self.handleProvider = handleProvider
    }

    func shouldHandle(url: URL) -> Bool {
        shouldHandleProvider(url)
    }

    func handle(url: URL) -> [UIViewController] {
        handleProvider(url)
    }
}
