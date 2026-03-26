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
final class CreateJotCoordinator: NavigationCoordinator {

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

    func shouldHandle(url: URL) -> Bool {
        url.path.hasPrefix(CreateJotURL().path)
    }

    func handle(url: URL) -> [UIViewController] {
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
            style: .cancel
        )
        alertController.addAction(cancelAction)

        navigation.present(alertController, animated: true)
        return []
    }

    private func handleCreateJot(name: String) {
        Task.detached { [weak self] in
            do {
                try await self?.repository.createJot(name: name)
            } catch CreateJotRepository.Failure.fileExists {
                await self?.showInfoAlert(
                    title: "'\(name)' already exists",
                    message: nil
                )
            } catch {
                await self?.showInfoAlert(
                    title: "Something went wrong",
                    message: error.localizedDescription
                )
            }
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
