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

final class RenameJotCoordinator: Coordinator {

    private var retainedInfoAlertCoordinator: Coordinator?

    var onEnd: (() -> Void)?

    private let jotFileInfo: JotFile.Info
    private let navigation: Navigation
    private let repository: RenameJotRepositoryProtocol
    private let onRename: @Sendable (_ info: JotFile.Info) -> Void

    init(
        jotFileInfo: JotFile.Info,
        navigation: Navigation,
        repository: RenameJotRepositoryProtocol,
        onRename: @Sendable @escaping (_ info: JotFile.Info) -> Void
    ) {
        self.jotFileInfo = jotFileInfo
        self.navigation = navigation
        self.repository = repository
        self.onRename = onRename
    }

    func start() {
        let alertController = UIAlertController(
            title: L10n.Jots.Rename.title,
            message: nil,
            preferredStyle: .alert
        )
        alertController.addTextField { [weak self] textField in
            textField.clearButtonMode = .whileEditing
            textField.placeholder = self?.jotFileInfo.name
        }
        alertController.addAction(
            UIAlertAction(
                title: L10n.Action.cancel,
                style: .cancel
            )
        )
        alertController.addAction(
            UIAlertAction(
                title: L10n.Action.rename,
                style: .default
            ) { [weak self] _ in
                guard
                    let self,
                    let newName = alertController.textFields?.first?.text
                else {
                    return
                }
                handleRename(newName: newName)
                onEnd?()
            }
        )
        navigation.present(alertController, animated: true)
    }

    private func handleRename(
        newName: String
    ) {
        do {
            let renamedJotFileInfo = try repository.rename(
                jotFileInfo: jotFileInfo,
                newName: newName
            )
            onRename(renamedJotFileInfo)
        } catch {
            showInfoAlert(
                title: L10n.Jots.Rename.Error.generic(newName),
                message: error.localizedDescription
            )
        }
    }

    private func showInfoAlert(
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
}
