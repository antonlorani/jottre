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

    lazy var customUserInterfaceStyle = repository.getUserInterfaceStyleAppearancePublisher()

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
        let userInterfaceStyleAppearance = repository.getUserInterfaceStyleAppearance()

        let newItems = makeItems(
            canUseCloud: canUseCloud,
            shouldUseCloud: shouldUseCloud,
            isReadOnly: isReadOnly,
            userInterfaceStyleAppearance: userInterfaceStyleAppearance
        )

        itemsSubject.send(newItems)
    }

    private func makeItems(
        canUseCloud: Bool,
        shouldUseCloud: Bool,
        isReadOnly: Bool,
        userInterfaceStyleAppearance: CustomUserInterfaceStyle
    ) -> [Item] {
        var items = [Item]()

        items.append(
            .text(
                title: repository.getText(Constants.Items.Appearance.titleIdentifier),
                text: userInterfaceStyleAppearance.string,
                onClick: { [weak self] in
<<<<<<< HEAD
                    self?.appearanceItemDidTap(currentInterfaceStyle: userInterfaceStyleAppearance)
=======
                    self?.appearanceDidTap(currentInterfaceStyle: userInterfaceStyleAppearance)
>>>>>>> 6c59f0adac973792d37c8acc5b1e5df3722d571d
                }
            )
        )

        items.append(
            .switch(
                title: repository.getText(Constants.Items.Cloud.titleIdentifier),
                isOn: shouldUseCloud,
                isEnabled: (isReadOnly == false) && canUseCloud,
<<<<<<< HEAD
                onClick: { newState in
                    self.cloudItemDidTap(newState: newState)
                }
=======
                onClick: { _ in }
>>>>>>> 6c59f0adac973792d37c8acc5b1e5df3722d571d
            )
        )

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

<<<<<<< HEAD
    private func appearanceItemDidTap(currentInterfaceStyle: CustomUserInterfaceStyle) {
=======
    private func appearanceDidTap(currentInterfaceStyle: CustomUserInterfaceStyle) {
>>>>>>> 6c59f0adac973792d37c8acc5b1e5df3722d571d
        switch currentInterfaceStyle {
        case .system:
            repository.setUserInterfaceStyleAppearance(newUserInterfaceStyle: .dark)
        case .dark:
            repository.setUserInterfaceStyleAppearance(newUserInterfaceStyle: .light)
        case .light:
            repository.setUserInterfaceStyleAppearance(newUserInterfaceStyle: .system)
        }
        reload()
<<<<<<< HEAD
    }

    private func cloudItemDidTap(newState: Bool) {
        repository.setUsingCloud(state: newState)
        reload()
=======
>>>>>>> 6c59f0adac973792d37c8acc5b1e5df3722d571d
    }

    func didClickDone() {
        coordinator?.dismiss()
    }
}
