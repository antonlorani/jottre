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

final class JotConflictCoordinator: Coordinator {

    private var retainedInfoAlertCoordinator: Coordinator?

    var onEnd: (() -> Void)?

    private let jotFileInfo: JotFile.Info
    private let jotFileVersions: [JotFileVersion]
    private let repository: JotConflictRepositoryProtocol
    private let navigation: Navigation
    private let jotConflictViewControllerFactory: JotConflictViewControllerFactoryProtocol
    private let onResult: @Sendable (_ result: JotConflictResult) -> Void

    init(
        jotFileInfo: JotFile.Info,
        jotFileVersions: [JotFileVersion],
        repository: JotConflictRepositoryProtocol,
        navigation: Navigation,
        jotConflictViewControllerFactory: JotConflictViewControllerFactoryProtocol,
        onResult: @Sendable @escaping (_ result: JotConflictResult) -> Void
    ) {
        self.jotFileInfo = jotFileInfo
        self.jotFileVersions = jotFileVersions
        self.repository = repository
        self.navigation = navigation
        self.jotConflictViewControllerFactory = jotConflictViewControllerFactory
        self.onResult = onResult
    }

    func start() {
        let viewController = jotConflictViewControllerFactory.make(
            viewModel: JotConflictViewModel(
                jotFileInfo: jotFileInfo,
                jotFileVersions: jotFileVersions,
                repository: repository,
                coordinator: self,
                onResult: onResult
            )
        )
        viewController.isModalInPresentation = true

        let navigationController = UINavigationController(
            rootViewController: viewController
        )
        navigationController.navigationBar.prefersLargeTitles = false
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
        infoAlertCoordinator.onEnd = { [weak self] in
            self?.retainedInfoAlertCoordinator = nil
        }
        retainedInfoAlertCoordinator = infoAlertCoordinator
        infoAlertCoordinator.start()
    }

    func dismiss() {
        navigation.dismiss(animated: true)
    }
}
