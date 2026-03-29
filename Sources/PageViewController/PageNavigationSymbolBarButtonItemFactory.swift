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

enum PrimaryBarButtonAction: Sendable {
    case action(UIAction)
    case menu(UIMenu)
}

@MainActor
protocol SymbolBarButtonItemFactory: Sendable {

    func make(
        symbolName: String,
        primaryAction: PrimaryBarButtonAction
    ) -> UIBarButtonItem
}

struct IOS18SymbolBarButtonItemFactory: SymbolBarButtonItemFactory {

    func make(
        symbolName: String,
        primaryAction: PrimaryBarButtonAction
    ) -> UIBarButtonItem {
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: symbolName)?
            .withTintColor(.systemBackground, renderingMode: .alwaysOriginal)
        configuration.baseBackgroundColor = .label
        configuration.baseForegroundColor = .systemBackground
        configuration.cornerStyle = .capsule
        configuration.buttonSize = .medium

        switch primaryAction {
        case let .action(action):
            return UIBarButtonItem(
                customView: UIButton(
                    configuration: configuration,
                    primaryAction: action
                )
            )
        case let .menu(menu):
            let button = UIButton(configuration: configuration)
            button.menu = menu
            button.showsMenuAsPrimaryAction = true
            return UIBarButtonItem(customView: button)
        }
    }
}

@available(iOS 26, *)
struct IOS26SymbolBarButtonItemFactory: SymbolBarButtonItemFactory {

    func make(
        symbolName: String,
        primaryAction: PrimaryBarButtonAction
    ) -> UIBarButtonItem {
        let image = UIImage(systemName: symbolName)
        return switch primaryAction {
        case let .action(action):
            UIBarButtonItem(image: image, primaryAction: action)
        case let .menu(menu):
            UIBarButtonItem(image: image, menu: menu)
        }
    }
}
