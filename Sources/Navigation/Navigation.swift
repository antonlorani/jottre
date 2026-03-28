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

/// Defines navigation actions.
struct Navigation: Sendable {

    private let openURLProvider: @Sendable (_ url: URL) -> Void
    private let presentViewControllerProvider:
        @Sendable (
            _ viewController: UIViewController,
            _ animated: Bool
        ) -> Void
    private let dismissViewControllerProvider:
        @Sendable (_ animated: Bool, _ completion: (@Sendable () -> Void)?) -> Void
    private let popViewControllerProvider: @Sendable (_ animated: Bool) -> Void

    init(
        openURLProvider: @Sendable @escaping (_ url: URL) -> Void,
        presentViewControllerProvider:
            @Sendable @escaping (
                _ viewController: UIViewController,
                _ animated: Bool
            ) -> Void,
        dismissViewControllerProvider: @Sendable @escaping (_ animated: Bool, _ completion: (@Sendable () -> Void)?) ->
            Void,
        popViewControllerProvider: @Sendable @escaping (_ animated: Bool) -> Void
    ) {
        self.openURLProvider = openURLProvider
        self.presentViewControllerProvider = presentViewControllerProvider
        self.dismissViewControllerProvider = dismissViewControllerProvider
        self.popViewControllerProvider = popViewControllerProvider
    }

    func open(url: URL) {
        openURLProvider(url)
    }

    func open<T: URLConvertible>(url: T) {
        openURLProvider(url.toURL())
    }

    func present(_ viewController: UIViewController, animated: Bool) {
        presentViewControllerProvider(viewController, animated)
    }

    func dismiss(animated: Bool, completion: (@Sendable () -> Void)? = nil) {
        dismissViewControllerProvider(animated, completion)
    }

    func popViewController(animated: Bool) {
        popViewControllerProvider(animated)
    }
}
