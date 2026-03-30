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

final class DeleteJotCoordinator: Coordinator {

    var onEnd: (() -> Void)?

    private var retainedInfoAlertCoordinator: Coordinator?

    private let jotFileInfo: JotFile.Info
    private let navigation: Navigation
    private let repository: DeleteJotRepositoryProtocol

    init(
        jotFileInfo: JotFile.Info,
        navigation: Navigation,
        repository: DeleteJotRepositoryProtocol
    ) {
        self.jotFileInfo = jotFileInfo
        self.navigation = navigation
        self.repository = repository
    }

    func start() {
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
                guard let self else {
                    return
                }
                handleDeleteJot(jotFileInfo: jotFileInfo)
                navigation.dismiss(animated: true) { [weak self] in
                    Task { @MainActor in
                        self?.onEnd?()
                    }
                }
            }
        )
        navigation.present(alertController, animated: true)

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
}
