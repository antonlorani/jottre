import Combine
import UIKit

final class PreferencesViewModel {

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

    private let itemsSubject = CurrentValueSubject<[Item], Never>([])
    lazy var items = itemsSubject
        .eraseToAnyPublisher()

    init(
        repository: PreferencesRepositoryProtocol,
        coordinator: PreferencesCoordinator
    ) {
        self.repository = repository
        self.coordinator = coordinator
        self.navigationTitle = repository.getNavigationTitle()
        load()
    }

    func load() {
        let newItems: [Item] = [
            .text(
                title: "Erscheinungsbild",
                text: "Dunkel",
                onClick: {}
            ),
            .image(
                title: "Source bei GitHub",
                image: UIImage(
                    systemName: "link.circle.fill"
                ),
                onClick: {}
            ),
            .switch(
                title: "Mit iCloud synchronisieren",
                isOn: repository.getIsCloudEnabled(),
                isEnabled: repository.getIsReadOnly(),
                onClick: { newState in }
            ),
            .text(
                title: "Version",
                text: "v2.0",
                onClick: {}
            )
        ]
        itemsSubject.send(newItems)
    }

    func didClickDone() {
        coordinator?.dismiss()
    }
}
