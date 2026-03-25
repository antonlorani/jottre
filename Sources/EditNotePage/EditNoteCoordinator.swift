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

final class EditNoteCoordinator: NavigationCoordinator {

    private var retainedNoteConflictCoordinator: Coordinator?
    private var retainedShareNoteCoordinator: Coordinator?
    private var retainedDeleteNoteCoordinator: Coordinator?
    private var retainedRenameNoteCoordinator: Coordinator?

    private let navigation: Navigation
    private let editNoteViewControllerFactory: EditNoteViewControllerFactory
    private let noteConflictCoordinatorFactory: NoteConflictCoordinatorFactory

    init(
        navigation: Navigation,
        editNoteViewControllerFactory: EditNoteViewControllerFactory,
        noteConflictCoordinatorFactory: NoteConflictCoordinatorFactory
    ) {
        self.navigation = navigation
        self.editNoteViewControllerFactory = editNoteViewControllerFactory
        self.noteConflictCoordinatorFactory = noteConflictCoordinatorFactory
    }

    func shouldHandle(url: URL) -> Bool {
        url.path.hasPrefix(EditNoteURL().path)
    }

    func handle(url: URL) -> [UIViewController] {

        retainedNoteConflictCoordinator =
            noteConflictCoordinatorFactory
            .make(navigation: navigation)
        retainedNoteConflictCoordinator?.start()

        return [
            editNoteViewControllerFactory.make(coordinator: self)
        ]
    }

    func showShareNote(format: ShareFormat) {
        let coordinator = ShareNoteCoordinator(
            navigation: navigation,
            format: format
        )
        retainedShareNoteCoordinator = coordinator
        coordinator.onEnd = { [weak self] in
            self?.retainedShareNoteCoordinator = nil
        }
        coordinator.start()
    }

    func showRenameAlert() {
        let coordinator = RenameNoteCoordinator(navigation: navigation)
        retainedRenameNoteCoordinator = coordinator
        coordinator.onEnd = { [weak self] in
            self?.retainedRenameNoteCoordinator = nil
        }
        coordinator.start()
    }

    func showDeleteConfirmationAlert() {
        let coordinator = DeleteNoteCoordinator(navigation: navigation)
        retainedShareNoteCoordinator = coordinator
        coordinator.onEnd = { [weak self] in
            self?.retainedShareNoteCoordinator = nil
        }
        coordinator.start()
    }

    func showInFiles() {

    }
}
