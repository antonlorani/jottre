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

final class EditJotCoordinator: NavigationCoordinator {

    private var retainedJotConflictCoordinator: Coordinator?
    private var retainedShareJotCoordinator: Coordinator?
    private var retainedDeleteJotCoordinator: Coordinator?
    private var retainedRenameJotCoordinator: Coordinator?

    private let navigation: Navigation
    private let editJotViewControllerFactory: EditJotViewControllerFactory
    private let jotConflictCoordinatorFactory: JotConflictCoordinatorFactory

    init(
        navigation: Navigation,
        editJotViewControllerFactory: EditJotViewControllerFactory,
        jotConflictCoordinatorFactory: JotConflictCoordinatorFactory
    ) {
        self.navigation = navigation
        self.editJotViewControllerFactory = editJotViewControllerFactory
        self.jotConflictCoordinatorFactory = jotConflictCoordinatorFactory
    }

    func shouldHandle(url: URL) -> Bool {
        guard
            url.path.hasPrefix(EditJotURL().path),
            getFileURLQueryItem(url: url) != nil
        else {
            return false
        }
        return true
    }

    func handle(url: URL) -> [UIViewController] {
        guard let fileURL = getFileURLQueryItem(url: url),
            let jotFile = JotFileBusinessModel(url: fileURL, modificationDate: nil)
        else {
            return []
        }

        return [
            editJotViewControllerFactory.make(
                jotFile: jotFile,
                coordinator: self
            )
        ]
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

    func showRenameAlert() {
        let coordinator = RenameJotCoordinator(navigation: navigation)
        retainedRenameJotCoordinator = coordinator
        coordinator.onEnd = { [weak self] in
            self?.retainedRenameJotCoordinator = nil
        }
        coordinator.start()
    }

    func showDeleteConfirmationAlert() {
        let coordinator = DeleteJotCoordinator(navigation: navigation)
        retainedShareJotCoordinator = coordinator
        coordinator.onEnd = { [weak self] in
            self?.retainedShareJotCoordinator = nil
        }
        coordinator.start()
    }

    func showInFiles() {

    }

    func showJotConflictPage(jotFileVersions: [JotFileVersion]) {
        retainedJotConflictCoordinator = jotConflictCoordinatorFactory.make(navigation: navigation)
        retainedJotConflictCoordinator?.start()
        retainedJotConflictCoordinator?.onEnd = { [weak self] in
            self?.retainedJotConflictCoordinator = nil
        }
    }

    func goBack() {
        navigation.popViewController(animated: true)
    }

    private func getFileURLQueryItem(url: URL) -> URL? {
        guard let queryItems = URLComponents(string: url.absoluteString)?.queryItems,
            let fileURLValue = queryItems.first(where: { $0.name == "fileURL" })?.value,
            let fileURL = URL(string: fileURLValue)
        else {
            return nil
        }
        return fileURL
    }
}
