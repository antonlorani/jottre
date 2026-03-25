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
protocol SettingsViewControllerFactory: Sendable {

    func make(coordinator: SettingsCoordinator) -> UIViewController
}

struct IOS18SettingsViewControllerFactory: SettingsViewControllerFactory {

    func make(coordinator: SettingsCoordinator) -> UIViewController {
        let viewController = PageViewController(
            viewModel: SettingsViewModel(coordinator: coordinator),
            textBarButtonItemFactory: IOS18TextBarButtonItemFactory(),
            symbolBarButtonItemFactory: IOS18SymbolBarButtonItemFactory()
        )
        viewController.navigationItem.largeTitleDisplayMode = .always
        return viewController
    }
}

@available(iOS 26, *)
struct IOS26SettingsViewControllerFactory: SettingsViewControllerFactory {

    func make(coordinator: SettingsCoordinator) -> UIViewController {
        let viewController = PageViewController(
            viewModel: SettingsViewModel(coordinator: coordinator),
            textBarButtonItemFactory: IOS26TextBarButtonItemFactory(),
            symbolBarButtonItemFactory: IOS26SymbolBarButtonItemFactory()
        )
        viewController.navigationItem.largeTitleDisplayMode = .always
        return viewController
    }
}
