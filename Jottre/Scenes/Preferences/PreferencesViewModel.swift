import Combine
import UIKit

final class PreferencesViewModel {

    private struct Constants {
        struct Items {
            struct Appearance {
                static let titleIdentifier = "Scene.Preferences.Item.Appearance.title"
            }
            struct Source {
                static let titleIdentifier = "Scene.Preferences.Item.Source.title"
            }
            struct Cloud {
                static let titleIdentifier = "Scene.Preferences.Item.Cloud.title"
                static let notAvailableTextIdentifier = "Scene.Preferences.Item.Cloud.notAvailableText"
            }
            struct Version {
                static let titleIdentifier = "Scene.Preferences.Item.Version.title"
            }
        }
    }

    enum Item {
        case text(title: String, text: String, onClick: () -> Void),
             `switch`(title: String, isOn: Bool, isEnabled: Bool, onClick: (_ newState: Bool) -> Void),
             image(title: String, image: UIImage?, onClick: () -> Void)

        var title: String {
            switch self {
            case let .text(title, _, _):
                return title
            case let .switch(title, _, _, _):
                return title
            case let .image(title, _, _):
                return title
            }
        }

        var onClick: (() -> Void)? {
            switch self {
            case let .text(_, _, onClick):
                return onClick
            case let .image(_, _, onClick):
                return onClick
            case .switch:
                return nil
            }
        }
    }

    let navigationTitle: String

    private weak var coordinator: PreferencesCoordinator?
    private let repository: PreferencesRepositoryProtocol
    private let openURLProvider: (URL) -> Void

    private let itemsSubject = CurrentValueSubject<[Item], Never>([])
    lazy var items = itemsSubject
        .eraseToAnyPublisher()

    lazy var customUserInterfaceStyle = repository.getUserInterfaceStylePublisher()

    init(
        repository: PreferencesRepositoryProtocol,
        coordinator: PreferencesCoordinator,
        openURLProvider: @escaping (URL) -> Void
    ) {
        self.repository = repository
        self.coordinator = coordinator
        self.openURLProvider = openURLProvider
        navigationTitle = repository.getNavigationTitle()
        reload()
    }

    private func reload() {
        let canUseCloud = repository.getCanUseCloud()
        let shouldUseCloud = repository.getShouldUseCloud()
        let isReadOnly = repository.getIsReadOnly()
        let userInterfaceStyle = repository.getUserInterfaceStyle()

        let newItems = makeItems(
            canUseCloud: canUseCloud,
            shouldUseCloud: shouldUseCloud,
            isReadOnly: isReadOnly,
            userInterfaceStyle: userInterfaceStyle
        )

        itemsSubject.send(newItems)
    }

    private func makeItems(
        canUseCloud: Bool,
        shouldUseCloud: Bool,
        isReadOnly: Bool,
        userInterfaceStyle: UIUserInterfaceStyle
    ) -> [Item] {
        var items = [Item]()

        items.append(
            .text(
                title: repository.getText(Constants.Items.Appearance.titleIdentifier),
                text: userInterfaceStyle.string,
                onClick: { [weak self] in
                    self?.appearanceItemDidTap(currentUserInterfaceStyle: userInterfaceStyle)
                }
            )
        )

        if canUseCloud {
            items.append(
                .switch(
                    title: repository.getText(Constants.Items.Cloud.titleIdentifier),
                    isOn: shouldUseCloud,
                    isEnabled: isReadOnly == false,
                    onClick: { newState in
                        self.cloudItemDidTap(newState: newState)
                    }
                )
            )
        } else {
            items.append(
                .text(
                    title: repository.getText(Constants.Items.Cloud.titleIdentifier),
                    text: repository.getText(Constants.Items.Cloud.notAvailableTextIdentifier),
                    onClick: {}
                )
            )
        }

        items.append(
            .image(
                title: repository.getText(Constants.Items.Source.titleIdentifier),
                image: UIImage(
                    systemName: "link.circle.fill"
                ),
                onClick: { [weak self] in
                    self?.openURLProvider(JottreGitHubURL().asURL())
                }
            )
        )

        items.append(
            .text(
                title: repository.getText(Constants.Items.Version.titleIdentifier),
                text: "v2.0",
                onClick: {}
            )
        )

        return items
    }

    private func appearanceItemDidTap(currentUserInterfaceStyle: UIUserInterfaceStyle) {
        switch currentUserInterfaceStyle {
        case .unspecified:
            repository.setUserInterfaceStyle(newUserInterfaceStyle: .dark)
        case .dark:
            repository.setUserInterfaceStyle(newUserInterfaceStyle: .light)
        case .light:
            repository.setUserInterfaceStyle(newUserInterfaceStyle: .unspecified)
        default:
            repository.setUserInterfaceStyle(newUserInterfaceStyle: .unspecified)
        }
        reload()
    }

    private func cloudItemDidTap(newState: Bool) {
        repository.setUsingCloud(state: newState)
        reload()
    }

    func didClickDone() {
        coordinator?.dismiss()
    }
}
