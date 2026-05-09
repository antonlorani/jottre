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

final class SettingsRepositoryMock: SettingsRepositoryProtocol {

    private let shouldShowEnableICloudButtonProvider: @Sendable () -> Bool
    private let appVersionProvider: @Sendable () -> String
    private let userInterfaceStyleProvider: @Sendable () -> AsyncStream<UIUserInterfaceStyle>
    private let updateUserInterfaceStyleProvider: @Sendable (_ style: UIUserInterfaceStyle) -> Void

    init(
        shouldShowEnableICloudButtonProvider: @Sendable @escaping () -> Bool = { false },
        appVersionProvider: @Sendable @escaping () -> String = { "" },
        userInterfaceStyleProvider: @Sendable @escaping () -> AsyncStream<UIUserInterfaceStyle> = {
            AsyncStream { $0.finish() }
        },
        updateUserInterfaceStyleProvider: @Sendable @escaping (_ style: UIUserInterfaceStyle) -> Void = { _ in }
    ) {
        self.shouldShowEnableICloudButtonProvider = shouldShowEnableICloudButtonProvider
        self.appVersionProvider = appVersionProvider
        self.userInterfaceStyleProvider = userInterfaceStyleProvider
        self.updateUserInterfaceStyleProvider = updateUserInterfaceStyleProvider
    }

    func shouldShowEnableICloudButton() -> Bool {
        shouldShowEnableICloudButtonProvider()
    }

    func appVersion() -> String {
        appVersionProvider()
    }

    func userInterfaceStyle() -> AsyncStream<UIUserInterfaceStyle> {
        userInterfaceStyleProvider()
    }

    func updateUserInterfaceStyle(_ style: UIUserInterfaceStyle) {
        updateUserInterfaceStyleProvider(style)
    }
}
