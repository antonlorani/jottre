import UIKit

@MainActor
final class SettingsViewModel: PageViewModel {

    var title: String? { "Settings" }

    let rightNavigationItems: AsyncStream<[PageNavigationItem]>
    private let rightNavigationItemsContinuation: AsyncStream<[PageNavigationItem]>.Continuation

    let items: AsyncStream<[PageCellItem]>
    private let itemsContinuation: AsyncStream<[PageCellItem]>.Continuation

    init(coordinator: SettingsCoordinator) {
        (items, itemsContinuation) = AsyncStream.makeStream(
            of: [PageCellItem].self,
            bufferingPolicy: .bufferingNewest(1)
        )

        (rightNavigationItems, rightNavigationItemsContinuation) = AsyncStream.makeStream(
            of: [PageNavigationItem].self,
            bufferingPolicy: .bufferingNewest(1)
        )

        itemsContinuation.yield([
            .settingsDropdown(
                name: "Appearance",
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
            ),
//            .settingsToggle(
//                name: "iCloud Synchronization",
//                isOn: false
//            ),
            .settingsExternalLink(
                name: "iCloud Synchronization",
                info: "Learn how to enable iCloud on this device.",
                onAction: { [weak coordinator] in
                    Task { @MainActor in
                        coordinator?.openExternalLink(url: EnableICloudSupportURL().toURL())
                    }
                }
            ),
            .settingsExternalLink(
                name: "Stargaze on Github",
                info: nil,
                onAction: { [weak coordinator] in
                    Task { @MainActor in
                        coordinator?.openExternalLink(url: JottreGithubURL().toURL())
                    }
                }
            ),
            .settingsInfo(
                name: "Version",
                value: "2.0.0"
            )
        ])

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
            "Light"
        case .dark:
            "Dark"
        default:
            "System"
        }
    }
}
