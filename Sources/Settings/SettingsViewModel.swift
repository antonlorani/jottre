import Foundation
import UIKit

@MainActor
final class SettingsViewModel: Sendable {

    enum Item {
        case dropdown(SettingsDropdownBusinessModel)
        case toggle(SettingsToggleBusinessModel)
        case externalLink(SettingsExternalLinkBusinessModel, onAction: () -> Void)
        case text(SettingsInfoBusinessModel)
    }

    let items: AsyncStream<[Item]>
    private let itemsContinuation: AsyncStream<[Item]>.Continuation

    private weak var coordinator: SettingsCoordinator?

    init(coordinator: SettingsCoordinator) {
        self.coordinator = coordinator

        (items, itemsContinuation) = AsyncStream.makeStream(
            of: [Item].self,
            bufferingPolicy: .bufferingNewest(1)
        )
        itemsContinuation.yield(makeItems())
    }

    private func makeItems() -> [Item] {
        [
            .dropdown(
                SettingsDropdownBusinessModel(
                    name: "Appearance",
                    current: SettingsDropdownBusinessModel.Option(
                        label: makeLabel(userInterfaceStyle: .unspecified),
                        value: UIUserInterfaceStyle.unspecified
                    ),
                    options: [UIUserInterfaceStyle.unspecified, .dark, .light].map { userInterfaceStyle in
                        SettingsDropdownBusinessModel.Option(
                            label: makeLabel(userInterfaceStyle: userInterfaceStyle),
                            value: userInterfaceStyle
                        )
                    },
                    onAction: { [weak self] newOption in

                    }
                )),
//            .toggle(SettingsToggleBusinessModel(
//                name: "iCloud Synchronization",
//                isOn: false
//            )),
            .externalLink(
                SettingsExternalLinkBusinessModel(
                    name: "iCloud Synchronization",
                    info: "Learn how to enable iCloud on this device.",
                ),
                onAction: { [weak self] in
                    self?.coordinator?.openExternalLink(url: EnableICloudSupportURL().toURL())
                }
            ),
            .externalLink(
                SettingsExternalLinkBusinessModel(
                    name: "Stargaze on Github",
                    info: nil
                ),
                onAction: { [weak self] in
                    self?.coordinator?.openExternalLink(url: JottreGithubURL().toURL())
                }
            ),
            .text(SettingsInfoBusinessModel(
                name: "Version",
                value: "2.0.0"
            ))
        ]
    }

    func didTapCloseButton() {
        coordinator?.dismiss()
    }

    private func makeLabel(userInterfaceStyle: UIUserInterfaceStyle) -> String {
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
