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
protocol EditNoteCoordinatorFactory {

    func make(navigation: Navigation) -> NavigationCoordinator
}

struct IOS18EditNoteCoordinatorFactory: EditNoteCoordinatorFactory {

    func make(navigation: Navigation) -> NavigationCoordinator {
        EditNoteCoordinator(
            navigation: navigation,
            editNoteViewControllerFactory: IOS18EditNoteViewControllerFactory(),
            noteConflictCoordinatorFactory: IOS18NoteConflictCoordinatorFactory()
        )
    }
}

@available(iOS 26, *)
struct IOS26EditNoteCoordinatorFactory: EditNoteCoordinatorFactory {

    func make(navigation: Navigation) -> NavigationCoordinator {
        EditNoteCoordinator(
            navigation: navigation,
            editNoteViewControllerFactory: IOS26EditNoteViewControllerFactory(),
            noteConflictCoordinatorFactory: IOS26NoteConflictCoordinatorFactory()
        )
    }
}
