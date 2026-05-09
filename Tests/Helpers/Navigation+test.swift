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

@testable import Jottre

extension Navigation {

    static func test(
        openURLProvider: @Sendable @escaping (_ url: URL) -> Void = { _ in },
        openExternalURLProvider: @Sendable @escaping (_ url: URL) -> Void = { _ in },
        openSceneProvider: @Sendable @escaping (_ url: URL) -> Void = { _ in },
        presentViewControllerProvider:
            @Sendable @escaping (_ viewController: UIViewController, _ animated: Bool) -> Void = { _, _ in },
        dismissViewControllerProvider:
            @Sendable @escaping (_ animated: Bool, _ completion: (@Sendable () -> Void)?) -> Void = { _, _ in },
        popViewControllerProvider: @Sendable @escaping (_ animated: Bool) -> Void = { _ in },
        getViewControllersProvider: @MainActor @escaping () -> [UIViewController] = { [] }
    ) -> Navigation {
        Navigation(
            openURLProvider: openURLProvider,
            openExternalURLProvider: openExternalURLProvider,
            openSceneProvider: openSceneProvider,
            presentViewControllerProvider: presentViewControllerProvider,
            dismissViewControllerProvider: dismissViewControllerProvider,
            popViewControllerProvider: popViewControllerProvider,
            getViewControllersProvider: getViewControllersProvider
        )
    }
}
