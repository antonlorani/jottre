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

final class SettingsCoordinator: Coordinator {

    var onEnd: (() -> Void)?

    private let navigation: Navigation
    private let settingsViewControllerFactory: SettingsViewControllerFactoryProtocol

    init(
        navigation: Navigation,
        settingsViewControllerFactory: SettingsViewControllerFactoryProtocol
    ) {
        self.navigation = navigation
        self.settingsViewControllerFactory = settingsViewControllerFactory
    }

    func start() {
        let navigationController = UINavigationController(
            rootViewController: settingsViewControllerFactory.make(coordinator: self)
        )
        navigationController.navigationBar.prefersLargeTitles = true
        navigation.present(navigationController, animated: true)
    }

    func openExternalLink(url: URL) {
        navigation.openExternal(url: url)
    }

    func dismiss() {
        navigation.dismiss(animated: true)
    }
}
