import Foundation

@MainActor
final class SettingsViewModel: Sendable {

    struct Item {
        enum Content {
            case dropdown(value: String, options: [String])
            case toggle(isOn: Bool)
            case externalLink(onAction: () -> Void)
            case text(value: String)
        }

        let name: String
        let content: Content
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
            Item(name: "Appearance", content: .dropdown(value: "Light", options: ["System", "Dark", "Light"])),
            Item(name: "iCloud Synchronization", content: .toggle(isOn: false)),
            Item(
                name: "Stargaze on Github",
                content: .externalLink(onAction: { [weak self] in
                    self?.coordinator?.openExternalLink(url: JottreGithubURL().toURL())
                })
            ),
            Item(name: "Version", content: .text(value: "2.0.0")),
        ]
    }

    func didTapCloseButton() {
        coordinator?.dismiss()
    }
}
