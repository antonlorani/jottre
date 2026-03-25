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

final class RootCoordinator: NavigationCoordinator {

    private lazy var externalLinkNavigationCoordinator = ExternalLinkNavigationCoordinator()
    private lazy var notesCoordinator = notesCoordinatorFactory.make(navigation: navigation)

    private let navigation: Navigation
    private let notesCoordinatorFactory: NotesCoordinatorFactory

    init(
        navigation: Navigation,
        notesCoordinatorFactory: NotesCoordinatorFactory
    ) {
        self.navigation = navigation
        self.notesCoordinatorFactory = notesCoordinatorFactory
    }

    func shouldHandle(url: URL) -> Bool {
        true
    }

    func handle(url: URL) -> [UIViewController] {
        var viewControllers = [UIViewController]()
        viewControllers.append(contentsOf: notesCoordinator.handle(url: url))

        if externalLinkNavigationCoordinator.shouldHandle(url: url) {
            viewControllers.append(contentsOf: externalLinkNavigationCoordinator.handle(url: url))
        }

        return viewControllers
    }
}
