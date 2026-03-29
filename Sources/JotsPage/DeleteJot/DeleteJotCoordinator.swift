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

final class DeleteJotCoordinator: NavigationCoordinator {

    private var retainedInfoAlertCoordinator: Coordinator?

    private let navigation: Navigation
    private let repository: DeleteJotRepositoryProtocol

    init(
        navigation: Navigation,
        repository: DeleteJotRepositoryProtocol
    ) {
        self.navigation = navigation
        self.repository = repository
    }

    func shouldHandle(url: URL) -> Bool {
        guard
            url.path.hasPrefix(DeleteJotURL().path),
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

        let alertController = UIAlertController(
            title: L10n.Jots.Delete.title,
            message: L10n.Jots.Delete.message,
            preferredStyle: .alert
        )
        alertController.addAction(
            UIAlertAction(
                title: L10n.Action.cancel,
                style: .cancel
            )
        )
        alertController.addAction(
            UIAlertAction(
                title: L10n.Action.delete,
                style: .destructive
            ) { [weak self] _ in
                self?.handleDeleteJot(jotFileInfo: jotFileInfo)
                self?.navigation.dismiss(animated: true)
            }
        )
        navigation.present(alertController, animated: true)

        return []
    }

    private func handleDeleteJot(jotFileInfo: JotFile.Info) {
        do {
            try repository.deleteJot(jotFileInfo: jotFileInfo)
        } catch {
            showInfoAlert(
                title: L10n.Jots.Delete.Error.generic(jotFileInfo.name),
                message: error.localizedDescription
            )
        }
    }

    private func showInfoAlert(
        title: String,
        message: String?
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
