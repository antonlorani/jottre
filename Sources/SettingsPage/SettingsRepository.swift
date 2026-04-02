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

protocol SettingsRepositoryProtocol: Sendable {

    func shouldShowEnableICloudButton() -> Bool

    func appVersion() -> String

    func userInterfaceStyle() -> AsyncStream<UIUserInterfaceStyle>

    func updateUserInterfaceStyle(_ style: UIUserInterfaceStyle)
}

struct SettingsRepository: SettingsRepositoryProtocol {

    private let ubiquitousFileService: FileServiceProtocol
    private let bundleService: BundleServiceProtocol
    private let defaultsService: DefaultsServiceProtocol

    init(
        ubiquitousFileService: FileServiceProtocol,
        bundleService: BundleServiceProtocol,
        defaultsService: DefaultsServiceProtocol
    ) {
        self.ubiquitousFileService = ubiquitousFileService
        self.bundleService = bundleService
        self.defaultsService = defaultsService
    }

    func shouldShowEnableICloudButton() -> Bool {
        !ubiquitousFileService.isEnabled()
    }

    func appVersion() -> String {
        bundleService.shortVersionString() ?? "-"
    }

    func userInterfaceStyle() -> AsyncStream<UIUserInterfaceStyle> {
        defaultsService.getValueStream(.userInterfaceStyle)
            .map { value in
                value
                    .flatMap { UIUserInterfaceStyle(rawValue: $0) }
                    ?? .unspecified
            }
            .toAsyncStream()
    }

    func updateUserInterfaceStyle(_ style: UIUserInterfaceStyle) {
        defaultsService.set(.userInterfaceStyle, value: style.rawValue)
    }
}
