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

@MainActor
final class CreateJotCoordinator: Coordinator {

    var onEnd: (() -> Void)?

    private var retainedInfoAlertCoordinator: Coordinator?

    private let navigation: Navigation
    private let repository: CreateJotRepositoryProtocol

    init(
        navigation: Navigation,
        repository: CreateJotRepositoryProtocol
    ) {
        self.navigation = navigation
        self.repository = repository
    }

    func start() {
        let alertController = UIAlertController(
            title: L10n.Jots.Create.title,
            message: nil,
            preferredStyle: .alert
        )
        alertController.addTextField { textField in
            textField.placeholder = L10n.Jots.Create.namePlaceholder
            textField.autocapitalizationType = .sentences
            textField.returnKeyType = .done
        }

        let createAction = UIAlertAction(
            title: L10n.Action.create,
            style: .default
        ) { [weak self] _ in
            guard
                let self,
                let name = alertController.textFields?.first?.text,
                !name.isEmpty
            else {
                return
            }

            handleCreateJot(name: name)
        }
        alertController.addAction(createAction)

        let cancelAction = UIAlertAction(
            title: L10n.Action.cancel,
            style: .cancel,
            handler: { [weak self] _ in
                self?.onEnd?()
            }
        )
        alertController.addAction(cancelAction)

        navigation.present(alertController, animated: true)
    }

    private func handleCreateJot(name: String) {
        Task { [weak self] in
            guard let self else {
                return
            }
            do {
                try await handleCreateJot(name: name)
            } catch CreateJotRepository.Failure.fileExists {
                showInfoAlert(
                    title: L10n.Jots.Create.Error.fileExists(name),
                    message: nil
                )
            } catch {
                showInfoAlert(
                    title: L10n.Jots.Create.Error.generic,
                    message: error.localizedDescription
                )
            }
        }
    }

    private func handleCreateJot(name: String) async throws {
        let jotFileInfo = try await repository.createJot(name: name)
        navigation.open(url: EditJotURL(jotFileInfo: jotFileInfo))
        onEnd?()
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
            self?.onEnd?()
        }
        infoAlertCoordinator.start()
    }
}
