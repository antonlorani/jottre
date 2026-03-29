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
final class SettingsViewModel: PageViewModel {

    var title: String? {
        L10n.Settings.title
    }

    let rightNavigationItems: AsyncStream<[PageNavigationItem]>
    private let rightNavigationItemsContinuation: AsyncStream<[PageNavigationItem]>.Continuation

    let items: AsyncStream<[PageCellItem]>
    private let itemsContinuation: AsyncStream<[PageCellItem]>.Continuation

    init(
        repository: SettingsRepositoryProtocol,
        coordinator: SettingsCoordinator
    ) {
        (items, itemsContinuation) = AsyncStream.makeStream(
            of: [PageCellItem].self,
            bufferingPolicy: .bufferingNewest(1)
        )

        (rightNavigationItems, rightNavigationItemsContinuation) = AsyncStream.makeStream(
            of: [PageNavigationItem].self,
            bufferingPolicy: .bufferingNewest(1)
        )

        var items = [
            PageCellItem.settingsDropdown(
                name: L10n.Settings.Appearance.title,
                current: .init(
                    label: SettingsViewModel.makeLabel(userInterfaceStyle: .unspecified),
                    value: UIUserInterfaceStyle.unspecified
                ),
                options: [UIUserInterfaceStyle.unspecified, .dark, .light].map { style in
                    .init(
                        label: SettingsViewModel.makeLabel(userInterfaceStyle: style),
                        value: style
                    )
                },
                onAction: { _ in }
            )
        ]

        if repository.shouldShowEnableICloudButton() {
            items.append(
                .settingsExternalLink(
                    name: L10n.Settings.ICloud.title,
                    info: L10n.Settings.ICloud.info,
                    onAction: { [weak coordinator] in
                        Task { @MainActor in
                            coordinator?.openExternalLink(url: EnableICloudSupportURL().toURL())
                        }
                    }
                )
            )
        }

        items.append(contentsOf: [
            .settingsExternalLink(
                name: L10n.Settings.ICloud.title,
                info: L10n.Settings.ICloud.info,
                onAction: { [weak coordinator] in
                    Task { @MainActor in
                        coordinator?.openExternalLink(url: EnableICloudSupportURL().toURL())
                    }
                }
            ),
            .settingsExternalLink(
                name: L10n.Settings.Github.title,
                info: nil,
                onAction: { [weak coordinator] in
                    Task { @MainActor in
                        coordinator?.openExternalLink(url: JottreGithubURL().toURL())
                    }
                }
            ),
            .settingsInfo(
                name: L10n.Settings.Version.title,
                value: repository.appVersion()
            ),
        ])

        itemsContinuation.yield(items)

        rightNavigationItemsContinuation.yield([
            .symbol(systemImageName: "xmark") { [weak coordinator] in
                Task { @MainActor in
                    coordinator?.dismiss()
                }
            }
        ])
    }

    private static func makeLabel(userInterfaceStyle: UIUserInterfaceStyle) -> String {
        switch userInterfaceStyle {
        case .light:
            L10n.Settings.Appearance.light
        case .dark:
            L10n.Settings.Appearance.dark
        default:
            L10n.Settings.Appearance.system
        }
    }
}
