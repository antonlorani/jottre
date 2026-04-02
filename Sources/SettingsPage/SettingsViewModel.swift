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

    private enum Constants {

        static let userInterfaceStyleOptions: [UIUserInterfaceStyle] = [.unspecified, .dark, .light]
    }

    var title: String? {
        L10n.Settings.title
    }

    let rightNavigationItems: AsyncStream<[PageNavigationItem]>
    private let rightNavigationItemsContinuation: AsyncStream<[PageNavigationItem]>.Continuation

    let items: AsyncStream<[PageCellItem]>
    private let itemsContinuation: AsyncStream<[PageCellItem]>.Continuation

    private let repository: SettingsRepositoryProtocol
    private weak var coordinator: SettingsCoordinator?

    private var loadingTask: Task<Void, Never>?

    init(
        repository: SettingsRepositoryProtocol,
        coordinator: SettingsCoordinator
    ) {
        self.repository = repository
        self.coordinator = coordinator
        (items, itemsContinuation) = AsyncStream.makeStream(
            of: [PageCellItem].self,
            bufferingPolicy: .bufferingNewest(1)
        )

        (rightNavigationItems, rightNavigationItemsContinuation) = AsyncStream.makeStream(
            of: [PageNavigationItem].self,
            bufferingPolicy: .bufferingNewest(1)
        )

        rightNavigationItemsContinuation.yield([
            .symbol(systemImageName: "xmark") { [weak coordinator] in
                Task { @MainActor in
                    coordinator?.dismiss()
                }
            }
        ])
    }

    func didLoad() {
        loadingTask = Task { [weak self] in
            guard let repository = self?.repository else {
                return
            }
            let shouldShowEnableICloudButton = repository.shouldShowEnableICloudButton()
            let appVersion = repository.appVersion()
            for await userInterfaceStyle in repository.userInterfaceStyle() {
                guard let self else {
                    return
                }
                itemsContinuation.yield(
                    makePageItems(
                        userInterfaceStyle: userInterfaceStyle,
                        shouldShowEnableICloudButton: shouldShowEnableICloudButton,
                        appVersion: appVersion
                    )
                )
            }
        }
    }

    private func makePageItems(
        userInterfaceStyle: UIUserInterfaceStyle,
        shouldShowEnableICloudButton: Bool,
        appVersion: String
    ) -> [PageCellItem] {
        var items = [
            PageCellItem.settingsDropdown(
                settingsDropdown: SettingsDropdownBusinessModel(
                    name: L10n.Settings.Appearance.title,
                    current: SettingsDropdownBusinessModel.Option(
                        label: SettingsViewModel.makeLabel(userInterfaceStyle: userInterfaceStyle),
                        value: userInterfaceStyle
                    ),
                    options: Constants.userInterfaceStyleOptions.map { userInterfaceStyleOption in
                        SettingsDropdownBusinessModel.Option(
                            label: SettingsViewModel.makeLabel(userInterfaceStyle: userInterfaceStyleOption),
                            value: userInterfaceStyleOption
                        )
                    }
                ),
                onAction: { [weak self] option in
                    guard let style = option.value as? UIUserInterfaceStyle else {
                        return
                    }
                    self?.repository.updateUserInterfaceStyle(style)
                }
            )
        ]

        if shouldShowEnableICloudButton {
            items.append(
                .settingsExternalLink(
                    settingsExternalLink: SettingsExternalLinkBusinessModel(
                        name: L10n.Settings.ICloud.title,
                        info: L10n.Settings.ICloud.info
                    ),
                    onAction: { [weak self] in
                        Task { @MainActor [weak self] in
                            self?.coordinator?.openExternalLink(url: EnableICloudSupportURL().toURL())
                        }
                    }
                )
            )
        }

        items.append(contentsOf: [
            .settingsExternalLink(
                settingsExternalLink: SettingsExternalLinkBusinessModel(
                    name: L10n.Settings.Github.title,
                    info: nil
                ),
                onAction: { [weak self] in
                    Task { @MainActor [weak self] in
                        self?.coordinator?.openExternalLink(url: JottreGithubURL().toURL())
                    }
                }
            ),
            .settingsInfo(
                settingsInfo: SettingsInfoBusinessModel(
                    name: L10n.Settings.Version.title,
                    value: appVersion
                )
            ),
        ])

        return items
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

    deinit {
        loadingTask?.cancel()
    }
}
