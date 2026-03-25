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
protocol TextBarButtonItemFactory: Sendable {

    func make(
        title: String,
        primaryAction: UIAction
    ) -> UIBarButtonItem
}

struct IOS18TextBarButtonItemFactory: TextBarButtonItemFactory {

    func make(
        title: String,
        primaryAction: UIAction
    ) -> UIBarButtonItem {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.baseBackgroundColor = .label
        configuration.baseForegroundColor = .systemBackground
        configuration.cornerStyle = .capsule
        configuration.buttonSize = .medium
        return UIBarButtonItem(
            customView: UIButton(
                configuration: configuration,
                primaryAction: primaryAction
            )
        )
    }
}

@available(iOS 26, *)
struct IOS26TextBarButtonItemFactory: TextBarButtonItemFactory {

    func make(
        title: String,
        primaryAction: UIAction
    ) -> UIBarButtonItem {
        UIBarButtonItem(
            title: title,
            primaryAction: primaryAction
        )
    }
}
