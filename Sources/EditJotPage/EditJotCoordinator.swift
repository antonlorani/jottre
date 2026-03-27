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

    private var retainedInfoAlertCoordinator: Coordinator?

    private var retainedJotConflictCoordinator: Coordinator?
    private var retainedShareJotCoordinator: Coordinator?
    private var retainedRenameJotCoordinator: Coordinator?

    private let navigation: Navigation
    private let editJotViewControllerFactory: EditJotViewControllerFactoryProtocol
    private let jotConflictCoordinatorFactory: JotConflictCoordinatorFactoryProtocol
    private let renameJotCoordinatorFactory: RenameJotCoordinatorFactoryProtocol

    init(
        navigation: Navigation,
        editJotViewControllerFactory: EditJotViewControllerFactoryProtocol,
        jotConflictCoordinatorFactory: JotConflictCoordinatorFactoryProtocol,
        renameJotCoordinatorFactory: RenameJotCoordinatorFactoryProtocol
    ) {
        self.navigation = navigation
        self.editJotViewControllerFactory = editJotViewControllerFactory
        self.jotConflictCoordinatorFactory = jotConflictCoordinatorFactory
        self.renameJotCoordinatorFactory = renameJotCoordinatorFactory
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
            let jotFileInfo = JotFile.Info(url: fileURL, modificationDate: nil)
        else {
            return []
        }

        return [
            editJotViewControllerFactory.make(
                jotFileInfo: jotFileInfo,
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

    func showRenameAlert(jotFileInfo: JotFile.Info) {
        let coordinator = renameJotCoordinatorFactory.make(
            jotFileInfo: jotFileInfo,
            navigation: navigation
        ) { [weak self] renameJotFileInfo in
            self?.navigation.open(url: EditJotURL(jotFileInfo: renameJotFileInfo))
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

    func openJot(jotFileInfo: JotFile.Info) {
        navigation.open(url: EditJotURL(jotFileInfo: jotFileInfo))
    }

    func showInFiles() {

    }

    func showJotConflictPage(
        jotFileInfo: JotFile.Info,
        jotFileVersions: [JotFileVersion],
        onResult: @Sendable @escaping (_ result: JotConflictResult) -> Void
    ) {
        retainedJotConflictCoordinator = jotConflictCoordinatorFactory.make(
            jotFileInfo: jotFileInfo,
            jotFileVersions: jotFileVersions,
            navigation: navigation,
            onResult: onResult
        )
        retainedJotConflictCoordinator?.start()
        retainedJotConflictCoordinator?.onEnd = { [weak self] in
            self?.retainedJotConflictCoordinator = nil
        }
    }

    func goBack() {
        navigation.popViewController(animated: true)
    }

    func showInfoAlert(
        title: String,
        message: String
    ) {
        let infoAlertCoordinator = InfoAlertCoordinator(
            navigation: navigation,
            title: title,
            message: message
        )
        retainedInfoAlertCoordinator = infoAlertCoordinator
        infoAlertCoordinator.onEnd = { [weak self] in
            self?.retainedInfoAlertCoordinator = nil
        }
        infoAlertCoordinator.start()
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
