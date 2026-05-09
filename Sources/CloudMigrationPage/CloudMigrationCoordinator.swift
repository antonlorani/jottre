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
protocol CloudMigrationCoordinatorProtocol: Coordinator {

    func shouldStart() -> Bool

    func showInfoAlert(title: String, message: String)

    func dismiss()
}

final class CloudMigrationCoordinator: CloudMigrationCoordinatorProtocol {

    var onEnd: (() -> Void)?

    private var retainedInfoAlertCoordinator: Coordinator?

    private let repository: CloudMigrationRepositoryProtocol
    private let navigation: Navigation
    private let cloudMigrationViewControllerFactory: CloudMigrationViewControllerFactoryProtocol

    init(
        repository: CloudMigrationRepositoryProtocol,
        navigation: Navigation,
        cloudMigrationViewControllerFactory: CloudMigrationViewControllerFactoryProtocol
    ) {
        self.repository = repository
        self.navigation = navigation
        self.cloudMigrationViewControllerFactory = cloudMigrationViewControllerFactory
    }

    func shouldStart() -> Bool {
        repository.getShouldShowCloudMigration()
    }

    func start() {
        let navigationController = UINavigationController(
            rootViewController: cloudMigrationViewControllerFactory.make(
                viewModel: CloudMigrationViewModel(
                    repository: repository,
                    coordinator: self
                )
            )
        )
        navigation.present(navigationController, animated: true)
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

    func dismiss() {
        navigation.dismiss(animated: true) { [weak self] in
            Task { @MainActor in
                self?.onEnd?()
            }
        }
    }
}
